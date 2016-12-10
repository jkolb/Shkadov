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

import Swiftish

let MaxBuffers = 3
let ConstantBufferSize = 1024*1024

let vertexData:[Float] =
    [
        -1.0, -1.0, 0.0, 1.0,
        -1.0,  1.0, 0.0, 1.0,
        1.0, -1.0, 0.0, 1.0,
        
        1.0, -1.0, 0.0, 1.0,
        -1.0,  1.0, 0.0, 1.0,
        1.0,  1.0, 0.0, 1.0,
        
        -0.0, 0.25, 0.0, 1.0,
        -0.25, -0.25, 0.0, 1.0,
        0.25, -0.25, 0.0, 1.0
]

let vertexColorData:[Float] =
    [
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        0.0, 0.0, 1.0, 1.0,
        
        0.0, 0.0, 1.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        1.0, 0.0, 0.0, 1.0
]

public final class OneTriangle : EngineListener {
    private let engine: Engine
    private let logger: Logger
    
    private var totalDuration = Duration.zero
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let tickDuration = Duration(seconds: 1.0 / 60.0)
    private let maxFrameDuration = Duration(seconds: 0.25)
    
    private var commandQueue: CommandQueue
    private var pipeline: RenderPipelineStateHandle
    private var renderPass: RenderPassHandle
    private var framebuffer: Framebuffer
    private var vertexBuffer: GPUBufferHandle
    private var vertexColorBuffer: GPUBufferHandle

    private var bufferIndex: Int
    
    private var xOffset:[Float] = [ -1.0, 1.0, -1.0 ]
    private var yOffset:[Float] = [ 1.0, 0.0, -1.0 ]
    private var xDelta:[Float] = [ 0.002, -0.001, 0.003 ]
    private var yDelta:[Float] = [ 0.001,  0.002, -0.001 ]

    public init(engine: Engine, logger: Logger) {
        self.engine = engine
        self.logger = logger
        self.commandQueue = engine.makeCommandQueue()
        self.pipeline = RenderPipelineStateHandle()
        self.renderPass = RenderPassHandle()
        self.framebuffer = Framebuffer()
        self.vertexBuffer = GPUBufferHandle()
        self.vertexColorBuffer = GPUBufferHandle()
        self.bufferIndex = 0
    }
    
    private func makePipeline() -> RenderPipelineStateHandle {
        do {
            let modulePath = engine.pathForResource(named: "default.metallib")
            logger.debug("\(modulePath)")
            let module = try engine.createModule(filepath: modulePath)
            defer {
                engine.destroyModule(handle: module)
            }
            
            precondition(module.isValid)
            
            let vertexShader = engine.createVertexFunction(module: module, named: "passThroughVertex")
            let fragmentShader = engine.createFragmentFunction(module: module, named: "passThroughFragment")
            defer {
                engine.destroyVertexFunction(handle: vertexShader)
                engine.destroyFragmentFunction(handle: fragmentShader)
            }
            
            precondition(vertexShader.isValid)
            precondition(fragmentShader.isValid)
            
            var descriptor = RenderPipelineDescriptor()
            descriptor.vertexShader = vertexShader
            descriptor.fragmentShader = fragmentShader
            descriptor.colorAttachments.append(RenderPipelineColorAttachmentDescriptor())
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            descriptor.sampleCount = 4
            
            return try engine.createRenderPipelineState(descriptor: descriptor)
        }
        catch {
            logger.debug("\(error)")
            fatalError()
        }
    }
    
    private func makeRenderPass() -> RenderPassHandle {
        var descriptor = RenderPassDescriptor()
        descriptor.colorAttachments.append(RenderPassColorAttachmentDescriptor())
        descriptor.colorAttachments[0].resolve = true
        descriptor.colorAttachments[0].storeAction = .multisampleResolve
        return engine.createRenderPass(descriptor: descriptor)
    }
    
    private func makeFramebuffer() -> Framebuffer {
        var framebuffer = Framebuffer()
        framebuffer.colorAttachments.append(FramebufferAttachment())
        framebuffer.colorAttachments[0].render = makeMultisampleTexture()
        return framebuffer
    }
    
    private func makeMultisampleTexture() -> TextureHandle {
        var descriptor = TextureDescriptor()
        descriptor.width = 640
        descriptor.height = 360
        descriptor.pixelFormat = .bgra8Unorm
        descriptor.textureType = .type2D
        descriptor.sampleCount = 4
        descriptor.textureUsage = [.shaderRead, .shaderWrite, .renderTarget]
        descriptor.storageMode = .privateToGPU
        return engine.createTexture(descriptor: descriptor)
    }
    
