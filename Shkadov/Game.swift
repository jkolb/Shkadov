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
import Darwin
import simd

struct ObjectData
{
    var LocalToWorld: matrix_float4x4 = matrix_float4x4()
    var color: vector_float4 = vector_float4()
    var pad0: vector_float4 = vector_float4()
    var pad01: vector_float4 = vector_float4()
    var pad02: vector_float4 = vector_float4()
    var pad1: matrix_float4x4 = matrix_float4x4()
    var pad2: matrix_float4x4 = matrix_float4x4()
    
}

struct ShadowPass
{
    var ViewProjection: matrix_float4x4 = matrix_float4x4()
    var pad1: matrix_float4x4 = matrix_float4x4()
    var pad2: matrix_float4x4 = matrix_float4x4()
    var pad3: matrix_float4x4 = matrix_float4x4()
};

struct MainPass
{
    var ViewProjection: matrix_float4x4 = matrix_float4x4()
    var ViewShadow0Projection: matrix_float4x4 = matrix_float4x4()
    var LightPosition: vector_float4 = vector_float4()
    var pad00: vector_float4 = vector_float4()
    var pad01: vector_float4 = vector_float4()
    var pad02: vector_float4 = vector_float4()
    var pad1: matrix_float4x4 = matrix_float4x4()
}

let DEG2RAD = M_PI / 180.0

let SHADOW_DIMENSION = 2048

let MAX_FRAMES_IN_FLIGHT : Int = 3

let SHADOW_PASS_COUNT : Int = 1
let MAIN_PASS_COUNT : Int = 1
let OBJECT_COUNT : Int = 200000

let START_POSITION = float3(0.0, 0.0, -325.0)

let START_CAMERA_VIEW_DIR = float3(0.0, 0.0, 1.0)
let START_CAMERA_UP_DIR = float3(0.0, 1.0, 0.0)

let GROUND_POSITION = float3(0.0, -250.0, 0.0)
let GROUND_COLOR = float4(1.0)

let SHADOWED_DIRECTIONAL_LIGHT_DIRECTION = float3(0.0, -1.0, 0.0)
let SHADOWED_DIRECTIONAL_LIGHT_UP = float3(0.0, 0.0, 1.0)
let SHADOWED_DIRECTIONAL_LIGHT_POSITION = float3(0.0, 225.0, 0.0)

let CONSTANT_BUFFER_SIZE : Int = OBJECT_COUNT * MemoryLayout<ObjectData>.size + SHADOW_PASS_COUNT * MemoryLayout<ShadowPass>.size + MAIN_PASS_COUNT * MemoryLayout<MainPass>.size

public final class Game : EngineListener {
    private let engine: Engine
    private let logger: Logger

    private var totalDuration = Duration.zero
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let tickDuration = Duration(seconds: 1.0 / 60.0)
    private let maxFrameDuration = Duration(seconds: 0.25)
    private let camera = ACamera()
    private var shadowCamera: ACamera = ACamera()
    private let commandQueue: CommandQueue
    private var mainRenderPass: RenderPassHandle
    private var mainPassFramebuffer: Framebuffer
    private var shadowRenderPass: RenderPassHandle
    private var shadowFramebuffer: Framebuffer
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
    private var renderables: ContiguousArray<RenderableObject> = ContiguousArray<RenderableObject>()
    private var groundPlane: StaticRenderableObject!
    private var frameCounter: UInt = 1
    private var constantBufferSlot: Int = 0
    private var mainPassView = matrix_float4x4()
    private var mainPassProjection = matrix_float4x4()
    private var mainPassFrameData = MainPass()
    private var shadowPassData = ShadowPass()
    private var moveForward = false
    private var moveBackward = false
    private var moveLeft = false
    private var moveRight = false
    private var mouseDown = false
    private var objectsToRender = 1000
    private var orbit = float2()
    private var cameraAngles = float2()
    private var mainRasterizerState: RasterizerStateHandle
    private var shadowRasterizerState: RasterizerStateHandle
    private var finalRenderPass: RenderPassHandle
    private var finalFrameBuffer = Framebuffer()
    
    public init(engine: Engine, logger: Logger) {
        self.engine = engine
        self.logger = logger
        self.commandQueue = engine.makeCommandQueue()
        self.mainRenderPass = RenderPassHandle()
        self.mainPassFramebuffer = Framebuffer()
        self.shadowRenderPass = RenderPassHandle()
        self.shadowFramebuffer = Framebuffer()
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
        self.mainRasterizerState = RasterizerStateHandle()
        self.shadowRasterizerState = RasterizerStateHandle()
        self.finalRenderPass = RenderPassHandle()
        
        finalFrameBuffer.colorAttachments.append(FramebufferAttachment())
    }
    
