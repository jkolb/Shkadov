/*
The MIT License (MIT)

Copyright (c) 2016 Justin Kolb

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import Metal
import MetalKit

public final class MetalRenderer : NSObject, Renderer, MTKViewDelegate {
    public weak var delegate: RendererDelegate!
    public var view: NSView {
        return metalView
    }
    public let numberOfBuffers = 3
    public var viewport: Extent2D {
        get {
            return Extent2D(width: Int(metalView.drawableSize.width), height: Int(metalView.drawableSize.height))
        }
        set {
            metalView.drawableSize = CGSize(width: newValue.width, height: newValue.height)
        }
    }

    private let metalDevice: MTLDevice
    private let metalView: MTKView
    private let logger: Logger
    
    private let commandQueue: MTLCommandQueue
    private let frameSemaphore: dispatch_semaphore_t
    private var bufferIndex: Int
    private var frameCount: Int
    private var commandBuffer: MTLCommandBuffer!
    private var renderPassDescriptor: MTLRenderPassDescriptor!
    private var depthStencilState: MTLDepthStencilState

    public init(metalDevice: MTLDevice, metalView: MTKView, logger: Logger) {
        self.metalDevice = metalDevice
        self.logger = logger
        self.metalView = metalView
        self.commandQueue = metalDevice.newCommandQueue()
        self.frameSemaphore = dispatch_semaphore_create(numberOfBuffers)
        self.bufferIndex = 0
        self.frameCount = 0
        
        // TODO: This needs to be part of Renderable
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .Less
        depthStencilDescriptor.depthWriteEnabled = true
        depthStencilState = metalDevice.newDepthStencilStateWithDescriptor(depthStencilDescriptor)
    }
    
    public func renderRenderables(renderables: [Renderable]) {
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.label = #function

        for renderable in renderables {
            renderRenderable(renderable, renderEncoder: renderEncoder)
        }

        renderEncoder.endEncoding()
    }

    private func renderRenderable(renderable: Renderable, renderEncoder: MTLRenderCommandEncoder) {
        renderEncoder.pushDebugGroup(renderable.name)
        
        let renderPipelineState = renderable.renderPipeline.downCast(MTLRenderPipelineState)
        renderEncoder.setRenderPipelineState(renderPipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)

        let rasterizationState = renderable.rasterizationState.downCast(RasterizationStateDescriptor)
        let cullMode = MetalCullModeMapper.map(rasterizationState.cullMode)
        renderEncoder.setCullMode(cullMode)
        let frontFaceWinding = MetalFaceWindingMapper.map(rasterizationState.frontFaceWinding)
        renderEncoder.setFrontFacingWinding(frontFaceWinding)
        let triangleFillMode = MetalFillModeMapper.map(rasterizationState.fillMode)
        renderEncoder.setTriangleFillMode(triangleFillMode)
        
        switch rasterizationState.depthClipMode {
        case .Clip:
            renderEncoder.setDepthClipMode(.Clip)
        case .Clamp(let bias, let slope, let clamp):
            renderEncoder.setDepthClipMode(.Clamp)
            renderEncoder.setDepthBias(bias, slopeScale: slope, clamp: clamp)
        }
        
        for bufferBinding in renderable.vertexBindings.bufferBindings {
            let index = bufferBinding.index
            let buffer = bufferBinding.buffer.downCast(MTLBuffer)
            // TODO: Offset should come from binding
            renderEncoder.setVertexBuffer(buffer, offset: 0, atIndex: index)
        }
        
        for samplerBinding in renderable.vertexBindings.samplerBindings {
            let index = samplerBinding.index
            let samplerState = samplerBinding.sampler.downCast(MTLSamplerState)
            renderEncoder.setVertexSamplerState(samplerState, atIndex: index)
        }
        
        for textureBinding in renderable.vertexBindings.textureBindings {
            let index = textureBinding.index
            let texture = textureBinding.texture.downCast(MTLTexture)
            renderEncoder.setVertexTexture(texture, atIndex: index)
        }
        
        for bufferBinding in renderable.fragmentBindings.bufferBindings {
            let index = bufferBinding.index
            let buffer = bufferBinding.buffer.downCast(MTLBuffer)
            // TODO: Offset should come from renderable
            renderEncoder.setFragmentBuffer(buffer, offset: 0, atIndex: index)
        }
        
        for samplerBinding in renderable.fragmentBindings.samplerBindings {
            let index = samplerBinding.index
            let samplerState = samplerBinding.sampler.downCast(MTLSamplerState)
            renderEncoder.setFragmentSamplerState(samplerState, atIndex: index)
        }
        
        for textureBinding in renderable.fragmentBindings.textureBindings {
            let index = textureBinding.index
            let texture = textureBinding.texture.downCast(MTLTexture)
            renderEncoder.setFragmentTexture(texture, atIndex: index)
        }
        
        for vertexDraw in renderable.vertexDraws {
            let primitiveType = MetalPrimitiveTypeMapper.map(vertexDraw.primitiveType)
            let vertexStart = vertexDraw.vertexStart
            let vertexCount = vertexDraw.vertexCount
            let instanceCount = vertexDraw.instanceCount
            let baseInstance = vertexDraw.baseInstance
            
            renderEncoder.drawPrimitives(primitiveType, vertexStart: vertexStart, vertexCount: vertexCount, instanceCount: instanceCount, baseInstance: baseInstance)
        }
        
        for indexedVertexDraw in renderable.indexedVertexDraws {
            let primitiveType = MetalPrimitiveTypeMapper.map(indexedVertexDraw.primitiveType)
            let indexType = MetalIndexTypeMapper.map(indexedVertexDraw.indexType)
            let indexCount = indexedVertexDraw.indexCount
            let indexBuffer = indexedVertexDraw.indexBuffer.downCast(MTLBuffer)
            let indexBufferOffset = indexedVertexDraw.indexBufferOffset
            let instanceCount = indexedVertexDraw.instanceCount
            let baseVertex = indexedVertexDraw.baseVertex
            let baseInstance = indexedVertexDraw.baseInstance
            
            renderEncoder.drawIndexedPrimitives(primitiveType, indexCount: indexCount, indexType: indexType, indexBuffer: indexBuffer, indexBufferOffset: indexBufferOffset, instanceCount: instanceCount, baseVertex: baseVertex, baseInstance: baseInstance)
        }
        
        renderEncoder.popDebugGroup()
    }
    
    public func pause() {
        metalView.paused = true
    }
    
    public func resume() {
        metalView.paused = false
    }
    
    public func generateMipmapsForTextures(textures: [Texture]) {
        let commandBuffer = commandQueue.commandBuffer()
        let blitCommandEncoder = commandBuffer.blitCommandEncoder()
        
        for texture in textures {
            let metalTexture = texture.downCast(MTLTexture)
            blitCommandEncoder.generateMipmapsForTexture(metalTexture)
        }
        
        blitCommandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }

    private func renderFrame() {
        let semaphore = frameSemaphore
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        delegate.renderer(self, willRenderFrame: frameCount)
        
        if let currentRenderPassDescriptor = metalView.currentRenderPassDescriptor {
            currentRenderPassDescriptor.stencilAttachment = nil
            
            renderPassDescriptor = currentRenderPassDescriptor
            commandBuffer = commandQueue.commandBuffer()
            commandBuffer.addCompletedHandler { commandBuffer in
                dispatch_semaphore_signal(semaphore)
            }
            
            delegate.renderer(self, renderFrame: frameCount)
            
            if let currentDrawable = metalView.currentDrawable {
                commandBuffer.presentDrawable(currentDrawable)
            }
            else {
                fatalError("No drawable available for frame: \(frameCount)")
            }
            
            commandBuffer.commit()
            commandBuffer = nil
            renderPassDescriptor = nil
            
            delegate.renderer(self, didRenderFrame: frameCount)
            
            advanceToNextFrame()
        }
        else {
            fatalError("No renderPassDescriptor available for frame: \(frameCount)")
        }
    }
    
    private func advanceToNextFrame() {
        bufferIndex = (bufferIndex + 1) % numberOfBuffers
        frameCount += 1
    }
    
    public func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        logger.debug("\(#function) \(size)")
        let viewport = Extent2D(width: Int(size.width), height: Int(size.height))
        delegate.renderer(self, willChangeViewport: viewport)
    }
    
    public func drawInMTKView(view: MTKView) {
        autoreleasepool {
            renderFrame()
        }
    }
}
