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
    var localToWorld: Matrix4x4<Float> = Matrix4x4<Float>()
    var color: Vector4<Float> = Vector4<Float>(0.0, 0.0, 0.0, 1.0)
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

let SHADOW_DIMENSION = 2048

let MAX_FRAMES_IN_FLIGHT : Int = 3

let SHADOW_PASS_COUNT : Int = 1
let MAIN_PASS_COUNT : Int = 1
let OBJECT_COUNT : Int = 200000

let START_POSITION = Vector3<Float>(0.0, 0.0, -325.0)

let START_CAMERA_VIEW_DIR = Vector3<Float>(0.0, 0.0, 1.0)
let START_CAMERA_UP_DIR = Vector3<Float>(0.0, 1.0, 0.0)

let GROUND_POSITION = Vector3<Float>(0.0, -250.0, 0.0)
let GROUND_COLOR = Vector4<Float>(1.0)

let SHADOWED_DIRECTIONAL_LIGHT_DIRECTION = Vector3<Float>(0.0, -1.0, 0.0)
let SHADOWED_DIRECTIONAL_LIGHT_UP = Vector3<Float>(0.0, 0.0, 1.0)
let SHADOWED_DIRECTIONAL_LIGHT_POSITION = Vector3<Float>(0.0, 225.0, 0.0)

