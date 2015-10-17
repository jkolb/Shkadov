/*
The MIT License (MIT)

Copyright (c) 2015 Justin Kolb

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

import AppKit
import Metal
import MetalKit


public final class MetalRenderer : NSObject, ContentViewSource, Synchronizable {
    private let device: MTLDevice
    private let view: MTKView
    public let contentView: NSView
    public let synchronizationQueue: DispatchQueue

    private let programHandleFactory = HandleFactory()
    private var programs = [Handle : MTLRenderPipelineState]()
    
    private let textureHandleFactory = HandleFactory()
    private var textures = [Handle : MTLTexture]()

    private var renderStates = [[RenderState]]()
    
    private var commandQueue: MTLCommandQueue!
    private var library: MTLLibrary!
    private var depthStencilState: MTLDepthStencilState!
    private var sampler: MTLSamplerState!
    
    public override init() {
        self.device = MTLCreateSystemDefaultDevice()!
        self.view = MetalRenderer.createViewForDevice(self.device)
        self.contentView = self.view
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.render", attribute: .Serial)
        super.init()
        self.view.delegate = self
    }
    
    public static func createViewForDevice(device: MTLDevice) -> MTKView {
        let view = MTKView(frame: CGRect.zero, device: device)
        view.framebufferOnly = true
        view.presentsWithTransaction = false
        view.colorPixelFormat = .BGRA8Unorm
        view.depthStencilPixelFormat = .Depth32Float_Stencil8
        view.sampleCount = 4
        view.clearColor = MTLClearColor(red: 178.0/255.0, green: 1.0, blue: 1.0, alpha: 1.0)
        view.clearDepth = 1.0
        view.clearStencil = 0
        view.paused = true
        view.enableSetNeedsDisplay = false
        view.autoResizeDrawable = true
        return view
    }
}

extension MetalRenderer : MTKViewDelegate {
    public func mtkView(view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func drawInMTKView(view: MTKView) {
        let commandBuffer = commandQueue.commandBuffer()
        commandBuffer.label = "Frame Command Buffer"
        commandBuffer.addCompletedHandler { (commandBuffer) -> Void in
        }
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            fatalError("Missing render pass descriptor")
        }
        guard let currentDrawable = view.currentDrawable else {
            fatalError("Missing drawable")
        }
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.label = "Render Encoder"
        renderEncoder.setDepthStencilState(depthStencilState)
        
        let states = renderStates.removeAtIndex(0)
        
        for state in states {
            switch state.cullMode {
            case .None:
                renderEncoder.setCullMode(.None)
            case .Front:
                renderEncoder.setCullMode(.Front)
            case .Back:
                renderEncoder.setCullMode(.Back)
            }
            
            switch state.winding {
            case .Clockwise:
                renderEncoder.setFrontFacingWinding(.Clockwise)
            case .CounterClockwise:
                renderEncoder.setFrontFacingWinding(.CounterClockwise)
            }
            
            let program = programs[state.program]!
            renderEncoder.setRenderPipelineState(program)
            
            let vertexBuffer = state.vertexBuffer.rendererInfo as! MTLBuffer
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            
            if let texture = textures[state.texture] {
                renderEncoder.setFragmentTexture(texture, atIndex: 0)
                renderEncoder.setFragmentSamplerState(sampler, atIndex: 0)
            }
            
            for object in state.objects {
                let uniformBuffer = object.uniformBuffer.rendererInfo as! MTLBuffer
                renderEncoder.setVertexBuffer(uniformBuffer, offset: object.uniformOffset, atIndex: 1)
                renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: object.vertexCount)
            }
        }
        
        renderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(currentDrawable)
        commandBuffer.commit()
    }
}

extension MetalRenderer : Renderer {
    public func configure() {
        commandQueue = device.newCommandQueue()
        commandQueue.label = "Main Command Queue"
        
        library = device.newDefaultLibrary()
        
        let depthStencilDescriptor = MTLDepthStencilDescriptor()
        depthStencilDescriptor.depthCompareFunction = .Less
        depthStencilDescriptor.depthWriteEnabled = true
        depthStencilState = device.newDepthStencilStateWithDescriptor(depthStencilDescriptor)
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .Nearest
        samplerDescriptor.magFilter = .Nearest
        samplerDescriptor.sAddressMode = .Repeat
        samplerDescriptor.tAddressMode = .Repeat
        sampler = device.newSamplerStateWithDescriptor(samplerDescriptor)
    }
    
    public func renderStates(states: [RenderState]) {
        renderStates.append(states)
        view.draw()
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        
    }
    
    public func createTextureFromData(textureData: TextureData) -> Handle {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.BGRA8Unorm, width: textureData.size.width, height: textureData.size.height, mipmapped: false)
        let texture = device.newTextureWithDescriptor(textureDescriptor)
        let region = MTLRegionMake2D(0, 0, textureData.size.width, textureData.size.height)
        texture.replaceRegion(region, mipmapLevel: 0, withBytes: textureData.rawData, bytesPerRow: textureData.bytesPerRow)
        let handle = textureHandleFactory.nextHandle()
        textures[handle] = texture
        return handle
    }
    
    public func destroyTexture(handle: Handle) {
        textures.removeValueForKey(handle)
    }
    
    public func createProgramWithVertexPath(vertexPath: String, fragmentPath: String) -> Handle {
        let vertexProgram = library.newFunctionWithName(vertexPath)!
        let fragmentProgram = library.newFunctionWithName(fragmentPath)!
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "\(vertexPath):\(fragmentPath)"
        pipelineStateDescriptor.sampleCount = view.sampleCount
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
        pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat
        pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat
        
        var pipelineState: MTLRenderPipelineState
        
        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch let error {
            fatalError("Failed to create pipeline state, error \(error)")
        }
        
        let handle = programHandleFactory.nextHandle()
        programs[handle] = pipelineState
        
        return handle
    }
    
    public func destroyProgram(handle: Handle) {
        programs.removeValueForKey(handle)
    }
    
    public func createBufferWithName(name: String, length: Int) -> RenderBuffer {
        let buffer = device.newBufferWithLength(length, options: [])
        buffer.label = name
        return MetalRenderBuffer(buffer: buffer)
    }
}
