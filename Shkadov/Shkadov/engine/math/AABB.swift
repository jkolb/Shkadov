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

public struct AABB : Equatable {
    public let center: Vector3D
    public let radius: Vector3D
    
    public init() {
        self.init(center: Vector3D.zero, radius: Vector3D.zero)
    }
    
    public init(minimum: Vector3D, maximum: Vector3D) {
        precondition(minimum.x <= maximum.x)
        precondition(minimum.y <= maximum.y)
        precondition(minimum.z <= maximum.z)
        let center = (maximum + minimum) * 0.5
        let radius = (maximum - minimum) * 0.5
        self.init(center: center, radius: radius)
    }
    
    public init(union: [AABB]) {
        var minmax = [Vector3D]()
        
        for other in union {
            if !other.isNull {
                minmax.append(other.minimum)
                minmax.append(other.maximum)
            }
        }
        
        self.init(containingPoints: minmax)
    }
    
    public init(containingPoints points: [Vector3D]) {
        if points.count == 0 {
            self.init()
            return
        }
        
        var minimum = Vector3D(+floatMax, +floatMax, +floatMax)
        var maximum = Vector3D(-floatMax, -floatMax, -floatMax)
        
        for point in points {
            if point.x < minimum.x {
                minimum.x = point.x
            }
            
            if point.x > maximum.x {
                maximum.x = point.x
            }
            
            if point.y < minimum.y {
                minimum.y = point.y
            }
            
            if point.y > maximum.y {
                maximum.y = point.y
            }
            
            if point.z < minimum.z {
                minimum.z = point.z
            }
            
            if point.z > maximum.z {
                maximum.z = point.z
            }
        }
        
        self.init(minimum: minimum, maximum: maximum)
    }

    public init(center: Vector3D, radius: Vector3D) {
        precondition(radius.x >= 0.0)
        precondition(radius.y >= 0.0)
        precondition(radius.z >= 0.0)
        self.center = center
        self.radius = radius
    }
    
    public var minimum: Vector3D {
        return center - radius
    }
    
    public var maximum: Vector3D {
        return center + radius
    }
    
    public func intersectsOrIsInsidePlane(plane: Plane) -> Bool {
        let projectionRadiusOfBox = sum(radius * abs(plane.normal))
        let distanceOfBoxCenterFromPlane = dot(plane.normal, center) - plane.distanceToOrigin
        let intersects = abs(distanceOfBoxCenterFromPlane) <= projectionRadiusOfBox
        let isInside = projectionRadiusOfBox <= distanceOfBoxCenterFromPlane
        return intersects || isInside
    }
    
    public var sphere: Sphere {
        return Sphere(center: center, radius: length(radius))
    }

    public var isNull: Bool {
        return center == Vector3D.zero && radius == Vector3D.zero
    }
    
    public func union(other: AABB) -> AABB {
        if isNull {
            return other
        }
        else if other.isNull {
            return self
        }
        else {
            return AABB(containingPoints: [minimum, maximum, other.minimum, other.maximum])
        }
    }
    
    public func union(others: [AABB]) -> AABB {
        var minmax = [Vector3D]()
        
        if !isNull {
            minmax.append(minimum)
            minmax.append(maximum)
        }
        
        for other in others {
            if !other.isNull {
                minmax.append(other.minimum)
                minmax.append(other.maximum)
            }
        }

        if minmax.count == 0 {
            return self
        }
        else {
            return AABB(containingPoints: minmax)
        }
    }
    
    public var description: String {
        return "{\(center), \(radius)}"
    }
    
    public var corners: [Vector3D] {
        return [
            (center + radius * Vector3D(+1.0, +1.0, +1.0)),
            (center + radius * Vector3D(-1.0, +1.0, +1.0)),
            (center + radius * Vector3D(+1.0, -1.0, +1.0)),
            (center + radius * Vector3D(+1.0, +1.0, -1.0)),
            (center + radius * Vector3D(-1.0, -1.0, +1.0)),
            (center + radius * Vector3D(+1.0, -1.0, -1.0)),
            (center + radius * Vector3D(-1.0, +1.0, -1.0)),
            (center + radius * Vector3D(-1.0, -1.0, -1.0)),
        ]
    }
}

public func ==(lhs: AABB, rhs: AABB) -> Bool {
    return lhs.center == rhs.center && lhs.radius == rhs.radius
}
