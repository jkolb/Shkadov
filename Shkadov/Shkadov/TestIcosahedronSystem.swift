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

public final class TestIcosahedronSystem {
    private let renderer: Renderer
    private let assetLoader: AssetLoader
    private let entityComponents: EntityComponents
    private var program: Handle = Handle.invalid
    private var vertexBuffer: RenderBuffer!
    private var indexBuffer: RenderBuffer!
    private var uniformBuffer: RenderBuffer!
    private let icosahedron: Entity
    
    public init(renderer: Renderer, assetLoader: AssetLoader, entityComponents: EntityComponents) {
        self.renderer = renderer
        self.assetLoader = assetLoader
        self.entityComponents = entityComponents
        self.icosahedron = entityComponents.createEntity()
    }
    
    deinit {
        renderer.destroyProgram(program)
    }
    
    public func configure() {
        let surface = generateSurface()
        let vertices = surface.allVertices()
        let faces = surface.allFaces()
        
        vertexBuffer = renderer.createBufferWithName("Icosahedron Vertex", length: vertices.count * strideof(Float32) * 7)
        indexBuffer = renderer.createBufferWithName("Icosahedron Index", length: faces.count * 3 * strideof(UInt32))
        
        let colors = [ColorRGBA8.forestGreen, ColorRGBA8.green]

        let vertexByteBuffer = ByteBuffer(data: vertexBuffer.contents, length: vertexBuffer.length)
        let indexByteBuffer = ByteBuffer(data: indexBuffer.contents, length: indexBuffer.length)

        for vertex in vertices {
            let normal = normalize(vertex)
            let height = normal * Float(arc4random() % 256)
            let adjustedVertex = (normal * 65536.0) + height
            vertexByteBuffer.putNextValue(adjustedVertex.point)
            vertexByteBuffer.putNextValue(Color(rgba8: colors[Int(arc4random() % UInt32(colors.count))]))
        }
        
        for face in faces {
            indexByteBuffer.putNextValue(UInt32(face.a))
            indexByteBuffer.putNextValue(UInt32(face.b))
            indexByteBuffer.putNextValue(UInt32(face.c))
        }
        
        program = renderer.createProgramWithVertexPath("terrainVertex", fragmentPath: "colorFragment")
        let uniformSize = strideof(UniformIn)
        uniformBuffer = renderer.createBufferWithName("Icosahedron Uniforms", length: uniformSize)
        
        entityComponents.addComponent(OrientationComponent(position: Point3D()), toEntity: icosahedron)
        entityComponents.addComponent(RenderComponent(vertexCount: vertices.count, indexCount: faces.count * 3, uniformBuffer: uniformBuffer, uniformOffset: 0, diffuseColor: Color.white), toEntity: icosahedron)
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
    }
    
    public func render() -> RenderState {
        var objects = [RenderComponent]()
        let renderObject = entityComponents.componentForEntity(icosahedron, withComponentType: RenderComponent.self)
        objects.append(renderObject)
        
        return RenderState(
            program: program,
            vertexBuffer: vertexBuffer,
            indexBuffer: indexBuffer,
            uniformBuffer: uniformBuffer,
            texture: Handle.invalid,
            objects: objects,
            cullMode: .Front
        )
    }
    
    public func generateSurface() -> Surface {
        let size: Float = 65536.0
        let divisions = 256
        return Surface.icosahedron(size).subdivideBy(divisions)
    }
}

extension Mesh3D {
    public func append(quad: Quad3D, normal: Vector3D, color1: ColorRGBA8, color2: ColorRGBA8) {
        let texCoord = Quad2D(Point2D(), Point2D(), Point2D(), Point2D())
        let v0 = Vertex3D(position: quad.a, normal: normal, texCoord: texCoord.a, color: color1)
        let v1 = Vertex3D(position: quad.b, normal: normal, texCoord: texCoord.b, color: color1)
        let v2 = Vertex3D(position: quad.d, normal: normal, texCoord: texCoord.d, color: color2)
        let v3 = Vertex3D(position: quad.d, normal: normal, texCoord: texCoord.d, color: color2)
        let v4 = Vertex3D(position: quad.b, normal: normal, texCoord: texCoord.b, color: color1)
        let v5 = Vertex3D(position: quad.c, normal: normal, texCoord: texCoord.c, color: color2)
        
        append(RenderableTriangle(v0, v1, v2))
        append(RenderableTriangle(v3, v4, v5))
    }
    
    public func append(triangle: Triangle3D, color: ColorRGBA8) {
        let texCoord = Quad2D(Point2D(), Point2D(), Point2D(), Point2D())
        let v0 = Vertex3D(position: triangle.a, normal: normalize(triangle.a.vector), texCoord: texCoord.a, color: color)
        let v1 = Vertex3D(position: triangle.b, normal: normalize(triangle.b.vector), texCoord: texCoord.b, color: color)
        let v2 = Vertex3D(position: triangle.c, normal: normalize(triangle.c.vector), texCoord: texCoord.c, color: color)
        
        append(RenderableTriangle(v0, v1, v2))
    }
}
