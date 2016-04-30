/*
 The MIT License (MIT)
 
 Copyright (c) 2016 Justin Kolb
 
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

public struct Triangle3D : CustomStringConvertible {
    public let a, b, c: Vector3D
    
    public init(_ a: Vector3D, _ b: Vector3D, _ c: Vector3D) {
        self.a = a
        self.b = b
        self.c = c
    }

    public var points: [Vector3D] {
        return [a, b, c]
    }
    
    public var normal: Vector3D {
        return normalize(cross(b - a, c - a))
    }
    
    public var plane: Plane {
        let normal = self.normal
        let distanceToOrigin = dot(normal, a)
        return Plane(normal: normal, distanceToOrigin: distanceToOrigin)
    }
    
    public var bounds: AABB {
        return AABB(containingPoints: [a, b, c])
    }
    
    public var description: String {
        return "{\(a), \(b), \(c)}"
    }
}
