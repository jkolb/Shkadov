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

public class Mesh3D : SequenceType {
    private var triangles: [RenderableTriangle]
    
    public init() {
        self.triangles = [RenderableTriangle]()
    }

    public func generate() -> AnyGenerator<RenderableTriangle> {
        var index = 0
        let count = self.count
        return anyGenerator {
            if index < count {
                return self.triangles[index++]
            }
            else {
                return nil
            }
        }
    }
    
    public func appendContentsOf(newTriangles: [RenderableTriangle]) {
        triangles.appendContentsOf(newTriangles)
    }
    
    public func append(triangle: RenderableTriangle) {
        triangles.append(triangle)
    }
    
    public func append(triangle: Triangle3D, normal: Vector3D = Vector3D.zero, color: ColorRGBA8 = ColorRGBA8.white) {
        let v0 = Vertex3D(position: triangle.a, normal: normal, texCoords: [], color: color)
        let v1 = Vertex3D(position: triangle.b, normal: normal, texCoords: [], color: color)
        let v2 = Vertex3D(position: triangle.c, normal: normal, texCoords: [], color: color)
        
        append(RenderableTriangle(v0, v1, v2))
    }
    
    public func append(quad: Quad3D, normal: Vector3D = Vector3D.zero, color: ColorRGBA8 = ColorRGBA8.white) {
        let v0 = Vertex3D(position: quad.a, normal: normal, texCoords: [], color: color)
        let v1 = Vertex3D(position: quad.b, normal: normal, texCoords: [], color: color)
        let v2 = Vertex3D(position: quad.c, normal: normal, texCoords: [], color: color)
        let v3 = Vertex3D(position: quad.c, normal: normal, texCoords: [], color: color)
        let v4 = Vertex3D(position: quad.b, normal: normal, texCoords: [], color: color)
        let v5 = Vertex3D(position: quad.d, normal: normal, texCoords: [], color: color)
        
        append(RenderableTriangle(v0, v1, v2))
        append(RenderableTriangle(v3, v4, v5))
    }
    
    public subscript (index: Int) -> RenderableTriangle {
        get {
            return triangles[index]
        }
        set {
            triangles[index] = newValue
        }
    }
    
    public var count: Int {
        return triangles.count
    }
    
    public var vertexCount: Int {
        return count * 3
    }
    
    public static func cubeWithSize(size: Float) -> Mesh3D {
        return boxWithSize(Size3D(width: size, height: size, depth: size))
    }
    
    public static func boxWithSize(size: Size3D) -> Mesh3D {
        let w = size.width * 0.5
        let h = size.height * 0.5
        let d = size.depth * 0.5
        
        let p0 = Point3D(x: +w, y: -h, z: -d)
        let p1 = Point3D(x: +w, y: +h, z: -d)
        let p2 = Point3D(x: +w, y: -h, z: +d)
        let p3 = Point3D(x: +w, y: +h, z: +d)
        let p4 = Point3D(x: -w, y: +h, z: -d)
        let p5 = Point3D(x: -w, y: -h, z: -d)
        let p6 = Point3D(x: -w, y: +h, z: +d)
        let p7 = Point3D(x: -w, y: -h, z: +d)
        
        let n0 = Vector3D(dx: +1.0, dy:  0.0, dz:  0.0)
        let n1 = Vector3D(dx: -1.0, dy:  0.0, dz:  0.0)
        let n2 = Vector3D(dx:  0.0, dy: +1.0, dz:  0.0)
        let n3 = Vector3D(dx:  0.0, dy: -1.0, dz:  0.0)
        let n4 = Vector3D(dx:  0.0, dy:  0.0, dz: +1.0)
        let n5 = Vector3D(dx:  0.0, dy:  0.0, dz: -1.0)
        
        let q0 = Quad3D(p0, p1, p2, p3)
        let q1 = Quad3D(p4, p5, p6, p7)
        let q2 = Quad3D(p1, p4, p3, p6)
        let q3 = Quad3D(p5, p0, p7, p2)
        let q4 = Quad3D(p3, p6, p2, p7)
        let q5 = Quad3D(p0, p5, p1, p4)
        
        let box = Mesh3D()
        box.append(q0, normal: n0)
        box.append(q1, normal: n1)
        box.append(q2, normal: n2)
        box.append(q3, normal: n3)
        box.append(q4, normal: n4)
        box.append(q5, normal: n5)
        return box
    }
    
    public func createBufferForVertexDescriptor(vertexDescriptor: VertexDescriptor) -> ByteBuffer {
        let buffer = ByteBuffer(capacity: vertexCount * vertexDescriptor.size)
        
        for triangle in self {
            for vertex in triangle {
                for attribute in vertexDescriptor.attributes {
                    switch attribute {
                    case .Position:
                        buffer.putNextValue(vertex.position)
                    case .Normal:
                        buffer.putNextValue(vertex.normal)
                    case .Color:
                        buffer.putNextValue(vertex.color)
                    case .TexCoord0:
                        fatalError("Not handled")
                    case .TexCoord1:
                        fatalError("Not handled")
                    }
                }
            }
        }
        
        return buffer
    }
}