    public func didStartup() {
        logger.debug("\(#function)")
        logger.debug("Screen Size: \(engine.screensSize)")
        
        pipeline = makePipeline()
        framebuffer = makeFramebuffer()
        renderPass = makeRenderPass()
        vertexBuffer = engine.createBuffer(count: ConstantBufferSize, storageMode: .sharedWithCPU)
        vertexColorBuffer = engine.createBuffer(bytes: vertexColorData, count: vertexData.count * MemoryLayout<Float>.size, storageMode: .sharedWithCPU)
        
        precondition(pipeline.isValid)
        precondition(framebuffer.colorAttachments[0].render.isValid)
        precondition(renderPass.isValid)
        precondition(vertexBuffer.isValid)
        precondition(vertexColorBuffer.isValid)
    }
    
    public func willShutdown() {
        logger.debug("\(#function)")
        
        do {
            try engine.writeConfig()
        }
        catch {
            logger.error("\(error)")
        }
    }
    
    public func willResizeScreen(size: Vector2<Int>) -> Vector2<Int> {
        logger.debug("\(#function) \(size)")
        return size
    }
    
    public func didResizeScreen() {
        logger.debug("\(#function)")
    }
    
    public func willMoveScreen() {
        logger.debug("\(#function)")
    }
    
    public func didMoveScreen() {
        logger.debug("\(#function)")
    }
    
    public func willEnterFullScreen() {
        logger.debug("\(#function)")
    }
    
    public func didEnterFullScreen() {
        logger.debug("\(#function)")
    }
    
    public func willExitFullScreen() {
        logger.debug("\(#function)")
    }
    
    public func didExitFullScreen() {
        logger.debug("\(#function)")
    }
    
    public  func received(input: RawInput) {
        logger.debug("\(#function) \(input)")
    }
    
    public func processFrame() {
        logger.trace("\(#function)")
        
        engine.waitForGPUIfNeeded()
        
        let currentTime = engine.currentTime
        var frameDuration = currentTime - previousTime
        logger.trace("FRAME DURATION: \(frameDuration)")
        
        if frameDuration > maxFrameDuration {
            logger.debug("EXCEEDED FRAME DURATION")
            frameDuration = maxFrameDuration
        }
        
        accumulatedTime += frameDuration
        previousTime = currentTime
        
        while accumulatedTime >= tickDuration {
            accumulatedTime -= tickDuration
            totalDuration += tickDuration
            
            update(elapsed: tickDuration)
        }
        
        render()
    }
    
    private func update(elapsed: Duration) {
        logger.trace("\(#function)")
        
        let vertices = engine.borrowBuffer(handle: vertexBuffer)
        let pData = vertices.bytes
        let vData = (pData + 256 * bufferIndex).bindMemory(to:Float.self, capacity: 256 / MemoryLayout<Float>.stride)
        
        vData.initialize(from: vertexData)
        
        let lastTriVertex = 24
        let vertexSize = 4
        
        for j in 0..<3 {
            xOffset[j] += xDelta[j]
            
            if(xOffset[j] >= 1.0 || xOffset[j] <= -1.0) {
                xDelta[j] = -xDelta[j]
                xOffset[j] += xDelta[j]
            }
            
            yOffset[j] += yDelta[j]
            
            if(yOffset[j] >= 1.0 || yOffset[j] <= -1.0) {
                yDelta[j] = -yDelta[j]
                yOffset[j] += yDelta[j]
            }
            
            let pos = lastTriVertex + j*vertexSize
            vData[pos] = xOffset[j]
            vData[pos+1] = yOffset[j]
        }
    }
    
    private func render() {
        logger.trace("\(#function)")
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderTarget = engine.acquireNextRenderTarget()
        precondition(renderTarget.isValid)
        
        framebuffer.colorAttachments[0].resolve = engine.textureForRenderTarget(handle: renderTarget)
        precondition(framebuffer.colorAttachments[0].resolve.isValid)
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(handle: renderPass, framebuffer: framebuffer)
        renderEncoder.setRenderPipelineState(pipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 256 * bufferIndex, at: 0)
        renderEncoder.setVertexBuffer(vertexColorBuffer, offset: 0, at: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 9, instanceCount: 1)
        renderEncoder.endEncoding()
        
        engine.present(commandBuffer: commandBuffer, renderTarget: renderTarget)

        bufferIndex = (bufferIndex + 1) % MaxBuffers
        
        commandBuffer.commit()
    }
}
