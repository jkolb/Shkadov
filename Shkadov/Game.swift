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

struct ObjectData {
    var localToWorld: Matrix4x4<Float>
    var color: Vector4<Float>
//    vector_float4 pad0;
//    vector_float4 pad01;
//    vector_float4 pad02;
//    matrix_float4x4 pad1;
//    matrix_float4x4 pad2;
}

struct ShadowPass {
    var viewProjection: Matrix4x4<Float>
//    matrix_float4x4 pad1;
//    matrix_float4x4 pad2;
//    matrix_float4x4 pad3;
}

struct MainPass {
    var viewProjection: Matrix4x4<Float>
    var viewShadow0Projection: Matrix4x4<Float>
    var lightPosition: Vector4<Float>
//    vector_float4	pad00;
//    vector_float4	pad01;
//    vector_float4	pad02;
//    matrix_float4x4 pad1;
}

public final class Game : EngineListener {
    private let engine: Engine
    private let logger: Logger

    private var totalDuration = Duration.zero
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let tickDuration = Duration(seconds: 1.0 / 60.0)
    private let maxFrameDuration = Duration(seconds: 0.25)
    private let camera = Camera()
    private let commandQueue: CommandQueue
    private var mainRenderPass: RenderPassHandle
    private var shadowRenderPasses: [RenderPassHandle]
    private var shadowMap: TextureHandle
    private var mainPassDepthTexture: TextureHandle
    private var mainPassFramebuffer: TextureHandle
    private var depthTestLess: DepthStencilStateHandle
    private var depthTestAlways: DepthStencilStateHandle
    private var constantBuffers: [GPUBufferHandle]
    private var unshadedPipeline: RenderPipelineStateHandle
    private var unshadedShadowedPipeline: RenderPipelineStateHandle
    private var litPipeline: RenderPipelineStateHandle
    private var litShadowedPipeline: RenderPipelineStateHandle
    private var planeRenderPipeline: RenderPipelineStateHandle
    private var zpassPipeline: RenderPipelineStateHandle
    private var quadVisPipeline: RenderPipelineStateHandle
    private var depthVisPipeline: RenderPipelineStateHandle
    private var texQuadVisPipeline: RenderPipelineStateHandle

    public init(engine: Engine, logger: Logger) {
        self.engine = engine
        self.logger = logger
        self.commandQueue = engine.makeCommandQueue()
        self.mainRenderPass = RenderPassHandle()
        self.shadowRenderPasses = []
        self.shadowMap = TextureHandle()
        self.mainPassDepthTexture = TextureHandle()
        self.mainPassFramebuffer = TextureHandle()
        self.depthTestLess = DepthStencilStateHandle()
        self.depthTestAlways = DepthStencilStateHandle()
        self.constantBuffers = []
        self.unshadedPipeline = RenderPipelineStateHandle()
        self.unshadedShadowedPipeline = RenderPipelineStateHandle()
        self.litPipeline = RenderPipelineStateHandle()
        self.litShadowedPipeline = RenderPipelineStateHandle()
        self.planeRenderPipeline = RenderPipelineStateHandle()
        self.zpassPipeline = RenderPipelineStateHandle()
        self.quadVisPipeline = RenderPipelineStateHandle()
        self.depthVisPipeline = RenderPipelineStateHandle()
        self.texQuadVisPipeline = RenderPipelineStateHandle()
    }
    
    public func didStartup() {
        logger.debug("\(#function)")
        logger.debug("Screen Size: \(engine.screensSize)")
        
        do {
            let modulePath = engine.pathForResource(named: "default.metallib")
            logger.debug("\(modulePath)")
            let module = try engine.createModule(filepath: modulePath)
            defer {
                engine.destroyModule(handle: module)
            }
            
            let vertexFunction = engine.createVertexFunction(module: module, named: "vertex_main")
            let unshadedFragment = engine.createFragmentFunction(module: module, named: "unshaded_fragment")
            let unshadedShadowedFragment = engine.createFragmentFunction(module: module, named: "unshaded_shadowed_fragment")
            let planeVertex = engine.createVertexFunction(module: module, named: "plane_vertex")
            let planeFragment = engine.createFragmentFunction(module: module, named: "plane_fragment")

            defer {
                engine.destroyVertexFunction(handle: vertexFunction)
                engine.destroyFragmentFunction(handle: unshadedFragment)
                engine.destroyFragmentFunction(handle: unshadedShadowedFragment)
                engine.destroyVertexFunction(handle: planeVertex)
                engine.destroyFragmentFunction(handle: planeFragment)
            }

            var pipelineDescriptor = RenderPipelineDescriptor()
            pipelineDescriptor.vertexShader = vertexFunction
            pipelineDescriptor.fragmentShader = unshadedFragment
            pipelineDescriptor.colorAttachments.append(RenderPipelineColorAttachmentDescriptor())
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            
            unshadedPipeline = try engine.createRenderPipelineState(descriptor: pipelineDescriptor)
            
            pipelineDescriptor.fragmentShader = unshadedShadowedFragment
            unshadedShadowedPipeline = try engine.createRenderPipelineState(descriptor: pipelineDescriptor)
            
        }
        catch {
            logger.debug("\(error)")
            fatalError()
        }
        
        
        camera.projection.fovy = engine.config.renderer.fovy
        camera.projection.zNear = 0.1
        camera.projection.zFar = 1000.0
        camera.worldTransform.t = Vector3<Float>(0.0, 0.0, 0.0)
        camera.worldTransform.r = rotation(pitch: Angle<Float>(), yaw: Angle<Float>(), roll: Angle<Float>())
        engine.mouseCursorFollowsMouse = true
        engine.mouseCursorHidden = true
        previousTime = engine.currentTime
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
    }
    
    private func render() {
        logger.trace("\(#function)")
        let commandBuffer = commandQueue.makeCommandBuffer()
        engine.present(commandBuffer: commandBuffer)
        commandBuffer.commit()
    }
}
