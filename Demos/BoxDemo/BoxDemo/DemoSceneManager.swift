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

import Shkadov

public final class DemoSceneManager : SceneManager, RawInputListener {
    // MARK: - SceneManager
    
    public func setUp() {
        setUpTextureRenderPipeline()
        setUpColorRenderPipeline()
        setUpRasterizationState()
        
        scene.cameraNode.localTransform.translation = Vector3D(0.0, 0.0, 10.0)
        scene.rootNode.addChildNode(scene.cameraNode)
        
        let axisCubes = createAxisCubes()
        
        for axisCube in axisCubes {
            scene.rootNode.addChildNode(axisCube)
        }

        scene.camera.projection.fovy = Angle(degrees: 30.0)
        scene.camera.projection.zNear = 0.5
        scene.camera.projection.zFar = 10000.0
        scene.update()
        scene.compile()
    }
    
    public func update() {
        let velocity = Vector3D(2.0 / 60.0)
        
        let rotateY = Quaternion.axis(Vector3D.xAxis, angle: pitch)
        let rotateX = Quaternion.axis(Vector3D.yAxis, angle: yaw)
        
        scene.cameraNode.localTransform.translation = scene.cameraNode.localTransform.translation + (rotateX * movementDirection() * velocity)
        scene.cameraNode.localTransform.rotation = rotateX * rotateY
        
        scene.update()
        
        let cameraPosition = scene.cameraNode.worldTransform.applyTo(Vector3D.zero)
        let downRay = Ray3D(origin: cameraPosition, direction: -Vector3D.yAxis)
        let collidingNodes = scene.potentiallyCollidingSceneNodes(downRay)
        var foundTriangles = [Triangle3D]()
        
        for node in collidingNodes {
            let collidingTriangles = node.collisionMesh.filter(downRay)
            foundTriangles.appendContentsOf(collidingTriangles)
        }
        
        let playerHeight = Float(2.0)
        let stepDistance = Float(1.0)
        var closestDistance = floatMax
        
        if !foundTriangles.isEmpty {
            for triangle in foundTriangles {
                let distance = downRay.distanceTo(triangle)
                
                if distance < closestDistance {
                    closestDistance = distance
                }
            }
        }
        else {
            closestDistance = playerHeight
        }
        
        var deltaHeight = playerHeight - closestDistance
        
        if deltaHeight < -playerHeight {
            deltaHeight = -stepDistance
        }
        else if deltaHeight > playerHeight {
            deltaHeight = stepDistance
        }
        
        scene.cameraNode.localTransform.translation = scene.cameraNode.localTransform.translation + (Vector3D.yAxis * deltaHeight)
        scene.update()
    }
    
    public func render() -> [Renderable] {
        return scene.generatePotentiallyVisibleRenderables()
    }
    
    public func updateViewport(viewport: Extent2D) {
        scene.camera.projection.aspectRatio = viewport.aspectRatio
    }
    
    // MARK: - RawInputListener
 
    public func receivedRawInput(rawInput: RawInput) {
        switch rawInput {
        case .ButtonDown(let buttonCode):
            logger.debug("BUTTON DOWN: \(buttonCode)")
            buttonDown.insert(buttonCode)
            
        case .ButtonUp(let buttonCode):
            logger.debug("BUTTON UP: \(buttonCode)")
            buttonDown.remove(buttonCode)
            
        case .JoystickAxis(let axis):
            logger.debug("JOYSTICK AXIS: \(axis)")
            
        case .KeyDown(let keyCode):
            logger.debug("KEY DOWN: \(keyCode)")
            keyDown.insert(keyCode)
            
        case .KeyUp(let keyCode):
            logger.debug("KEY UP: \(keyCode)")
            keyDown.remove(keyCode)
            
            if keyCode == .M {
                toggleMouseLook()
            }
            
        case .MousePosition(let position):
            logger.debug("MOUSE POSITION: \(position)")
            
        case .MouseDelta(let delta):
            logger.debug("MOUSE DELTA: \(delta)")
            if !mouseCursorManager.followsMouse {
                pitch += Angle(radians: delta.y * -0.001)
                yaw += Angle(radians: delta.x * -0.001)
            }
            
            if pitch < Angle(degrees: -89.9) {
                pitch = Angle(degrees: -89.9)
            }
            
            if pitch > Angle(degrees: 89.9) {
                pitch = Angle(degrees: 89.9)
            }
            
        case .ScrollDelta(let delta):
            logger.debug("SCROLL DELTA: \(delta)")
        }
    }
    
