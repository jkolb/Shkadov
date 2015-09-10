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

public protocol Polygon3D {
    func triangles() -> [Triangle3D]
}

public struct Triangle3D : Polygon3D {
    public let a: Point3D
    public let b: Point3D
    public let c: Point3D
    
    public init(a: Point3D, b: Point3D, c: Point3D) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    public func triangles() -> [Triangle3D] {
        return [self]
    }
    
    public func points() -> [Point3D] {
        return [a, b, c]
    }
}

public struct Quad3D : Polygon3D {
    public let a: Point3D
    public let b: Point3D
    public let c: Point3D
    public let d: Point3D
    
    public init(a: Point3D, b: Point3D, c: Point3D, d: Point3D) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    
    public func triangles() -> [Triangle3D] {
        return [
            Triangle3D(a: a, b: b, c: c),
            Triangle3D(a: c, b: b, c: d),
        ]
    }
}
