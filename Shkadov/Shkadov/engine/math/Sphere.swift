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

public struct Sphere : Equatable {
    public let center: Vector3D
    public let radius: Float

    public init() {
        self.init(center: Vector3D.zero, radius: 0.0)
    }
    
    public init(center: Vector3D, radius: Float) {
        precondition(radius >= 0.0)
        self.center = center
        self.radius = radius
    }
    
    public func intersectsOrIsInsidePlane(plane: Plane) -> Bool {
        let distance = dot(center, plane.normal) - plane.distanceToOrigin
        let intersects = abs(distance) <= radius
        let isInside = radius <= distance
        return intersects || isInside
    }
    
    public var aabb: AABB {
        return AABB(center: center, radius: Vector3D(radius))
    }
    
    public var isNull: Bool {
        return center == Vector3D.zero && radius == 0.0
    }
    
    public func union(other: Sphere) -> Sphere {
        let midpoint = (center + other.center) * 0.5
        let largestRadius = distance(midpoint, center) + max(radius, other.radius)
        return Sphere(center: midpoint, radius: largestRadius)
    }
    
    public var description: String {
        return "{\(center), \(radius)}"
    }
}

public func ==(lhs: Sphere, rhs: Sphere) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}
