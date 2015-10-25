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
    private var uniformBuffer: RenderBuffer!
    private let rectangles: Entity
    
    public init(renderer: Renderer, assetLoader: AssetLoader, entityComponents: EntityComponents) {
        self.renderer = renderer
        self.assetLoader = assetLoader
        self.entityComponents = entityComponents
        self.rectangles = entityComponents.createEntity()
    }
    
    deinit {
        renderer.destroyProgram(program)
    }
    
    public func configure() {
        var vertexDescriptor = VertexDescriptor()
        vertexDescriptor.addAttribute(.Position, format: .Float3)
        vertexDescriptor.addAttribute(.Normal, format: .Float3)
        vertexDescriptor.addAttribute(.Color, format: .Float4)
        
        let mesh = generateMesh()
        vertexBuffer = renderer.createBufferWithName("Icosahedron", length: mesh.vertexCount * vertexDescriptor.size)
        mesh.fillBuffer(vertexBuffer, vertexDescriptor: vertexDescriptor)
        
        program = renderer.createProgramWithVertexPath("colorVertex", fragmentPath: "colorFragment")
        let uniformSize = strideof(UniformIn)
        uniformBuffer = renderer.createBufferWithName("Rectangles Uniforms", length: uniformSize)
        
        entityComponents.addComponent(OrientationComponent(position: Point3D()), toEntity: rectangles)
        entityComponents.addComponent(RenderComponent(vertexCount: mesh.vertexCount, uniformBuffer: uniformBuffer, uniformOffset: 0, diffuseColor: Color.white), toEntity: rectangles)
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
    }
    
    public func render() -> RenderState {
        var objects = [RenderComponent]()
        let renderObject = entityComponents.componentForEntity(rectangles, withComponentType: RenderComponent.self)
        objects.append(renderObject)
        
        return RenderState(
            program: program,
            vertexBuffer: vertexBuffer,
            uniformBuffer: uniformBuffer,
            texture: Handle.invalid,
            objects: objects,
            cullMode: .Front
        )
    }
    
    public func generateMesh() -> Mesh3D {
        let size: Float = 65536.0
        let divisions = 256
        let mesh = Mesh3D()
        var index = 0
        let colors = [ColorRGBA8.olive, ColorRGBA8.forestGreen, ColorRGBA8.brown, ColorRGBA8.grey, ColorRGBA8.green, ColorRGBA8.blue, ColorRGBA8.yellow]
        let surface = Surface.icosahedron(size).subdivideBy(divisions)
        
        for triangle in surface.triangles() {
            let a = (normalize(triangle.a.vector) * size).point
            let b = (normalize(triangle.b.vector) * size).point
            let c = (normalize(triangle.c.vector) * size).point
            let t = Triangle3D(a, b, c)
            mesh.append(t, color: colors[++index % colors.count])
        }
        
        return mesh
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
