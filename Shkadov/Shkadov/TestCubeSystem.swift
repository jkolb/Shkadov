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

import simd

public class TestCubeSystem {
    private let renderer: Renderer
    private let assetLoader: AssetLoader
    private let entityComponents: EntityComponents
    private var program: Handle = Handle.invalid
    private var vertexArray: Handle = Handle.invalid
    private var uniformBuffer: Handle = Handle.invalid
    private var texture: Handle = Handle.invalid
    private var cubes: [Entity] = []
    
    public init(renderer: Renderer, assetLoader: AssetLoader, entityComponents: EntityComponents) {
        self.renderer = renderer
        self.assetLoader = assetLoader
        self.entityComponents = entityComponents
    }
    
    deinit {
        renderer.destroyProgram(program)
        renderer.destoryVertexArray(vertexArray)
    }
    
    public func configure() {
        var vertexDescriptor = VertexDescriptor()
        vertexDescriptor.addAttribute(.Position, format: .Float3)
        vertexDescriptor.addAttribute(.Normal, format: .Float3)
        vertexDescriptor.addAttribute(.TexCoord, format: .Float2)
        
        let grassTextureData = assetLoader.loadTextureData(assetLoader.pathToFile("Assets/grass_top.png"))
        texture = renderer.createTextureFromData(grassTextureData)

        let mesh = Mesh3D.cubeWithSize(1.0)
        let meshData = mesh.createBufferForVertexDescriptor(vertexDescriptor)
        
        program = renderer.createProgramWithVertexPath("passThroughVertex", fragmentPath: "passThroughFragment")
        vertexArray = renderer.createVertexArrayFromDescriptor(vertexDescriptor, buffer: meshData)
        
        let positions = [
            float3(0.0, 0.0, 0.0),
            float3(1.5, 0.0, 0.0),
            float3(-1.5, 0.0, 0.0),
            float3(0.0, 1.5, 0.0),
            float3(0.0, -1.5, 0.0),
            float3(0.0, 0.0, 1.5),
            float3(0.0, 0.0, -1.5),
        ]
        
        let colors = [
            Color.white,
            Color.red,
            Color.magenta,
            Color.green,
            Color.yellow,
            Color.blue,
            Color.cyan,
        ]
        
        let uniformSize = max(256, strideof(float4x4) + strideof(float4x4) + strideof(float4))
        uniformBuffer = renderer.createBufferWithName("Cube Uniforms", length: positions.count * uniformSize)
        var uniformOffset = 0
        
        for index in 0..<positions.count {
            let cube = entityComponents.createEntity()
            entityComponents.addComponent(OrientationComponent(position: positions[index]), toEntity: cube)
            entityComponents.addComponent(RenderComponent(uniformBuffer: uniformBuffer, uniformOffset: uniformOffset, diffuseColor: colors[index]), toEntity: cube)
            uniformOffset += uniformSize
            cubes.append(cube)
        }
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
        let updateAmount: Float = 0.01
        
        for cube in cubes {
            let oldOrientation = entityComponents.componentForEntity(cube, withComponentType: OrientationComponent.self)!
            let newOrientation = OrientationComponent(
                position: oldOrientation.position,
                pitch: oldOrientation.pitch + Angle(radians: updateAmount),
                yaw: oldOrientation.yaw + Angle(radians: updateAmount)
            )
            
            entityComponents.replaceComponent(newOrientation, forEntity: cube)
        }
    }
    
    public func render() -> RenderState {
        var objects = [RenderComponent]()
        
        for cube in cubes {
            let renderObject = entityComponents.componentForEntity(cube, withComponentType: RenderComponent.self)!
            objects.append(renderObject)
        }
        
        return RenderState(
            program: program,
            vertexArray: vertexArray,
            uniformBuffer: uniformBuffer,
            texture: texture,
            objects: objects
        )
    }
}
