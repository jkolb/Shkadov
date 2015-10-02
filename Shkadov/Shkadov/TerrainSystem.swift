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

public class TerrainSystem {
    private let renderer: Renderer
    private let assetLoader: AssetLoader
    private let entityComponents: EntityComponents
    private var program: Handle = Handle.invalid
    private var vertexArray: Handle = Handle.invalid
    private var uniformBuffer: Handle = Handle.invalid
    private var texture: Handle = Handle.invalid
    private var floor: Entity!
    
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
        
        let mesh = Mesh3D.boxWithSize(Size3D(100.0, 0.25, 100.0))
        let meshData = mesh.createBufferForVertexDescriptor(vertexDescriptor)
        
        program = renderer.createProgramWithVertexPath("passThroughVertex", fragmentPath: "passThroughFragment")
        vertexArray = renderer.createVertexArrayFromDescriptor(vertexDescriptor, buffer: meshData)
        let uniformSize = strideof(UniformIn)
        uniformBuffer = renderer.createBufferWithName("Terrain Uniforms", length: uniformSize)

        floor = entityComponents.createEntity()
        entityComponents.addComponent(OrientationComponent(position: float3(0.0, -4.0, 0.0)), toEntity: floor)
        entityComponents.addComponent(RenderComponent(uniformBuffer: uniformBuffer, uniformOffset: 0, diffuseColor: Color.tan), toEntity: floor)
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
    }
    
    public func render() -> RenderState {
        var objects = [RenderComponent]()
        let renderObject = entityComponents.componentForEntity(floor, withComponentType: RenderComponent.self)!
        objects.append(renderObject)
        
        return RenderState(
            program: program,
            vertexArray: vertexArray,
            uniformBuffer: uniformBuffer,
            texture: texture,
            objects: objects
        )
    }
}