    // MARK: - Private
    
    private let mouseCursorManager: MouseCursorManager
    private let shaderLibrary: ShaderLibrary
    private let renderStateBuilder: RenderStateBuilder
    private let gpuMemory: GPUMemory
    private let boxGeometryBuilder: BoxGeometryBuilder
    private let renderer: Renderer
    private let logger: Logger
    private var scene: Scene
    
    private var textures: [String : Texture]
    
    private var textureRenderPipeline: RenderPipeline!
    private var colorRenderPipeline: RenderPipeline!
    private var rasterizationState: RasterizationState!
    private var sampler: Sampler!
    
    private var keyDown: Set<RawInputKeyCode>
    private var buttonDown: Set<RawInputButtonCode>
    private var pitch: Angle
    private var yaw: Angle
    
    private var addedBoundsDebug = false
    
    public init(mouseCursorManager: MouseCursorManager, shaderLibrary: ShaderLibrary, renderStateBuilder: RenderStateBuilder, gpuMemory: GPUMemory, renderer: Renderer, boxGeometryBuilder: BoxGeometryBuilder, logger: Logger) {
        self.mouseCursorManager = mouseCursorManager
        self.shaderLibrary = shaderLibrary
        self.renderStateBuilder = renderStateBuilder
        self.gpuMemory = gpuMemory
        self.renderer = renderer
        self.boxGeometryBuilder = boxGeometryBuilder
        self.logger = logger
        self.scene = Scene()
        self.textures = [String : Texture](minimumCapacity: 32)
        self.keyDown = Set<RawInputKeyCode>(minimumCapacity: 16)
        self.buttonDown = Set<RawInputButtonCode>(minimumCapacity: 16)
        self.pitch = Angle()
        self.yaw = Angle()
    }
    
    private func setUpTextureRenderPipeline() {
        let vertexShader = shaderLibrary.vertexShaderForName("litTexturedVertex")
        let fragmentShader = shaderLibrary.fragmentShaderForName("litTexturedFragment")
        let renderPipelineDescriptor = RenderPipelineDescriptor(
            vertexShader: vertexShader,
            vertexDescriptor: nil,
            fragmentShader: fragmentShader
        )
        textureRenderPipeline = renderStateBuilder.renderPipelineForDescriptor(renderPipelineDescriptor)
    }
    
    private func setUpRasterizationState() {
        let rasterizationStateDescriptor = RasterizationStateDescriptor(
            fillMode: .Fill,
            cullMode: .Back,
            frontFaceWinding: .CounterClockwise,
            depthClipMode: .Clip
        )
        rasterizationState = renderStateBuilder.rasterizationStateForDescriptor(rasterizationStateDescriptor)
    }
    
    private func setUpColorRenderPipeline() {
        let vertexShader = shaderLibrary.vertexShaderForName("colorVertex")
        let fragmentShader = shaderLibrary.fragmentShaderForName("colorFragment")
        let renderPipelineDescriptor = RenderPipelineDescriptor(
            vertexShader: vertexShader,
            vertexDescriptor: nil,
            fragmentShader: fragmentShader
        )
        colorRenderPipeline = renderStateBuilder.renderPipelineForDescriptor(renderPipelineDescriptor)
    }
    
    private func setUpSampler() {
        let samplerDescriptor = SamplerDescriptor(
            minFilter: .Linear,
            magFilter: .Linear,
            mipFilter: .Nearest,
            maxAnisotropy: 1,
            sAddressMode: .Repeat,
            tAddressMode: .Repeat,
            rAddressMode: .ClampToEdge,
            normalizedCoordinates: true,
            lodMinClamp: 0.0,
            lodMaxClamp: floatMax,
            compareFunction: .Never
        )
        sampler = renderStateBuilder.samplerForDescriptor(samplerDescriptor)
    }
    
    private func isKeyDown(keyCode: RawInputKeyCode) -> Bool {
        return keyDown.contains(keyCode)
    }
    
    private func isButtonDown(buttonCode: RawInputButtonCode) -> Bool {
        return buttonDown.contains(buttonCode)
    }
    