    public func didStartup() {
        logger.debug("\(#function)")
        logger.debug("Screen Size: \(engine.screensSize)")
        
        camera.position = START_POSITION
        camera.direction = START_CAMERA_VIEW_DIR
        camera.up = START_CAMERA_UP_DIR
        
        // Set up shadow camera and data
        do
        {
            shadowCamera.direction = SHADOWED_DIRECTIONAL_LIGHT_DIRECTION
            shadowCamera.up = SHADOWED_DIRECTIONAL_LIGHT_UP
            shadowCamera.position = SHADOWED_DIRECTIONAL_LIGHT_POSITION
        }

        var mainRasterizer = RasterizerStateDescriptor()
        mainRasterizer.cullMode = .back
        mainRasterizerState = engine.createRasterizerState(descriptor: mainRasterizer)
        
        var shadowRasterizer = RasterizerStateDescriptor()
        shadowRasterizer.cullMode = .front
        shadowRasterizerState = engine.createRasterizerState(descriptor: shadowRasterizer)
        
        var finalPassDescriptor = RenderPassDescriptor()
        finalPassDescriptor.colorAttachments.append(RenderPassColorAttachmentDescriptor())
        finalRenderPass = engine.createRenderPass(descriptor: finalPassDescriptor)
        
        var renderPassDescriptor = RenderPassDescriptor()
        renderPassDescriptor.colorAttachments.append(RenderPassColorAttachmentDescriptor())
        renderPassDescriptor.colorAttachments[0].clearColor = ClearColor(r: 1.0, g: 0.0, b: 0.0, a: 1.0)
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
            
            shadowFramebuffer.depthAttachment.render = engine.createTexture(descriptor: texDesc)
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
            
            var attachment = FramebufferAttachment()
            attachment.render = engine.createTexture(descriptor: texDesc)
            mainPassFramebuffer.colorAttachments.append(attachment)
        }
        
        do {
            var texDesc = TextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                width: engine.config.renderer.width,
                                                                height: engine.config.renderer.height,
                                                                mipmapped: false)
            texDesc.textureUsage = [.renderTarget, .shaderRead]
            texDesc.storageMode = .privateToGPU
            
