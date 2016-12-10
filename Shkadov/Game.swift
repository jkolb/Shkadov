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
import Dispatch

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
    private let metalQueue: CommandQueue
    
    let mainRP: RenderPassHandle
    var mainFrame = Framebuffer()
    
    var shadowRPs : Array<RenderPassHandle> = [RenderPassHandle]()
    var shadowFrames : Array<Framebuffer> = [Framebuffer]()
    var shadowMap : TextureHandle = TextureHandle()
    
    var mainPassDepthTexture : TextureHandle = TextureHandle()
    var mainPassFramebuffer : TextureHandle = TextureHandle()
    
    var depthTestLess : DepthStencilStateHandle = DepthStencilStateHandle()
    var depthTestAlways : DepthStencilStateHandle = DepthStencilStateHandle()
    
    var semaphore : DispatchSemaphore
    var dispatchQueue : DispatchQueue
    
    // Contains all our objects and metadata about them
    // We aren't doing any culling so that means we'll be drawing everything every frame
    var renderables : ContiguousArray<RenderableObject> = ContiguousArray<RenderableObject>()
    var groundPlane : StaticRenderableObject!
    
    // Constant buffer ring
    var constantBuffers : Array<GPUBufferHandle> = [GPUBufferHandle] ()
    var constantBufferSlot : Int = 0
    var frameCounter : UInt = 1
    
    // View and shadow cameras
    var camera  = ACamera()
    var shadowCameras : Array<ACamera> = [ACamera]()
    
    // Controls
    var moveForward = false
    var moveBackward = false
    var moveLeft = false
    var moveRight = false
    
    var orbit = float2()
    var cameraAngles = float2()
    
    var mouseDown = false
    
    var mouseDownPoint = Vector2<Float>()
    
    var drawLighting = true
    var drawShadowsOnCubes = false
    var multithreadedUpdate = false
    var multithreadedRender = false
    var objectsToRender = 10000
    
    // Render modes
    var depthTest = true
    var showDepthAndShadow = false
    
    // Per-pass constant data. View/projection matrices, etc
    var mainPassView = matrix_float4x4()
    var mainPassProjection = matrix_float4x4()
    var mainPassFrameData = MainPass()
    
    var shadowPassData = [ShadowPass]()
    
    // Our pipelines
    var unshadedPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    var unshadedShadowedPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    
    var litPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    var litShadowedPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    
    var planeRenderPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    var zpassPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    
    var quadVisPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    var depthVisPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    var texQuadVisPipeline: RenderPipelineStateHandle = RenderPipelineStateHandle()
    
    // Timing
    var machToMilliseconds: Double = 0.0
    var runningAverageGPU: Double = 0.0
    var runningAverageCPU: Double = 0.0
    
    var gpuTiming = [UInt64]()

    public init(engine: Engine, logger: Logger) {
        self.engine = engine
        self.logger = logger
        self.metalQueue = engine.makeCommandQueue()
        
        semaphore = DispatchSemaphore(value: MAX_FRAMES_IN_FLIGHT)
        dispatchQueue = DispatchQueue(label: "default queue", attributes: [.concurrent])
        
        var mainRPDesc = RenderPassDescriptor()
        mainRPDesc.colorAttachments.append(RenderPassColorAttachmentDescriptor())
        mainRPDesc.colorAttachments[0].clearColor = ClearColor(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
        mainRPDesc.colorAttachments[0].loadAction = .clear
        mainRPDesc.colorAttachments[0].storeAction = .store
        
        mainRPDesc.depthAttachment.clearDepth = 1.0
        mainRPDesc.depthAttachment.loadAction = .clear
        mainRPDesc.depthAttachment.storeAction = .dontCare
        mainRP = engine.createRenderPass(descriptor: mainRPDesc)
        
        mainPassView = matrix_identity_float4x4
        mainPassProjection = matrix_identity_float4x4
        
        mainPassFrameData.ViewProjection = matrix_multiply(mainPassProjection, mainPassView)
        
        camera.position = START_POSITION
        camera.direction = START_CAMERA_VIEW_DIR
        camera.up = START_CAMERA_UP_DIR
        
        // Set up shadow camera and data
        do
        {
            let c = ACamera()
            
            c.direction = SHADOWED_DIRECTIONAL_LIGHT_DIRECTION
            c.up = SHADOWED_DIRECTIONAL_LIGHT_UP
            c.position = SHADOWED_DIRECTIONAL_LIGHT_POSITION
            
            shadowCameras.append(c)
            
            shadowPassData.append(ShadowPass())
        }
        
        var timebase : mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&timebase)
        
        machToMilliseconds = Double(timebase.numer) / Double(timebase.denom) * 1e-6
        
        //add 3
        gpuTiming.append(0)
        gpuTiming.append(0)
        gpuTiming.append(0)
    }
    
    private func createPipelines() {
        var module = ModuleHandle()
        
        do {
            let modulePath = engine.pathForResource(named: "default.metallib")
            logger.debug("\(modulePath)")
            module = try engine.createModule(filepath: modulePath)
            
            // Shaders for lighting/shadowing
            let vertexFunction = engine.createVertexFunction(module: module, named: "vertex_main")
            let unshadedFragment = engine.createFragmentFunction(module: module, named: "unshaded_fragment")
            let unshadedShadowedFragment = engine.createFragmentFunction(module: module, named: "unshaded_shadowed_fragment")
            let planeVertex = engine.createVertexFunction(module: module, named: "plane_vertex")
            let planeFragment = engine.createFragmentFunction(module: module, named: "plane_fragment")
            
            var pipeDesc = RenderPipelineDescriptor()
            pipeDesc.vertexShader = vertexFunction
            pipeDesc.fragmentShader = unshadedFragment
            pipeDesc.colorAttachments.append(RenderPipelineColorAttachmentDescriptor())
            pipeDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipeDesc.depthAttachmentPixelFormat = .depth32Float
            
            try unshadedPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
            
            pipeDesc.fragmentShader = unshadedShadowedFragment
            try unshadedShadowedPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
            
            let litVertexFunction = engine.createVertexFunction(module: module, named: "lit_vertex")
            let litFragmentFunction = engine.createFragmentFunction(module: module, named: "lit_fragment")
            let litShadowedFragment = engine.createFragmentFunction(module: module, named: "lit_shadowed_fragment")
            
            // Rendering with simple lighting
            pipeDesc.vertexShader = litVertexFunction
            pipeDesc.fragmentShader = litFragmentFunction
            
            try litPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
            
            pipeDesc.fragmentShader = litShadowedFragment
            
            try litShadowedPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
            
            // Ground plane
            
            pipeDesc.vertexShader = planeVertex
            pipeDesc.fragmentShader = planeFragment
            try planeRenderPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
            
            // Shadow pass
            
            let zpassVertex = engine.createVertexFunction(module: module, named: "zpass_vertex_main")
            let zpassFragment = engine.createFragmentFunction(module: module, named: "zpass_fragment")
            
            //Z only passes do not need to write color
            pipeDesc.vertexShader = zpassVertex
            pipeDesc.fragmentShader = zpassFragment
            pipeDesc.colorAttachments[0].pixelFormat = .invalid
            pipeDesc.colorAttachments[0].writeMask = [] // MTLColorWriteMask()
            
            try zpassPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
        }
        catch {
            fatalError("Could not create lighting shaders, failing. \(error)")
        }
        
        do {
            // Visualization shaders
            let vertexFunction = engine.createVertexFunction(module: module, named: "quad_vertex_main")
            let quadVisFragFunction = engine.createFragmentFunction(module: module, named: "quad_fragment_main")
            let quadTexVisFunction = engine.createFragmentFunction(module: module, named: "textured_quad_fragment")
            let quadDepthVisFunction = engine.createFragmentFunction(module: module, named: "visualize_depth_fragment")
            
            var pipeDesc = RenderPipelineDescriptor()
            pipeDesc.vertexShader = vertexFunction
            pipeDesc.fragmentShader = quadVisFragFunction
            pipeDesc.colorAttachments.append(RenderPipelineColorAttachmentDescriptor())
            pipeDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            try quadVisPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
            
            pipeDesc.fragmentShader = quadDepthVisFunction
            try depthVisPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
            
            pipeDesc.fragmentShader = quadTexVisFunction
            try texQuadVisPipeline = engine.createRenderPipelineState(descriptor: pipeDesc)
        }
        catch {
            Swift.print("Could not compile visualization shaders, failing.")
            exit(1)
        }
    }

    public func didStartup() {
        logger.debug("\(#function)")
        // MARK: Constant Buffer Creation
        // Create our constant buffers
        // We've chosen 3 for this example; your application may need a different number
        for _ in 1...MAX_FRAMES_IN_FLIGHT {
            let buf = engine.createBuffer(count: CONSTANT_BUFFER_SIZE, storageMode: .unsafeSharedWithCPU)
            constantBuffers.append(buf)
        }
        
        // MARK: Shadow Texture Creation
        do {
            var texDesc : TextureDescriptor = TextureDescriptor()
            texDesc.pixelFormat = .depth32Float
            texDesc.width = SHADOW_DIMENSION
            texDesc.height = SHADOW_DIMENSION
            texDesc.depth = 1
            texDesc.textureType = .type2D
            texDesc.textureUsage = [.renderTarget, .shaderRead]
            texDesc.storageMode = .privateToGPU
            
            shadowMap = engine.createTexture(descriptor: texDesc)
        }
        
        // MARK: Main framebuffer / depth creation
        do {
            var texDesc = TextureDescriptor()
            texDesc.width =  Int(engine.config.renderer.width)
            texDesc.height =  Int(engine.config.renderer.height)
            texDesc.depth = 1
            texDesc.textureType = .type2D
            
            texDesc.textureUsage = [.renderTarget, .shaderRead]
            texDesc.storageMode = .privateToGPU
            texDesc.pixelFormat = .bgra8Unorm
            
            mainPassFramebuffer = engine.createTexture(descriptor: texDesc)
            
            mainFrame.colorAttachments.append(FramebufferAttachment())
            mainFrame.colorAttachments[0].render = mainPassFramebuffer
        }
        
        do {
            var texDesc = TextureDescriptor.texture2DDescriptor(pixelFormat: .depth32Float,
                                                                width: Int(engine.config.renderer.width),
                                                                height: Int(engine.config.renderer.height),
                                                                mipmapped: false)
            texDesc.textureUsage = [.renderTarget, .shaderRead]
            texDesc.storageMode = .privateToGPU
            mainPassDepthTexture = engine.createTexture(descriptor: texDesc)
            
            mainFrame.depthAttachment.render = mainPassDepthTexture
        }
        
        do {
            var rp = RenderPassDescriptor()
            rp.depthAttachment.clearDepth = 1.0
            rp.depthAttachment.loadAction = .clear
            rp.depthAttachment.storeAction = .store
            
            shadowRPs.append(engine.createRenderPass(descriptor: rp))
            
            var f = Framebuffer()
            f.depthAttachment.render = shadowMap
            shadowFrames.append(f)
        }
        
        // MARK: Depth State Creation
        
        do {
            var depthStencilDesc = DepthStencilDescriptor()
            depthStencilDesc.isDepthWriteEnabled = true
            depthStencilDesc.depthCompareFunction = .less
            
            depthTestLess = engine.createDepthStencilState(descriptor: depthStencilDesc)
            
            depthStencilDesc.isDepthWriteEnabled = false
            depthStencilDesc.depthCompareFunction = .always
            depthTestAlways = engine.createDepthStencilState(descriptor: depthStencilDesc)
        }
        
        // MARK: Shader Creation
        
        createPipelines()
        
        // MARK: Object Creation
        do {
            let (geo, index, indexCount, vertCount) = createCube(engine)
            
            for _ in 0..<OBJECT_COUNT {
                //NOTE returns a value within -value to value
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
            let (planeGeo, count) = createPlane(engine)
            groundPlane = StaticRenderableObject(m: planeGeo, idx: GPUBufferHandle(), count: count, tex: TextureHandle())
            groundPlane.position = float4(GROUND_POSITION.x,
                                           GROUND_POSITION.y,
                                           GROUND_POSITION.z,1.0)
            groundPlane.objectData.color = GROUND_COLOR
            groundPlane.objectData.LocalToWorld.columns.3 = groundPlane.position
        }
        
        // Main pass projection matrix
        // Our window cannot change size so we don't ever update this
        mainPassProjection = getPerpectiveProjectionMatrix(Float(60.0*DEG2RAD), aspectRatio: Float(engine.config.renderer.width) / Float(engine.config.renderer.height), zFar: 2000.0, zNear: 1.0)
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
    }
    
    func encodeShadowPass(_ commandBuffer: CommandBuffer, rp: RenderPassHandle, fb: Framebuffer, constantBuffer: GPUBufferHandle, passDataOffset: Int, objectDataOffset: Int) {
        let enc = commandBuffer.makeRenderCommandEncoder(handle: rp, framebuffer: fb)
        enc.setDepthStencilState(depthTestLess)
        
        //We're only going to draw back faces into the shadowmap
//        enc.setCullMode(.front)
        
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
            offset += MemoryLayout<ObjectData>.size
        }
        
        enc.endEncoding()
        
        commandBuffer.commit()
    }
    
    func encodeMainPass(_ enc: RenderCommandEncoder, constantBuffer: GPUBufferHandle, passDataOffset: Int, objectDataOffset: Int) {
        // Similar to the shadow passes, we must bind the constant buffer once before we call setVertexBytes
        enc.setVertexBuffer(constantBuffer, offset: 0, at: 1)
        enc.setFragmentBuffer(constantBuffer, offset: 0, at: 1)
        
        // Now bind the MainPass constants once
        enc.setVertexBuffer(constantBuffer, offset: passDataOffset, at: 2)
        enc.setFragmentBuffer(constantBuffer, offset: passDataOffset, at: 2)
        
        enc.setFragmentTexture(shadowMap, at: 0)
        
        var offset = objectDataOffset
        if drawShadowsOnCubes {
            if drawLighting {
                enc.setRenderPipelineState(litShadowedPipeline)
            }
            else {
                enc.setRenderPipelineState(unshadedShadowedPipeline)
            }
        }
        else {
            if drawLighting {
                enc.setRenderPipelineState(litPipeline)
            }
            else {
                enc.setRenderPipelineState(unshadedPipeline)
            }
        }
        
        enc.setVertexBuffer(renderables[0].mesh, offset: 0, at: 0)
        for index in 0..<objectsToRender {
            renderables[index].Draw(enc, offset: offset)
            offset += MemoryLayout<ObjectData>.size
        }
        
        enc.setRenderPipelineState(planeRenderPipeline)
        enc.setVertexBuffer(groundPlane.mesh, offset: 0, at: 0)
        groundPlane.Draw(enc, offset: offset)
    }
    
    func drawMainPass(_ mainCommandBuffer: CommandBuffer, constantBuffer: GPUBufferHandle, mainPassOffset: Int, objectDataOffset: Int) {
        let currentFrame = frameCounter
        
        if showDepthAndShadow {
            mainRPDesc.depthAttachment.storeAction = .store
        }
        else {
            mainRPDesc.depthAttachment.storeAction = .dontCare
        }
        
        let enc : RenderCommandEncoder = mainCommandBuffer.makeRenderCommandEncoder(descriptor: mainRPDesc)
        enc.setCullMode(MTLCullMode.back)
        
        if depthTest {
            enc.setDepthStencilState(depthTestLess)
        }
        
        encodeMainPass(enc, constantBuffer: constantBuffer, passDataOffset : mainPassOffset, objectDataOffset: objectDataOffset)
        
        enc.endEncoding()
        
        let currentDrawable = self.currentDrawable!
        let rpDesc = currentRenderPassDescriptor!
        
        // Draws the Scene, Depth and Shadow map to the screen
        if showDepthAndShadow {
            let visEnc = mainCommandBuffer.makeRenderCommandEncoder(descriptor: rpDesc)
            
            var viewport = MTLViewport(originX: 0.0, originY: 0.0,
                                       width: Double(frame.width)*0.5,
                                       height: Double(frame.height)*0.5,
                                       znear: 0.0, zfar: 1.0)
            
            visEnc.setViewport(viewport)
            
            visEnc.setRenderPipelineState(texQuadVisPipeline!)
            visEnc.setFragmentTexture(mainPassFramebuffer, at: 0)
            
            visEnc.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 4)
            
            viewport = MTLViewport(originX: Double(frame.width)*0.5, originY: 0.0,
                                   width: Double(frame.width)*0.5,
                                   height: Double(frame.height)*0.5,
                                   znear: 0.0, zfar: 1.0)
            
            visEnc.setViewport(viewport)
            
            visEnc.setRenderPipelineState(self.depthVisPipeline!)
            visEnc.setFragmentTexture(self.mainPassDepthTexture, at: 0)
            
            visEnc.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 4)
            
            // Shadow
            viewport = MTLViewport(originX: 0.0,
                                   originY: Double(frame.height)*0.5,
                                   width: Double(frame.width)*0.5,
                                   height: Double(frame.height)*0.5,
                                   znear: 0.0, zfar: 1.0)
            
            visEnc.setViewport(viewport)
            
            visEnc.setFragmentTexture(shadowMap, at: 0)
            visEnc.drawPrimitives(type: MTLPrimitiveType.triangleStrip, vertexStart: 0, vertexCount: 4)
            
            visEnc.endEncoding()
        }
        else {
            // Draws the main pass
            let finalEnc = mainCommandBuffer.makeRenderCommandEncoder(descriptor: rpDesc)
            
            finalEnc.setRenderPipelineState(texQuadVisPipeline!)
            finalEnc.setFragmentTexture(mainPassFramebuffer, at: 0)
            
            finalEnc.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            
            finalEnc.endEncoding()
        }
        
        mainCommandBuffer.present(currentDrawable)
        
        mainCommandBuffer.addScheduledHandler { scheduledCommandBuffer in
            self.gpuTiming[Int(currentFrame % 3)] = mach_absolute_time()
        }
        
        mainCommandBuffer.addCompletedHandler { completedCommandBuffer in
            
            let end = mach_absolute_time()
            self.gpuTiming[Int(currentFrame % 3)] = end - self.gpuTiming[Int(currentFrame % 3)]
            
            let seconds = self.machToMilliseconds * Double(self.gpuTiming[Int(currentFrame % 3)])
            
            self.runningAverageGPU = (self.runningAverageGPU * Double(currentFrame-1) + seconds) / Double(currentFrame)
            
            self.semaphore.signal()
        }
        
        mainCommandBuffer.commit()
    }
}
