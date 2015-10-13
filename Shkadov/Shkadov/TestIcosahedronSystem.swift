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
    private var vertexArray: Handle = Handle.invalid
    private var uniformBuffer: Handle = Handle.invalid
    private let rectangles: Entity
    
    public init(renderer: Renderer, assetLoader: AssetLoader, entityComponents: EntityComponents) {
        self.renderer = renderer
        self.assetLoader = assetLoader
        self.entityComponents = entityComponents
        self.rectangles = entityComponents.createEntity()
    }
    
    deinit {
        renderer.destroyProgram(program)
        renderer.destoryVertexArray(vertexArray)
    }
    
    public func configure() {
        var vertexDescriptor = VertexDescriptor()
        vertexDescriptor.addAttribute(.Position, format: .Float3)
        vertexDescriptor.addAttribute(.Normal, format: .Float3)
        vertexDescriptor.addAttribute(.Color, format: .Float4)
        
        let mesh = generateMesh()
        let meshData = mesh.createBufferForVertexDescriptor(vertexDescriptor)
        
        program = renderer.createProgramWithVertexPath("colorVertex", fragmentPath: "colorFragment")
        vertexArray = renderer.createVertexArrayFromDescriptor(vertexDescriptor, buffer: meshData)
        
        let uniformSize = strideof(UniformIn)
        uniformBuffer = renderer.createBufferWithName("Rectangles Uniforms", length: uniformSize)
        
        entityComponents.addComponent(OrientationComponent(position: Point3D()), toEntity: rectangles)
        entityComponents.addComponent(RenderComponent(uniformBuffer: uniformBuffer, uniformOffset: 0, diffuseColor: Color.white), toEntity: rectangles)
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
    }
    
    public func render() -> RenderState {
        var objects = [RenderComponent]()
        let renderObject = entityComponents.componentForEntity(rectangles, withComponentType: RenderComponent.self)
        objects.append(renderObject)
        
        return RenderState(
            program: program,
            vertexArray: vertexArray,
            uniformBuffer: uniformBuffer,
            texture: Handle.invalid,
            objects: objects,
            cullMode: .None
        )
    }
    
    public func generateMesh() -> Mesh3D {
        let goldenRatio = (1.0 + sqrtf(5.0)) / 2.0
        let g = normalize(Vector3D(0.0, 1.0, goldenRatio))
        
        let s = g.y * 0.5
        let l = g.z * 0.5
        
        /*
        Right handed & Counter-clockwise
        
          Y+
          |
          |
          o------X+
         /
        Z+
        
            X = 0            Y = 0         Z = 0
        0-----------3    2-----------1    1-----0
        |           |    |           |    |     |
        |           |    |           |    |     |
        1-----------2    3-----------0    |     |
                                          2-----3
        */

        // X = 0
        let p00 = Point3D(0.0, +s, +l)
        let p01 = Point3D(0.0, -s, +l)
        let p02 = Point3D(0.0, -s, -l)
        let p03 = Point3D(0.0, +s, -l)
        
        let n0 = Vector3D(+1.0,  0.0,  0.0)
        
        // Y = 0
        let p04 = Point3D(+l, 0.0, +s)
        let p05 = Point3D(+l, 0.0, -s)
        let p06 = Point3D(-l, 0.0, -s)
        let p07 = Point3D(-l, 0.0, +s)
        
        let n1 = Vector3D( 0.0, +1.0,  0.0)
        
        // Z = 0
        let p08 = Point3D(+s, +l, 0.0)
        let p09 = Point3D(-s, +l, 0.0)
        let p10 = Point3D(-s, -l, 0.0)
        let p11 = Point3D(+s, -l, 0.0)
        
        let n2 = Vector3D( 0.0,  0.0, +1.0)
        
        let q0 = Quad3D(p00, p01, p02, p03)
        let q1 = Quad3D(p04, p05, p06, p07)
        let q2 = Quad3D(p08, p09, p10, p11)
        
        let f00 = Triangle3D(p04, p08, p00)
        
        /*
           △▽△ 1
           ▽△
            ▽△▽△▽△▽△▽△
                     ▽△
                 20 ▽△▽
        */
        let mesh = Mesh3D()
        mesh.append(q0, normal: n0, color1: ColorRGBA8.blue, color2: ColorRGBA8.cyan)
        mesh.append(q1, normal: n1, color1: ColorRGBA8.red, color2: ColorRGBA8.magenta)
        mesh.append(q2, normal: n2, color1: ColorRGBA8.green, color2: ColorRGBA8.yellow)
        
        mesh.append(f00, normal: f00.normal(), color1: ColorRGBA8.red, color2: ColorRGBA8.green, color3: ColorRGBA8.blue)
        
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
    
    public func append(triangle: Triangle3D, normal: Vector3D, color1: ColorRGBA8, color2: ColorRGBA8, color3: ColorRGBA8) {
        let texCoord = Quad2D(Point2D(), Point2D(), Point2D(), Point2D())
        let v0 = Vertex3D(position: triangle.a, normal: normal, texCoord: texCoord.a, color: color1)
        let v1 = Vertex3D(position: triangle.b, normal: normal, texCoord: texCoord.b, color: color2)
        let v2 = Vertex3D(position: triangle.c, normal: normal, texCoord: texCoord.c, color: color3)
        
        append(RenderableTriangle(v0, v1, v2))
    }
}