let CONSTANT_BUFFER_SIZE : Int = OBJECT_COUNT * MemoryLayout<ObjectData>.size + SHADOW_PASS_COUNT * MemoryLayout<ShadowPass>.size + MAIN_PASS_COUNT * MemoryLayout<MainPass>.size

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
        
        var renderPassDescriptor = RenderPassDescriptor()
        renderPassDescriptor.colorAttachments.append(RenderPassColorAttachmentDescriptor())
        renderPassDescriptor.colorAttachments[0].clearColor = ClearColor(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        renderPassDescriptor.depthAttachment.clearDepth = 1.0
        renderPassDescriptor.depthAttachment.loadAction = .clear
        renderPassDescriptor.depthAttachment.storeAction = .dontCare
        
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
            
            let litVertexFunction = engine.createVertexFunction(module: module, named: "lit_vertex")
            let litFragmentFunction = engine.createFragmentFunction(module: module, named: "lit_fragment")
            let litShadowedFragment = engine.createFragmentFunction(module: module, named: "lit_shadowed_fragment")
            
            defer {
                engine.destroyVertexFunction(handle: litVertexFunction)
                engine.destroyFragmentFunction(handle: litFragmentFunction)
                engine.destroyFragmentFunction(handle: litShadowedFragment)
            }

            pipelineDescriptor.vertexShader = litVertexFunction
            pipelineDescriptor.fragmentShader = litFragmentFunction
            litPipeline = try engine.createRenderPipelineState(descriptor: pipelineDescriptor)

            pipelineDescriptor.fragmentShader = litShadowedFragment
            litShadowedPipeline = try engine.createRenderPipelineState(descriptor: pipelineDescriptor)

            pipelineDescriptor.vertexShader = planeVertex
            pipelineDescriptor.fragmentShader = planeFragment
            planeRenderPipeline = try engine.createRenderPipelineState(descriptor: pipelineDescriptor)

            let zpassVertex = engine.createVertexFunction(module: module, named: "zpass_vertex_main")
            let zpassFragment = engine.createFragmentFunction(module: module, named: "zpass_fragment")
            
            defer {
                engine.destroyVertexFunction(handle: zpassVertex)
                engine.destroyFragmentFunction(handle: zpassFragment)
            }

            pipelineDescriptor.vertexShader = zpassVertex
            pipelineDescriptor.fragmentShader = zpassFragment
            pipelineDescriptor.colorAttachments[0].pixelFormat = .invalid
            pipelineDescriptor.colorAttachments[0].writeMask = []
            zpassPipeline = try engine.createRenderPipelineState(descriptor: pipelineDescriptor)
            
            let vertexFunction2 = engine.createVertexFunction(module: module, named: "quad_vertex_main")
            let quadVisFragFunction = engine.createFragmentFunction(module: module, named: "quad_fragment_main")
            let quadTexVisFunction = engine.createFragmentFunction(module: module, named: "textured_quad_fragment")
            let quadDepthVisFunction = engine.createFragmentFunction(module: module, named: "visualize_depth_fragment")
            
            var pipeDesc = RenderPipelineDescriptor()
            pipeDesc.vertexShader = vertexFunction2
            pipeDesc.fragmentShader = quadVisFragFunction
            pipeDesc.colorAttachments.append(RenderPipelineColorAttachmentDescriptor())
            pipeDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            quadVisPipeline = try engine.createRenderPipelineState(descriptor: pipeDesc)
            
            pipeDesc.fragmentShader = quadDepthVisFunction
            depthVisPipeline = try engine.createRenderPipelineState(descriptor: pipeDesc)
            
            pipeDesc.fragmentShader = quadTexVisFunction
            texQuadVisPipeline = try engine.createRenderPipelineState(descriptor: pipeDesc)
        }
        catch {
            logger.debug("\(error)")
            fatalError()
        }
        
        for _ in 1...MAX_FRAMES_IN_FLIGHT {
            let buf = engine.createBuffer(count: CONSTANT_BUFFER_SIZE, storageMode: .unsafeSharedWithCPU)
            constantBuffers.append(buf)
        }
        
        do {
            var texDesc = TextureDescriptor()
            texDesc.pixelFormat = .depth32Float
            texDesc.width = SHADOW_DIMENSION
            texDesc.height = SHADOW_DIMENSION
            texDesc.depth = 1
            texDesc.textureType = .type2D
            texDesc.textureUsage = [.renderTarget, .shaderRead]
            texDesc.storageMode = .privateToGPU
            
            shadowMap = engine.createTexture(descriptor: texDesc)
        }
        
        do {
            var texDesc = TextureDescriptor()
            texDesc.width =  engine.config.renderer.width
            texDesc.height =  engine.config.renderer.height
            texDesc.depth = 1
            texDesc.textureType = .type2D
            
            texDesc.textureUsage = [.renderTarget, .shaderRead]
            texDesc.storageMode = .privateToGPU
            texDesc.pixelFormat = .bgra8Unorm
            
            mainPassFramebuffer = engine.createTexture(descriptor: texDesc)
            
            renderPassDescriptor.colorAttachments[0].texture = mainPassFramebuffer
        }
        
        do {
            var texDesc = TextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                width: engine.config.renderer.width,
                                                                height: engine.config.renderer.height,
                                                                mipmapped: false)
            texDesc.textureUsage = [.renderTarget, .shaderRead]
            texDesc.storageMode = .privateToGPU
            mainPassDepthTexture = engine.createTexture(descriptor: texDesc)
            
            renderPassDescriptor.depthAttachment.texture = mainPassDepthTexture
        }

        mainRenderPass = engine.createRenderPass(descriptor: renderPassDescriptor)

        do {
            var rp = RenderPassDescriptor()
            rp.depthAttachment.clearDepth = 1.0
            rp.depthAttachment.texture = shadowMap
            rp.depthAttachment.loadAction = .clear
            rp.depthAttachment.storeAction = .store
            shadowRenderPasses.append(engine.createRenderPass(descriptor: rp))
        }

        do {
            var depthStencilDesc = DepthStencilDescriptor()
            depthStencilDesc.isDepthWriteEnabled = true
            depthStencilDesc.depthCompareFunction = .less
            
            depthTestLess = engine.createDepthStencilState(descriptor: depthStencilDesc)
            
            depthStencilDesc.isDepthWriteEnabled = false
            depthStencilDesc.depthCompareFunction = .always
            
            depthTestAlways = engine.createDepthStencilState(descriptor: depthStencilDesc)
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
    
    private func createPlane() -> (GPUBufferHandle, Int) {
        var verts : [CFloat] = [ -1000.5, 0.0,  1000.5, 1.0,
                                 1000.5, 0.0,  1000.5, 1.0,
                                 -1000.5, 0.0, -1000.5, 1.0,
                                 1000.5, 0.0,  1000.5, 1.0,
                                 1000.5, 0.0, -1000.5, 1.0,
                                 -1000.5, 0.0, -1000.5, 1.0,]
        
        let length = verts.count*MemoryLayout<CFloat>.size
        
        let geoBufferHandle = engine.createBuffer(count: length, storageMode: .unsafeSharedWithCPU)
        let geoBuffer = engine.borrowBuffer(handle: geoBufferHandle)
        
        let geoPtr = geoBuffer.bytes.bindMemory(to: CFloat.self, capacity: length)
        
        geoPtr.assign(from: &verts, count: verts.count)
        geoBuffer.wasCPUModified(range: 0..<verts.count*MemoryLayout<Float>.size)
//        geoBuffer.didModifyRange(NSMakeRange(0, verts.count*MemoryLayout<Float>.size))
        
        return (geoBufferHandle, verts.count / 4)
    }
    
    private func createCube() -> (GPUBufferHandle, GPUBufferHandle?, Int, Int) {
        var verts : [CFloat] = [-0.5,  0.5, -0.5, 0.0, 0.0, -1.0,//0
            0.5,  0.5, -0.5, 0.0, 0.0, -1.0,//1
            0.5, -0.5, -0.5, 0.0, 0.0, -1.0,//2
            0.5, -0.5, -0.5, 0.0, 0.0, -1.0,//2
            -0.5, -0.5, -0.5, 0.0, 0.0, -1.0,//3
            -0.5,  0.5, -0.5, 0.0, 0.0, -1.0,//0
            
            0.5,  0.5, -0.5, 1.0,0.0,0.0, //1
            0.5,  0.5,  0.5, 1.0,0.0,0.0, //5
            0.5, -0.5,  0.5, 1.0,0.0,0.0, //6
            0.5, -0.5,  0.5, 1.0,0.0,0.0, //6
            0.5, -0.5, -0.5, 1.0,0.0,0.0, //2
            0.5,  0.5, -0.5, 1.0,0.0,0.0, //1
            
            0.5,  0.5,  0.5, 0.0,0.0,1.0, //5
            -0.5,  0.5,  0.5, 0.0,0.0,1.0, //4
            -0.5, -0.5,  0.5, 0.0,0.0,1.0, //7
            -0.5, -0.5,  0.5, 0.0,0.0,1.0, //7
            0.5, -0.5,  0.5, 0.0,0.0,1.0, //6
            0.5,  0.5,  0.5, 0.0,0.0,1.0, //5
            
            -0.5,  0.5,  0.5, -1.0,0.0,0.0, //4
            -0.5,  0.5, -0.5, -1.0,0.0,0.0, //0
            -0.5, -0.5, -0.5, -1.0,0.0,0.0, //3
            -0.5, -0.5, -0.5, -1.0,0.0,0.0, //3
            -0.5, -0.5,  0.5, -1.0,0.0,0.0, //7
            -0.5,  0.5,  0.5, -1.0,0.0,0.0, //4
            
            -0.5,  0.5,  0.5, 0.0,1.0,0.0,//4
            0.5,  0.5,  0.5, 0.0,1.0,0.0, //5
            0.5,  0.5, -0.5, 0.0,1.0,0.0, //1
            0.5,  0.5, -0.5, 0.0,1.0,0.0, //1
            -0.5,  0.5, -0.5, 0.0,1.0,0.0, //0
            -0.5,  0.5,  0.5, 0.0,1.0,0.0, //4
            
            -0.5, -0.5, -0.5, 0.0,-1.0,0.0, //3
            0.5, -0.5, -0.5, 0.0,-1.0,0.0, //2
            0.5, -0.5,  0.5, 0.0,-1.0,0.0, //6
            0.5, -0.5,  0.5, 0.0,-1.0,0.0, //6
            -0.5, -0.5,  0.5, 0.0,-1.0,0.0, //7
            -0.5, -0.5, -0.5, 0.0,-1.0,0.0, //3
        ]
        
        let length = verts.count*MemoryLayout<CFloat>.size
        let geoBufferHandle = engine.createBuffer(count: length, storageMode: .unsafeSharedWithCPU)
        let geoBuffer = engine.borrowBuffer(handle: geoBufferHandle)
        
        let geoPtr = geoBuffer.bytes.bindMemory(to: CFloat.self, capacity: length)
        
        geoPtr.assign(from: &verts, count: verts.count)
        geoBuffer.wasCPUModified(range: 0..<verts.count*MemoryLayout<Float>.size)
//        geoBuffer.didModifyRange(NSMakeRange(0, verts.count*MemoryLayout<Float>.size))
        
        return (geoBufferHandle, nil, 0, verts.count/6)
    }
}
