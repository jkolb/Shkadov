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
            cullMode: .None
        )
    }
    
    public func generateMesh() -> Mesh3D {
        let goldenRatio = (1.0 + sqrtf(5.0)) / 2.0
        let g = Vector3D(0.0, 1.0, goldenRatio) * 50000.0
        
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
        let z0 = Point3D(0.0, +s, +l)
        let z1 = Point3D(0.0, -s, +l)
        let z2 = Point3D(0.0, -s, -l)
        let z3 = Point3D(0.0, +s, -l)
        
        // Y = 0
        let x0 = Point3D(+l, 0.0, +s)
        let x1 = Point3D(+l, 0.0, -s)
        let x2 = Point3D(-l, 0.0, -s)
        let x3 = Point3D(-l, 0.0, +s)
        
        // Z = 0
        let y0 = Point3D(+s, +l, 0.0)
        let y1 = Point3D(-s, +l, 0.0)
        let y2 = Point3D(-s, -l, 0.0)
        let y3 = Point3D(+s, -l, 0.0)
        
        let t0 = y0.vector
        let t1 = y1.vector
        let tl = length(t1 - t0)
        print(tl)
//        let n0 = Vector3D(+1.0,  0.0,  0.0)
//        let n1 = Vector3D( 0.0, +1.0,  0.0)
//        let n2 = Vector3D( 0.0,  0.0, +1.0)
//        
//        let q0 = Quad3D(z0, z1, z2, z3)
//        let q1 = Quad3D(x0, x1, x2, x3)
//        let q2 = Quad3D(y0, y1, y2, y3)
        
        /*
           △▽△ 1
           ▽△
            ▽△▽△▽△▽△▽△
                     ▽△
                 20 ▽△▽
        */
        let f00 = Triangle3D(y0, y1, z0)
        let f01 = Triangle3D(z0, y1, x3)
        let f02 = Triangle3D(x3, z1, z0)
        let f03 = Triangle3D(z0, z1, x0)
        let f04 = Triangle3D(x0, y0, z0)
        let f05 = Triangle3D(x0, x1, y0)
        let f06 = Triangle3D(x1, y0, z3)
        let f07 = Triangle3D(z3, y0, y1)
        let f08 = Triangle3D(z3, y1, x2)
        let f09 = Triangle3D(x2, y1, x3)
        let f10 = Triangle3D(x2, x3, y2)
        let f11 = Triangle3D(x3, y2, z1)
        let f12 = Triangle3D(z1, y2, y3)
        let f13 = Triangle3D(y3, z1, x0)
        let f14 = Triangle3D(x0, y3, x1)
        let f15 = Triangle3D(x1, y3, z2)
        let f16 = Triangle3D(z2, x1, z3)
        let f17 = Triangle3D(z3, z2, x2)
        let f18 = Triangle3D(z2, x2, y2)
        let f19 = Triangle3D(z2, y2, y3)
        
        let mesh = Mesh3D()
        
//        mesh.append(q0, normal: n0, color1: ColorRGBA8.blue, color2: ColorRGBA8.cyan)
//        mesh.append(q1, normal: n1, color1: ColorRGBA8.red, color2: ColorRGBA8.magenta)
//        mesh.append(q2, normal: n2, color1: ColorRGBA8.green, color2: ColorRGBA8.yellow)
        
//        mesh.append(f00, normal: f00.normal(), color: ColorRGBA8.red)
//        mesh.append(f01, normal: f01.normal(), color: ColorRGBA8.green)
//        mesh.append(f02, normal: f02.normal(), color: ColorRGBA8.blue)
//        mesh.append(f03, normal: f03.normal(), color: ColorRGBA8.yellow)
//        mesh.append(f04, normal: f04.normal(), color: ColorRGBA8.magenta)
//        mesh.append(f05, normal: f05.normal(), color: ColorRGBA8.cyan)
//        mesh.append(f06, normal: f06.normal(), color: ColorRGBA8.brown)
//        mesh.append(f07, normal: f07.normal(), color: ColorRGBA8.pink)
//        mesh.append(f08, normal: f08.normal(), color: ColorRGBA8.lime)
//        mesh.append(f09, normal: f09.normal(), color: ColorRGBA8.orange)
//        mesh.append(f10, normal: f10.normal(), color: ColorRGBA8.silver)
//        mesh.append(f11, normal: f11.normal(), color: ColorRGBA8.teal)
//        mesh.append(f12, normal: f12.normal(), color: ColorRGBA8.olive)
//        mesh.append(f13, normal: f13.normal(), color: ColorRGBA8.purple)
//        mesh.append(f14, normal: f14.normal(), color: ColorRGBA8.navy)
//        mesh.append(f15, normal: f15.normal(), color: ColorRGBA8.maroon)
//        mesh.append(f16, normal: f16.normal(), color: ColorRGBA8.skyBlue)
//        mesh.append(f17, normal: f17.normal(), color: ColorRGBA8.forestGreen)
//        mesh.append(f18, normal: f18.normal(), color: ColorRGBA8.gold)
//        mesh.append(f19, normal: f19.normal(), color: ColorRGBA8.indigo)
        mesh.append(f00, normal: f00.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f01, normal: f01.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f02, normal: f02.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f03, normal: f03.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f04, normal: f04.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f05, normal: f05.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f06, normal: f06.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f07, normal: f07.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f08, normal: f08.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f09, normal: f09.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f10, normal: f10.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f11, normal: f11.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f12, normal: f12.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f13, normal: f13.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f14, normal: f14.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f15, normal: f15.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f16, normal: f16.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f17, normal: f17.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f18, normal: f18.normal(), color: ColorRGBA8.skyBlue)
        mesh.append(f19, normal: f19.normal(), color: ColorRGBA8.skyBlue)

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
    
    public func append(triangle: Triangle3D, normal: Vector3D, color: ColorRGBA8) {
        let texCoord = Quad2D(Point2D(), Point2D(), Point2D(), Point2D())
        let v0 = Vertex3D(position: triangle.a, normal: normal, texCoord: texCoord.a, color: color)
        let v1 = Vertex3D(position: triangle.b, normal: normal, texCoord: texCoord.b, color: color)
        let v2 = Vertex3D(position: triangle.c, normal: normal, texCoord: texCoord.c, color: color)
        
        append(RenderableTriangle(v0, v1, v2))
    }
}