            mainPassFramebuffer.depthAttachment.render = engine.createTexture(descriptor: texDesc)
        }

        mainRenderPass = engine.createRenderPass(descriptor: renderPassDescriptor)

        do {
            var rp = RenderPassDescriptor()
            rp.depthAttachment.clearDepth = 1.0
            rp.depthAttachment.loadAction = .clear
            rp.depthAttachment.storeAction = .store

            shadowRenderPass = engine.createRenderPass(descriptor: rp)
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

        do {
            let (geo, index, indexCount, vertCount) = createCube()
            
            for _ in 0..<OBJECT_COUNT {
                let p = Float(getRandomValue(500.0))
                let p1 = Float(getRandomValue(100.0))
                let p2 = Float(getRandomValue(500.0))
                
                let cube = RenderableObject(m: geo, idx: index, count: indexCount, tex: TextureHandle())
                cube.position = float4(p, p1, p2, 1.0)
                cube.count = vertCount
                
                let r = Float(Float(drand48())) * 2.0
                let r1 = Float(Float(drand48())) * 2.0
                let r2 = Float(Float(drand48())) * 2.0
                
                cube.rotationRate = float3(r, r1, r2)
                
                let scale = Float(drand48()*5.0)
                
                cube.scale = float3(scale)
                
                cube.objectData.color = float4(Float(drand48()),
                                               Float(drand48()),
                                               Float(drand48()), 1.0)
                renderables.append(cube)
            }
        }
        
        do {
            let (planeGeo, count) = createPlane()
            groundPlane = StaticRenderableObject(m: planeGeo, idx: GPUBufferHandle(), count: count, tex: TextureHandle())
            groundPlane.position = float4(GROUND_POSITION.x,
                                           GROUND_POSITION.y,
                                           GROUND_POSITION.z,1.0)
            groundPlane.objectData.color = GROUND_COLOR
            groundPlane.objectData.LocalToWorld.columns.3 = groundPlane!.position
        }

        mainPassProjection = getPerpectiveProjectionMatrix(Float(60.0*DEG2RAD), aspectRatio: Float(engine.config.renderer.width) / Float(engine.config.renderer.height), zFar: 2000.0, zNear: 1.0)

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
        let currentConstantBuffer = constantBufferSlot
        
        // Update view matrix here
        if moveForward {
            camera.position.z += 1.0
        }
        else if moveBackward {
            camera.position.z -= 1.0
        }
        
        if mouseDown {
            cameraAngles.x += 0.005 * orbit.y
            cameraAngles.y += 0.005 * orbit.x
        }
        
        do {
            // Figure out far plane distance at least
            let zFar = distance(GROUND_POSITION,SHADOWED_DIRECTIONAL_LIGHT_POSITION)
            
            shadowPassData.ViewProjection = getLHOrthoMatrix(1100, height: 1100, zFar: zFar, zNear: 25)
            shadowPassData.ViewProjection = matrix_multiply(shadowPassData.ViewProjection, shadowCamera.GetViewMatrix())
        }
        
        do {
            //NOTE: We're doing an orbit so we've usurped the normal camera class here
            mainPassView = matrix_multiply(getRotationAroundY(cameraAngles.y), getRotationAroundX(cameraAngles.x))
            mainPassView = matrix_multiply(camera.GetViewMatrix(), mainPassView)
            mainPassFrameData.ViewProjection = matrix_multiply(mainPassProjection, mainPassView)
            mainPassFrameData.ViewShadow0Projection = shadowPassData.ViewProjection
            mainPassFrameData.LightPosition = float4(SHADOWED_DIRECTIONAL_LIGHT_POSITION.x,
                                                     SHADOWED_DIRECTIONAL_LIGHT_POSITION.y,
                                                     SHADOWED_DIRECTIONAL_LIGHT_POSITION.z, 1.0)
        }
        
        // Select which constant buffer to use
        let constantBufferForFrame = engine.borrowBuffer(handle: constantBuffers[currentConstantBuffer])
        
        // Calculate the offsets into the constant buffer for the shadow pass data, main pass data, and object data
        let shadowOffset = 0
        let mainPassOffset = 256 + shadowOffset
        let objectDataOffset = 256 + mainPassOffset
        
        // Write the shadow pass data into the constants buffer
        constantBufferForFrame.bytes.storeBytes(of: shadowPassData, toByteOffset: shadowOffset, as: ShadowPass.self)
        
        // Write the main pass data into the constants buffer
        constantBufferForFrame.bytes.storeBytes(of: mainPassFrameData, toByteOffset: mainPassOffset, as: MainPass.self)
        
        // Create a mutable pointer to the beginning of the object data so we can step through it and set the data of each object individually
        var ptr = constantBufferForFrame.bytes.advanced(by: objectDataOffset).bindMemory(to: ObjectData.self, capacity: objectsToRender)
        
        for index in 0..<objectsToRender {
            ptr = renderables[index].UpdateData(ptr, deltaTime: Float(elapsed.seconds))
        }
        
        ptr = ptr.advanced(by: objectsToRender)
        
        _ = groundPlane.UpdateData(ptr, deltaTime: Float(elapsed.seconds))
        
        // Mark constant buffer as modified (objectsToRender+1 because of the ground plane)
        constantBufferForFrame.wasCPUModified(range: 0..<mainPassOffset+(256*(objectsToRender+1)))
    }
    
    private func render() {
        logger.trace("\(#function)")
        
        // Create command buffers for the entire scene rendering
        let shadowCommandBuffer = commandQueue.makeCommandBuffer()
        let mainCommandBuffer = commandQueue.makeCommandBuffer()
        
        // Enforce the ordering:
        // Shadows must be completed before the main rendering pass
        shadowCommandBuffer.enqueue()
        mainCommandBuffer.enqueue()
        
        let currentConstantBuffer = constantBufferSlot
        let shadowOffset = 0
        let mainPassOffset = 256 + shadowOffset
        let objectDataOffset = 256 + mainPassOffset

        encodeShadowPass(shadowCommandBuffer, rp: shadowRenderPass, constantBuffer: constantBuffers[currentConstantBuffer], passDataOffset: shadowOffset, objectDataOffset: objectDataOffset)
        drawMainPass(mainCommandBuffer, constantBuffer: constantBuffers[currentConstantBuffer], mainPassOffset: mainPassOffset, objectDataOffset: objectDataOffset)
        constantBufferSlot = (constantBufferSlot + 1) % MAX_FRAMES_IN_FLIGHT
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
    
    private func createCube() -> (GPUBufferHandle, GPUBufferHandle, Int, Int) {
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
        
        return (geoBufferHandle, GPUBufferHandle(), 0, verts.count/6)
    }
    
    func encodeShadowPass(_ commandBuffer: CommandBuffer, rp: RenderPassHandle, constantBuffer: GPUBufferHandle, passDataOffset: Int, objectDataOffset: Int) {
        let enc = commandBuffer.makeRenderCommandEncoder(handle: rp, framebuffer: shadowFramebuffer)
        enc.setDepthStencilState(depthTestLess)
        
        enc.setRasterizerState(shadowRasterizerState)
        
        // setVertexOffset will allow faster updates, but we must bind the Constant buffer once
        enc.setVertexBuffer(constantBuffer, offset: 0, at: 1)
        // Bind the ShadowPass data once for all objects to see
        enc.setVertexBuffer(constantBuffer, offset: passDataOffset, at: 2)
        
        // We have one pipeline for all our objects, so only bind it once
        enc.setRenderPipelineState(zpassPipeline)
        enc.setVertexBuffer(renderables[0].mesh, offset: 0, at: 0)
        
        var offset = objectDataOffset
        for index in 0..<objectsToRender {
            renderables[index].DrawZPass(enc, offset: offset)
            offset += 256
        }
        
        enc.endEncoding()
        
        commandBuffer.commit()
    }
    
    // A tiny bit more complex than DrawShadowPass
    // We must pick the current drawable from MTKView as well as calling present before
    // Committing our command buffer
    // We'll also add a completion handler to signal the semaphore
    
    func encodeMainPass(_ enc: RenderCommandEncoder, constantBuffer: GPUBufferHandle, passDataOffset: Int, objectDataOffset: Int) {
        // Similar to the shadow passes, we must bind the constant buffer once before we call setVertexBytes
        enc.setVertexBuffer(constantBuffer, offset: 0, at: 1)
        enc.setFragmentBuffer(constantBuffer, offset: 0, at: 1)
        
        // Now bind the MainPass constants once
        enc.setVertexBuffer(constantBuffer, offset: passDataOffset, at: 2)
        enc.setFragmentBuffer(constantBuffer, offset: passDataOffset, at: 2)
        
        enc.setFragmentTexture(shadowFramebuffer.depthAttachment.render, at: 0)
        
        var offset = objectDataOffset
        enc.setRenderPipelineState(litShadowedPipeline)
        
        enc.setVertexBuffer(renderables[0].mesh, offset: 0, at: 0)
        for index in 0..<objectsToRender {
            renderables[index].Draw(enc, offset: offset)
            offset += 256
        }
        
        enc.setRenderPipelineState(planeRenderPipeline)
        enc.setVertexBuffer(groundPlane.mesh, offset: 0, at: 0)
        groundPlane.Draw(enc, offset: offset)
    }
    
    func drawMainPass(_ mainCommandBuffer: CommandBuffer, constantBuffer: GPUBufferHandle, mainPassOffset: Int, objectDataOffset: Int) {
        let currentFrame = frameCounter
        
        let enc = mainCommandBuffer.makeRenderCommandEncoder(handle: mainRenderPass, framebuffer: mainPassFramebuffer)
        enc.setDepthStencilState(depthTestLess)
        enc.setRasterizerState(mainRasterizerState)
        
        encodeMainPass(enc, constantBuffer: constantBuffer, passDataOffset : mainPassOffset, objectDataOffset: objectDataOffset)
        
        enc.endEncoding()
        
        let renderTarget = engine.acquireNextRenderTarget()
        finalFrameBuffer.colorAttachments[0].render = engine.textureForRenderTarget(handle: renderTarget)
        
        let finalEnc = mainCommandBuffer.makeRenderCommandEncoder(handle: finalRenderPass, framebuffer: finalFrameBuffer)
        
        finalEnc.setRenderPipelineState(texQuadVisPipeline)
        finalEnc.setFragmentTexture(mainPassFramebuffer.colorAttachments[0].render, at: 0)
        
        finalEnc.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        
        finalEnc.endEncoding()
        
        engine.present(commandBuffer: mainCommandBuffer, renderTarget: renderTarget)
        
        mainCommandBuffer.commit()
    }
}
