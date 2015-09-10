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

public class Mesh {
    public let vertexDescriptor: VertexDescriptor
    private let bits = UnsafeMutablePointer<UInt8>.alloc(sizeof(UIntMax))
    public var data = [UInt32]()
    
    public init(vertexDescriptor: VertexDescriptor) {
        self.vertexDescriptor = vertexDescriptor
    }
    
    public func addPolygon(polygon: Polygon3D, normal: Vector3D, color: ColorRGBA8) {
        for triangle in polygon.triangles() {
            for point in triangle.points() {
                if vertexDescriptor.hasAttribute(.Position) {
                    addFloat(point.x)
                    addFloat(point.y)
                    addFloat(point.z)
                }

                if vertexDescriptor.hasAttribute(.Normal) {
                    addFloat(normal.dx)
                    addFloat(normal.dy)
                    addFloat(normal.dz)
                }

                if vertexDescriptor.hasAttribute(.Color) {
                    addColor(color)
                }

                /*
                case TexCoord0
                case TexCoord1
                */
            }
        }
    }
    
    public var size: Int {
        return vertexDescriptor.size * data.count
    }
    
    public var stride: Int {
        return vertexDescriptor.size
    }
    
    deinit {
        bits.dealloc(sizeof(UIntMax))
    }

    private func addColor(color: ColorRGBA8) {
        let floatColor = color.color
        addFloat(floatColor.red)
        addFloat(floatColor.green)
        addFloat(floatColor.blue)
        addFloat(floatColor.alpha)
    }
    
    private func addFloat(value: Float) {
        UnsafeMutablePointer<Float32>(bits).memory = value
        data.append(UnsafePointer<UInt32>(bits).memory)
    }
    
    public func addCubeWithSize(size: GeometryType, color: ColorRGBA8) {
        addBoxWithWidth(size, height: size, depth: size, color: color)
    }
    
    public func addBoxWithWidth(width: GeometryType, height: GeometryType, depth: GeometryType, color: ColorRGBA8) {
        precondition(width > geometryZero)
        precondition(height > geometryZero)
        precondition(depth > geometryZero)
        
        let w = width * 0.5
        let h = height * 0.5
        let d = depth * 0.5
        
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
        
        let q0 = Quad3D(a: p0, b: p1, c: p2, d: p3)
        let q1 = Quad3D(a: p4, b: p5, c: p6, d: p7)
        let q2 = Quad3D(a: p1, b: p4, c: p3, d: p6)
        let q3 = Quad3D(a: p5, b: p0, c: p7, d: p2)
        let q4 = Quad3D(a: p3, b: p6, c: p2, d: p7)
        let q5 = Quad3D(a: p0, b: p5, c: p1, d: p4)
        
        addPolygon(q0, normal: n0, color: color)
        addPolygon(q1, normal: n1, color: color)
        addPolygon(q2, normal: n2, color: color)
        addPolygon(q3, normal: n3, color: color)
        addPolygon(q4, normal: n4, color: color)
        addPolygon(q5, normal: n5, color: color)
    }
}
