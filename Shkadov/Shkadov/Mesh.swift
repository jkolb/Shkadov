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

public protocol Mesh3D {
    var polygons: [Polygon3D] { get }
    var vertexCount: Int { get }
}

public struct Box3D : Mesh3D {
    public var right: Polygon3D
    public var left: Polygon3D
    public var top: Polygon3D
    public var bottom: Polygon3D
    public var forward: Polygon3D
    public var backward: Polygon3D
    
    public var vertexCount: Int {
        return 36
    }
    
    public static func cubeWithSize(size: Float) -> Box3D {
        return boxWithSize(Size3D(width: size, height: size, depth: size))
    }
    
    public static func boxWithSize(size: Size3D) -> Box3D {
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
        
        let v00 = Vertex3D(position: p0, normal: n0)
        let v01 = Vertex3D(position: p1, normal: n0)
        let v02 = Vertex3D(position: p2, normal: n0)
        let v03 = Vertex3D(position: p3, normal: n0)
        
        let v04 = Vertex3D(position: p4, normal: n1)
        let v05 = Vertex3D(position: p5, normal: n1)
        let v06 = Vertex3D(position: p6, normal: n1)
        let v07 = Vertex3D(position: p7, normal: n1)
        
        let v08 = Vertex3D(position: p1, normal: n2)
        let v09 = Vertex3D(position: p4, normal: n2)
        let v10 = Vertex3D(position: p3, normal: n2)
        let v11 = Vertex3D(position: p6, normal: n2)
        
        let v12 = Vertex3D(position: p5, normal: n3)
        let v13 = Vertex3D(position: p0, normal: n3)
        let v14 = Vertex3D(position: p7, normal: n3)
        let v15 = Vertex3D(position: p2, normal: n3)
        
        let v16 = Vertex3D(position: p3, normal: n4)
        let v17 = Vertex3D(position: p6, normal: n4)
        let v18 = Vertex3D(position: p2, normal: n4)
        let v19 = Vertex3D(position: p7, normal: n4)
        
        let v20 = Vertex3D(position: p0, normal: n5)
        let v21 = Vertex3D(position: p5, normal: n5)
        let v22 = Vertex3D(position: p1, normal: n5)
        let v23 = Vertex3D(position: p4, normal: n5)
        
        let q0 = Quad3D(v00, v01, v02, v03)
        let q1 = Quad3D(v04, v05, v06, v07)
        let q2 = Quad3D(v08, v09, v10, v11)
        let q3 = Quad3D(v12, v13, v14, v15)
        let q4 = Quad3D(v16, v17, v18, v19)
        let q5 = Quad3D(v20, v21, v22, v23)
        
        return Box3D(right: q0, left: q1, top: q2, bottom: q3, forward: q4, backward: q5)
    }
    
    public init(right: Polygon3D, left: Polygon3D, top: Polygon3D, bottom: Polygon3D, forward: Polygon3D, backward: Polygon3D) {
        self.right = right
        self.left = left
        self.top = top
        self.bottom = bottom
        self.forward = forward
        self.backward = backward
    }
    
    public var polygons: [Polygon3D] {
        return [right, left, top, bottom, forward, backward]
    }
}