    private func toggleMouseLook() {
        mouseCursorManager.followsMouse = !mouseCursorManager.followsMouse
        mouseCursorManager.hidden = !mouseCursorManager.followsMouse
        
        if !mouseCursorManager.followsMouse {
            mouseCursorManager.moveToPoint(Vector2D(2560.0 * 0.5, 1080.0 * 0.5))
        }
    }
    
    private func movementDirection() -> Vector3D {
        var direction = Vector3D.zero
        
        if isKeyDown(.W) {
            // move forward
            direction.z += -1.0
        }
        
        if isKeyDown(.S) {
            // move backward
            direction.z += +1.0
        }
        
        if isKeyDown(.A) {
            // move left
            direction.x += -1.0
        }
        
        if isKeyDown(.D) {
            // move right
            direction.x += +1.0
        }
        
        if isKeyDown(.LSHIFT) {
            // move down
            direction.y += -1.0
        }
        
        if isKeyDown(.SPACE) {
            // move up
            direction.y += +1.0
        }
        
        if direction != Vector3D.zero {
            return normalize(direction)
        }
        else {
            return direction
        }
    }
    
    private func createAxisCubes() -> [StaticBasicSceneNode] {
        let cube = boxGeometryBuilder.unitFilledBox()
        let positions = [
            Vector3D(0.0, 0.0, 0.0),
            Vector3D(1.5, 0.0, 0.0),
            Vector3D(-1.5, 0.0, 0.0),
            Vector3D(0.0, 1.5, 0.0),
            Vector3D(0.0, -1.5, 0.0),
            Vector3D(0.0, 0.0, 1.5),
            Vector3D(0.0, 0.0, -1.5),
            ]
        
        let colors = [
            ColorRGBA8.white,
            ColorRGBA8.red,
            ColorRGBA8.magenta,
            ColorRGBA8.green,
            ColorRGBA8.yellow,
            ColorRGBA8.blue,
            ColorRGBA8.cyan,
            ]

        var nodes = [StaticBasicSceneNode]()
        nodes.reserveCapacity(positions.count)
        
        for (index, position) in positions.enumerate() {
            let node = createBasicSceneNode("Box\(index)", position: position, geometry: cube, color: colors[index], renderPipeline: colorRenderPipeline)
            nodes.append(node)
        }
        
        return nodes
    }
    
    private func createBasicSceneNode(name: String, position: Vector3D, geometry: Geometry, color: ColorRGBA8, renderPipeline: RenderPipeline) -> StaticBasicSceneNode {
        let uniformBuffer = gpuMemory.perFrameBufferWithSize(sizeof(ColorUniform), storageMode: .Shared)
        
        let vertexBufferBinding = BufferBinding(index: 0, buffer: geometry.vertexBuffer.data)
        let vertexUniformBinding = BufferBinding(index: 1, buffer: uniformBuffer)
        let vertexBindings = ShaderBindings(bufferBindings: [vertexBufferBinding, vertexUniformBinding], samplerBindings: [], textureBindings: [])
        
        let fragmentUniformBinding = BufferBinding(index: 0, buffer: uniformBuffer)
        let fragmentBindings = ShaderBindings(bufferBindings: [fragmentUniformBinding], samplerBindings: [], textureBindings: [])
        
        let indexedVertexDraw = geometry.indexBuffer.indexedVertexDrawWithInstaceCount(1)
        
        let renderable = Renderable(
            name: name,
            renderPipeline: renderPipeline,
            rasterizationState: rasterizationState,
            vertexBindings: vertexBindings,
            fragmentBindings: fragmentBindings,
            vertexDraws: [],
            indexedVertexDraws: [indexedVertexDraw]
        )
        let node = StaticBasicSceneNode(name: renderable.name, localTransform: Transform3D(translation: position), bounds: geometry.bounds, renderable: renderable, collisionMesh: geometry.collisionMesh, updateUniforms: { (projectionMatrix, viewMatrix, modelMatrix) -> Void in
            let modelViewMatrix = viewMatrix * modelMatrix
            let modelViewProjectionMatrix = projectionMatrix * modelViewMatrix
            let colorUniform = ColorUniform(modelViewProjectionMatrix: modelViewProjectionMatrix, color: color)
            let colorUniformBuffer = uniformBuffer.nextBuffer()
            let colorUniformPointer = UnsafeMutablePointer<ColorUniform>(colorUniformBuffer.sharedBuffer().data)
            colorUniformPointer.memory = colorUniform
        })
        return node
    }
}
