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
    private let mouseCursorManager: MouseCursorManager
    private let assetManager: AssetManager
    private let shaderLibrary: ShaderLibrary
    private let renderStateBuilder: RenderStateBuilder
    private let gpuMemory: GPUMemory
    private let boxGeometryBuilder: BoxGeometryBuilder
    private let renderer: Renderer
    private let logger: Logger
    private var scene: Scene
    
    private var textures: [String : Texture]
    
    private var renderPipeline: RenderPipeline!
    private var lineRenderPipeline: RenderPipeline!
    private var rasterizationState: RasterizationState!
    private var sampler: Sampler!
    
    private var keyDown: Set<RawInputKeyCode>
    private var buttonDown: Set<RawInputButtonCode>
    private var pitch: Angle
    private var yaw: Angle
    
    private var addedBoundsDebug = false
    
    public init(mouseCursorManager: MouseCursorManager, assetManager: AssetManager, shaderLibrary: ShaderLibrary, renderStateBuilder: RenderStateBuilder, gpuMemory: GPUMemory, renderer: Renderer, boxGeometryBuilder: BoxGeometryBuilder, logger: Logger) {
        self.mouseCursorManager = mouseCursorManager
        self.assetManager = assetManager
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
    
    private func setUpRenderPipeline() {
        let vertexShader = shaderLibrary.vertexShaderForName("litTexturedVertex")
        let fragmentShader = shaderLibrary.fragmentShaderForName("litTexturedFragment")
        let renderPipelineDescriptor = RenderPipelineDescriptor(
            vertexShader: vertexShader,
            vertexDescriptor: nil,
            fragmentShader: fragmentShader
        )
        renderPipeline = renderStateBuilder.renderPipelineForDescriptor(renderPipelineDescriptor)
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
    
    private func setUpLineRenderPipeline() {
        let vertexShader = shaderLibrary.vertexShaderForName("lineVertex")
        let fragmentShader = shaderLibrary.fragmentShaderForName("lineFragment")
        let renderPipelineDescriptor = RenderPipelineDescriptor(
            vertexShader: vertexShader,
            vertexDescriptor: nil,
            fragmentShader: fragmentShader
        )
        lineRenderPipeline = renderStateBuilder.renderPipelineForDescriptor(renderPipelineDescriptor)
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
    
    private func toggleMouseLook() {
        mouseCursorManager.followsMouse = !mouseCursorManager.followsMouse
        mouseCursorManager.hidden = !mouseCursorManager.followsMouse
        
        if !mouseCursorManager.followsMouse {
            mouseCursorManager.moveToPoint(Vector2D(2560.0 * 0.5, 1080.0 * 0.5))
        }
    }
    
    public func setUp() {
        loadTextures()
        generateMipmaps()
        
        setUpRenderPipeline()
        setUpLineRenderPipeline()
        setUpRasterizationState()
        setUpSampler()
        
        loadSkyDome()
        loadTerrain()
        loadMainGate()
        loadMainGate01()
        loadWall01()
        loadWall02()
        loadFrontHall()
        loadExterior()
        loadDrawBridge()
        loadCylinder02()
        loadBridge()
        loadWallTurrent02()
        loadWallTurrent01()
        loadQuadPatch01()
        loadFrontRamp()
        
        let forward = Quaternion.axis(Vector3D.yAxis, angle: Angle(degrees: -90.0))
        let up = Quaternion.axis(Vector3D.xAxis, angle: Angle(degrees: 90.0))
        let cameraAlignment = Transform3D(
            scale: Vector3D(1.0),
            rotation: up * forward,
            translation: Vector3D(528.771825, 85.29845595, 69.9973)
        )
        let cameraAlignmentNode = StaticGroupSceneNode(name: "CameraAlignment", localTransform: cameraAlignment)
        
        cameraAlignmentNode.addChildNode(scene.cameraNode)
        scene.rootNode.addChildNode(cameraAlignmentNode)
        
        scene.camera.projection.fovy = Angle(degrees: 30.0)
        scene.camera.projection.zNear = 0.5
        scene.camera.projection.zFar = 10000.0
        scene.update()
        scene.compile()
    }
    
    public func update() {
        let velocity = Vector3D(40.0/60.0)
        
        let rotateY = Quaternion.axis(Vector3D.xAxis, angle: pitch)
        let rotateX = Quaternion.axis(Vector3D.yAxis, angle: yaw)
        
        scene.cameraNode.localTransform.translation = scene.cameraNode.localTransform.translation + (rotateX * movementDirection() * velocity)
        scene.cameraNode.localTransform.rotation = rotateX * rotateY
        
        scene.update()
        
        let cameraPosition = scene.cameraNode.worldTransform.applyTo(Vector3D.zero)
        let downRay = Ray3D(origin: cameraPosition, direction: -Vector3D.zAxis)
        let collidingNodes = scene.potentiallyCollidingSceneNodes(downRay)
        //        print(collidingNodes.map({ $0.name }))
        var foundTriangles = [Triangle3D]()
        
        for node in collidingNodes {
            let collidingTriangles = node.collisionMesh.filter(downRay)
            
            //            if !collidingTriangles.isEmpty {
            //                print("\(node.name) @ \(collidingTriangles)")
            //            }
            
            foundTriangles.appendContentsOf(collidingTriangles)
        }
        
        let playerHeight = Float(6.0)
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
        
        //        if !addedBoundsDebug {
        //            addedBoundsDebug = true
        //            var nodeStack = [SceneNode]()
        //            nodeStack.append(mainNode)
        //
        //            while !nodeStack.isEmpty {
        //                let worldNode = nodeStack.popLast()!
        //
        //                if !worldNode.worldBounds.isNull {
        //                    let worldBox = worldNode.worldBounds.asAxisAlignedBoundingBox()
        //                    let worldBoxNode = createNodeForBox(worldBox, color: ColorRGBA8(red: 255, green: 0, blue: 0))
        //                    worldNode.parent?.addChildNode(worldBoxNode)
        //
        //                    if let node = worldNode as? BasicSceneNode {
        //                        let localBox = node.localBounds.asAxisAlignedBoundingBox()
        //                        let localBoxNode = createNodeForBox(localBox, color: ColorRGBA8(red: 0, green: 255, blue: 0))
        //                        localBoxNode.localTransform = node.localTransform
        //                        node.parent?.addChildNode(localBoxNode)
        //                    }
        //                }
        //
        //                for child in worldNode.children {
        //                    nodeStack.append(child)
        //                }
        //            }
        //        }
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
    
    public func render() -> [Renderable] {
        return scene.generatePotentiallyVisibleRenderables()
    }
    
    public func updateViewport(viewport: Extent2D) {
        scene.camera.projection.aspectRatio = viewport.aspectRatio
    }
    
    private func loadTextures() {
        loadTextureWithName("barrel")
        loadTextureWithName("gravel01")
        loadTextureWithName("gravel02")
        loadTextureWithName("gravel_corner_se")
        loadTextureWithName("gravel_corner_ne")
        loadTextureWithName("gravel_corner_nw")
        loadTextureWithName("gravel_corner_sw")
        loadTextureWithName("stone01")
        loadTextureWithName("stone02")
        loadTextureWithName("stone03")
        loadTextureWithName("gravel_cap_ne")
        loadTextureWithName("gravel_cap_nw")
        loadTextureWithName("gravel_side_s")
        loadTextureWithName("gravel_side_n")
        loadTextureWithName("gravel_side_w")
        loadTextureWithName("largestone01")
        loadTextureWithName("largerstone01")
        loadTextureWithName("largerstone02")
        loadTextureWithName("largeststone01")
        loadTextureWithName("largeststone02")
        loadTextureWithName("hugestone01")
        loadTextureWithName("hugestone02")
        loadTextureWithName("skyline")
        loadTextureWithName("outwall03")
        loadTextureWithName("wall02")
        loadTextureWithName("steps")
        loadTextureWithName("door")
        loadTextureWithName("floor02")
        loadTextureWithName("woodceiling")
        loadTextureWithName("keystone")
        loadTextureWithName("rooftemp")
        loadTextureWithName("tileplanks")
        loadTextureWithName("ramp03")
    }
    
    private func generateMipmaps() {
        renderer.generateMipmapsForTextures(Array(textures.values))
    }
    
    private func loadTextureWithName(name: String) {
        let texture = try! assetManager.loadImageTextureForName(name)
        textures[name] = texture
    }
    
    private func textureWithName(name: String) -> Texture {
        return textures[name]!
    }
    
    private func loadSkyDome() {
        let localTransform = Transform3D(
            translation: Vector3D(0.0, 0.0, 200.0)
        )
        let node = createPNT1NodeWithMeshName("SkyDome", textureName: "skyline", localTransform: localTransform)
        scene.rootNode.addChildNode(node)
    }
    
    private func loadTerrain() {
        let localTransform = Transform3D(
            translation: Vector3D(1696.189697, -59.821838, 0.5)
        )
        let terrainNode = StaticGroupSceneNode(name: "TerrainRoot", localTransform: localTransform)
        scene.rootNode.addChildNode(terrainNode)
        
        let meshes = try! assetManager.loadMultipleMeshPNT1("Terrain")
        let textureNames = [
            "gravel01",
            "gravel02",
            "gravel_corner_se",
            "gravel_corner_ne",
            "stone01",
            "gravel_cap_ne",
            "stone02",
            "stone03",
            "gravel_side_s",
            "largestone01",
            "largerstone01",
            "largerstone02",
            "largeststone01",
            "largeststone02",
            "hugestone01",
            "hugestone02",
            "gravel_cap_nw",
            "gravel_side_n",
            "gravel_corner_nw",
            "gravel_side_w",
            "gravel_corner_sw",
            ]
        for (index, mesh) in meshes.enumerate() {
            let meshNode = createPNT1NodeWithMesh("Terrain", mesh: mesh, textureName: textureNames[index])
            terrainNode.addChildNode(meshNode)
        }
    }
    
    private func loadFrontHall() {
        var localTransform = Transform3D()
        localTransform.translation = Vector3D(1616.844116, -59.090065, 0.0)
        localTransform.scale = Vector3D(0.083333)
        
        let angle = Angle(degrees: 0.000004)
        let rotate0 = Quaternion.axis(Vector3D.zAxis, angle: angle)
        let rotate1 = Quaternion.axis(Vector3D.xAxis, angle: -angle)
        
        localTransform.rotation = rotate0 * rotate1
        
        let meshes = try! assetManager.loadMultipleMeshPNT1("FrontHall")
        let textureNames = [
            "wall02",
            "steps",
            "outwall03",
            "door",
            "floor02",
            "woodceiling",
            "keystone",
            ]
        for (index, mesh) in meshes.enumerate() {
            let meshNode = createPNT1NodeWithMesh("FrontHall", mesh: mesh, textureName: textureNames[index], localTransform: localTransform)
            scene.rootNode.addChildNode(meshNode)
        }
    }
    
    private func loadFrontRamp() {
        var localTransform = Transform3D()
        localTransform.translation = Vector3D(1616.844116, -59.090065, 0.0)
        localTransform.scale = Vector3D(0.083333)
        
        let angle = Angle(degrees: 0.000004)
        let rotate0 = Quaternion.axis(Vector3D.zAxis, angle: angle)
        let rotate1 = Quaternion.axis(Vector3D.xAxis, angle: -angle)
        
        localTransform.rotation = rotate0 * rotate1
        
        let meshes = try! assetManager.loadMultipleMeshPNT1("FrontRamp")
        let textureNames = [
            "outwall03",
            "rooftemp",
            "ramp03",
            "keystone",
            "wall02",
            "steps",
            "outwall03",
            ]
        for (index, mesh) in meshes.enumerate() {
            let meshNode = createPNT1NodeWithMesh("FrontRamp", mesh: mesh, textureName: textureNames[index], localTransform: localTransform)
            scene.rootNode.addChildNode(meshNode)
        }
    }
    
    private func loadExterior() {
        var localTransform = Transform3D()
        localTransform.translation = Vector3D(1616.844116, -59.090065, 0.000023)
        localTransform.scale = Vector3D(0.083333)
        
        let angle = Angle(degrees: 0.000004)
        let rotate0 = Quaternion.axis(Vector3D.zAxis, angle: angle)
        
        localTransform.rotation = rotate0
        
        let meshes = try! assetManager.loadMultipleMeshPNT1("Exterior")
        let textureNames = [
            "outwall03",
            "rooftemp",
            ]
        for (index, mesh) in meshes.enumerate() {
            let meshNode = createPNT1NodeWithMesh("Exterior", mesh: mesh, textureName: textureNames[index], localTransform: localTransform)
            scene.rootNode.addChildNode(meshNode)
        }
    }
    
    private func loadCylinder02() {
        var localTransform = Transform3D()
        localTransform.translation = Vector3D(1779.677124, -154.748062, 119.166679)
        localTransform.scale = Vector3D(0.083333)
        
        let angle = Angle(degrees: 0.000004)
        let rotate0 = Quaternion.axis(Vector3D.zAxis, angle: angle)
        let rotate1 = Quaternion.axis(Vector3D.xAxis, angle: -angle)
        
        localTransform.rotation = rotate0 * rotate1
        
        let meshes = try! assetManager.loadMultipleMeshPNT1("Cylinder02")
        let textureNames = [
            "ramp03",
            "rooftemp",
            ]
        for (index, mesh) in meshes.enumerate() {
            let meshNode = createPNT1NodeWithMesh("Cylinder02", mesh: mesh, textureName: textureNames[index], localTransform: localTransform)
            scene.rootNode.addChildNode(meshNode)
        }
    }
    
    private func loadQuadPatch01() {
        let localTransform = Transform3D(
            translation: Vector3D(2127.324951, -844.650757, 0.000023),
            scale: Vector3D(0.083333)
        )
        let node = createPNT1NodeWithMeshName("QuadPatch01", textureName: "stone01", localTransform: localTransform)
        scene.rootNode.addChildNode(node)
    }
    
    private func loadWallTurrent02() {
        let localTransform = Transform3D(
            translation: Vector3D(1538.876343, -309.239685, 0.000023),
            scale: Vector3D(0.083333)
        )
        let node = createPNT1NodeWithMeshName("WallTurret02", textureName: "outwall03", localTransform: localTransform)
        scene.rootNode.addChildNode(node)
    }
    
    private func loadWallTurrent01() {
        let localTransform = Transform3D(
            translation: Vector3D(1539.422119, 184.323593, 0.000023),
            scale: Vector3D(0.083333)
        )
        let node = createPNT1NodeWithMeshName("WallTurret01", textureName: "outwall03", localTransform: localTransform)
        scene.rootNode.addChildNode(node)
    }
    
    private func loadBridge() {
        let localTransform = Transform3D(
            translation: Vector3D(1277.351440, -62.214615, -108.688896),
            rotation: Quaternion.axis(Vector3D.zAxis, angle: Angle(degrees: 90.0)),
            scale: Vector3D(0.140000, 0.176400, 0.140000)
        )
        let node = createPNT1NodeWithMeshName("Bridge", textureName: "outwall03", localTransform: localTransform)
        scene.rootNode.addChildNode(node)
    }
    
    private func loadDrawBridge() {
        let parentTransform = Transform3D(
            translation: Vector3D(1474.214722, -62.328590, 0.0),
            scale: Vector3D(0.083333)
        )
        let parentNode = StaticGroupSceneNode(name: "DrawBridgeRoot", localTransform: parentTransform)
        scene.rootNode.addChildNode(parentNode)
        
        let localTransform = Transform3D(
            translation: Vector3D(-623.466858, 0.000000, -35.999718)
        )
        let node = createPNT1NodeWithMeshName("DrawBridge", textureName: "tileplanks", localTransform: localTransform)
        parentNode.addChildNode(node)
    }
    
    private func loadMainGate01() {
        let localTransform = Transform3D(
            translation: Vector3D(1174.400269, -62.375893, 0.000023),
            scale: Vector3D(0.083333)
        )
        let node = createPNT1NodeWithMeshName("MainGate01", textureName: "outwall03", localTransform: localTransform)
        scene.rootNode.addChildNode(node)
    }
    
    private func loadMainGate() {
        let localTransform = Transform3D(
            translation: Vector3D(1494.214722, -62.375893, 0.000023),
            scale: Vector3D(0.083333)
        )
        let node = createPNT1NodeWithMeshName("MainGate", textureName: "outwall03", localTransform: localTransform)
        scene.rootNode.addChildNode(node)
    }
    
    public func loadWall01() {
        let parentTransform = Transform3D(
            translation: Vector3D(1482.001709, -12.375895, 0.000023),
            scale: Vector3D(0.083333)
        )
        let parentNode = StaticGroupSceneNode(name: "Wall01Root", localTransform: parentTransform)
        scene.rootNode.addChildNode(parentNode)
        
        let localTransform = Transform3D(
            translation: Vector3D(0.0, 1188.0, 0.0)
        )
        let node = createPNT1NodeWithMeshName("Wall01", textureName: "outwall03", localTransform: localTransform)
        parentNode.addChildNode(node)
    }
    
    public func loadWall02() {
        let parentTransform = Transform3D(
            translation: Vector3D(1482.001709, -112.375885, 0.000023),
            scale: Vector3D(0.083333)
        )
        let parentNode = StaticGroupSceneNode(name: "Wall02Root", localTransform: parentTransform)
        scene.rootNode.addChildNode(parentNode)
        
        let localTransform = Transform3D(
            translation: Vector3D(0.0, -1188.0, 0.0)
        )
        let node = createPNT1NodeWithMeshName("Wall02", textureName: "outwall03", localTransform: localTransform)
        parentNode.addChildNode(node)
    }
    
    private func createPNT1NodeWithMeshName(meshName: String, textureName: String, localTransform: Transform3D = Transform3D()) -> StaticBasicSceneNode {
        let mesh = try! assetManager.loadMeshPNT1(meshName)
        return createPNT1NodeWithMesh(meshName, mesh: mesh, textureName: textureName, localTransform: localTransform)
    }
    
    private func createPNT1NodeWithMesh(meshName: String, mesh: Geometry, textureName: String, localTransform: Transform3D = Transform3D()) -> StaticBasicSceneNode {
        let uniformBuffer = gpuMemory.perFrameBufferWithSize(sizeof(LitUniform), storageMode: .Shared)
        
        let vertexBufferBinding = BufferBinding(index: 0, buffer: mesh.vertexBuffer.data)
        let vertexUniformBinding = BufferBinding(index: 1, buffer: uniformBuffer)
        let vertexBindings = ShaderBindings(bufferBindings: [vertexBufferBinding, vertexUniformBinding], samplerBindings: [], textureBindings: [])
        
        let samplerBinding = SamplerBinding(index: 0, sampler: sampler)
        let texture = textureWithName(textureName)
        let textureBinding = TextureBinding(index: 0, texture: texture)
        let fragmentBindings = ShaderBindings(bufferBindings: [], samplerBindings: [samplerBinding], textureBindings: [textureBinding])
        
        let indexedVertexDraw = mesh.indexBuffer.indexedVertexDrawWithInstaceCount(1)
        
        let renderable = Renderable(
            name: "\(meshName)+\(textureName)",
            renderPipeline: renderPipeline,
            rasterizationState: rasterizationState,
            vertexBindings: vertexBindings,
            fragmentBindings: fragmentBindings,
            vertexDraws: [],
            indexedVertexDraws: [indexedVertexDraw]
        )
        let meshNode = StaticBasicSceneNode(name: renderable.name, localTransform: localTransform, bounds: mesh.bounds, renderable: renderable, collisionMesh: mesh.collisionMesh, updateUniforms: { (projectionMatrix, viewMatrix, modelMatrix) -> Void in
            let modelViewMatrix = viewMatrix * modelMatrix
            let normalMatrix = modelViewMatrix.matrix3x3
            let modelViewProjectionMatrix = projectionMatrix * modelViewMatrix
            let litUniformBuffer = uniformBuffer.nextBuffer()
            let litUniformPointer = UnsafeMutablePointer<LitUniform>(litUniformBuffer.sharedBuffer().data)
            litUniformPointer.initialize(LitUniform(modelViewProjectionMatrix: modelViewProjectionMatrix, normalMatrix: normalMatrix))
        })
        return meshNode
    }
    
    private func createNodeForBox(box: AABB, color: ColorRGBA8) -> StaticBasicSceneNode {
        let mesh = boxGeometryBuilder.outlineBox(width: box.radius.x, height: box.radius.y, depth: box.radius.z)
        
        let uniformBuffer = gpuMemory.perFrameBufferWithSize(sizeof(ColorUniform), storageMode: .Shared)
        
        let vertexBufferBinding = BufferBinding(index: 0, buffer: mesh.vertexBuffer.data)
        let vertexUniformBinding = BufferBinding(index: 1, buffer: uniformBuffer)
        let vertexBindings = ShaderBindings(bufferBindings: [vertexBufferBinding, vertexUniformBinding], samplerBindings: [], textureBindings: [])
        
        let fragmentUniformBinding = BufferBinding(index: 0, buffer: uniformBuffer)
        let fragmentBindings = ShaderBindings(bufferBindings: [fragmentUniformBinding], samplerBindings: [], textureBindings: [])
        
        let indexedVertexDraw = mesh.indexBuffer.indexedVertexDrawWithInstaceCount(1)
        
        let renderable = Renderable(
            name: "\(box)",
            renderPipeline: lineRenderPipeline,
            rasterizationState: rasterizationState,
            vertexBindings: vertexBindings,
            fragmentBindings: fragmentBindings,
            vertexDraws: [],
            indexedVertexDraws: [indexedVertexDraw]
        )
        let meshNode = StaticBasicSceneNode(name: renderable.name, bounds: mesh.bounds, renderable: renderable, collisionMesh: mesh.collisionMesh, updateUniforms: { (projectionMatrix, viewMatrix, modelMatrix) -> Void in
            let modelViewMatrix = viewMatrix * modelMatrix
            let modelViewProjectionMatrix = projectionMatrix * modelViewMatrix
            let colorUniform = ColorUniform(modelViewProjectionMatrix: modelViewProjectionMatrix, color: color)
            let colorUniformBuffer = uniformBuffer.nextBuffer()
            let colorUniformPointer = UnsafeMutablePointer<ColorUniform>(colorUniformBuffer.sharedBuffer().data)
            colorUniformPointer.memory = colorUniform
        })
        return meshNode
    }
}
