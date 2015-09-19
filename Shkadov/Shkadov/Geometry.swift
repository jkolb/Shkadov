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

import Darwin.C.math

public typealias GeometryType = Float

public let π = GeometryType(M_PI)

private let geometryZero = GeometryType(0.0)

public struct Angle : Equatable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    public static let zero = Angle(radians: geometryZero)
    private static let degreesToRadians: GeometryType = π / 180.0
    private static let radiansToDegrees: GeometryType = 180.0 / π
    public static let min: GeometryType = -2.0 * π
    public static let max: GeometryType = +2.0 * π
    
    public var radians: GeometryType {
        didSet {
            radians = Angle.clamped(radians)
        }
    }
    
    public init(radians: GeometryType) {
        self.radians = Angle.clamped(radians)
    }
    
    private static func clamped(radians: GeometryType) -> GeometryType {
        var clampedRadians = radians
        
        while clampedRadians >= Angle.max {
            clampedRadians -= Angle.max
        }
        
        while clampedRadians < Angle.min {
            clampedRadians += Angle.max
        }
        
        return clampedRadians
    }
    
    public init(degrees: GeometryType) {
        self.init(radians: Angle.degreesToRadians * degrees)
    }
    
    public var degrees: GeometryType {
        return radians * Angle.radiansToDegrees
    }
    
    public var description: String {
        return radians.description
    }
    
    public var debugDescription: String {
        return degrees.description
    }
}

public func ==(a: Angle, b: Angle) -> Bool {
    return a.radians == b.radians
}

public func <(a: Angle, b: Angle) -> Bool {
    return a.radians < b.radians
}

public func +(a: Angle, b: Angle) -> Angle {
    return Angle(radians: a.radians + b.radians)
}

public func -(a: Angle, b: Angle) -> Angle {
    return Angle(radians: a.radians - b.radians)
}

public func *(a: Angle, b: GeometryType) -> Angle {
    return Angle(radians: a.radians * b)
}

public func *(a: GeometryType, b: Angle) -> Angle {
    return Angle(radians: a * b.radians)
}

public func /(a: Angle, b: GeometryType) -> Angle {
    return Angle(radians: a.radians / b)
}

public func +=(inout a: Angle, b: Angle) {
    a.radians = a.radians + b.radians
}

public func -=(inout a: Angle, b: Angle) {
    a.radians = a.radians - b.radians
}

public struct Point2D {
    public static let zero = Point2D(geometryZero, geometryZero)
    
    public let x: GeometryType
    public let y: GeometryType
    
    public init(_ x: GeometryType, _ y: GeometryType) {
        self.x = x
        self.y = y
    }
}

public struct Vector2D {
    public static let zero = Vector2D(geometryZero, geometryZero)
    
    public let dx: GeometryType
    public let dy: GeometryType
    
    public init(_ dx: GeometryType, _ dy: GeometryType) {
        self.dx = dx
        self.dy = dy
    }
    
    public var angle: Angle {
        return Angle(radians: atan2(dy, dx))
    }
}

public func +(a: Vector2D, b: Vector2D) -> Vector2D {
    return Vector2D(a.dx + b.dx, a.dy + b.dy)
}

public func -(a: Vector2D, b: Vector2D) -> Vector2D {
    return Vector2D(a.dx - b.dx, a.dy - b.dy)
}

public struct Size2D {
    public static let zero = Size2D(geometryZero, geometryZero)
    
    public let width: GeometryType
    public let height: GeometryType
    
    public init(_ width: GeometryType, _ height: GeometryType) {
        precondition(width >= geometryZero)
        precondition(height >= geometryZero)
        
        self.width = width
        self.height = height
    }
    
    public var aspectRatio: GeometryType {
        return width / height
    }
    
    public var inverseAspectRatio: GeometryType {
        return height / width
    }
}

public struct Rectangle2D {
    public static let zero = Rectangle2D(origin: Point2D.zero, size: Size2D.zero)
    
    public let origin: Point2D
    public let size: Size2D
    
    public init(origin: Point2D, size: Size2D) {
        self.origin = origin
        self.size = size
    }
    
    public var x: GeometryType {
        return origin.x
    }
    
    public var y: GeometryType {
        return origin.y
    }
    
    public var width: GeometryType {
        return size.width
    }
    
    public var height: GeometryType {
        return size.height
    }

    public var centerX: GeometryType {
        return x + (width * 0.5)
    }
    
    public var centerY: GeometryType {
        return y + (height * 0.5)
    }
    
    public var center: Point2D {
        return Point2D(centerX, centerY)
    }
    
    public var aspectRatio: GeometryType {
        return size.aspectRatio
    }
    
    public var inverseAspectRatio: GeometryType {
        return size.inverseAspectRatio
    }
}

public struct Point3D {
    public static let zero = Point3D(geometryZero, geometryZero, geometryZero)
    
    public let x: GeometryType
    public let y: GeometryType
    public let z: GeometryType
    
    public init(_ x: GeometryType, _ y: GeometryType, _ z: GeometryType) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct Vector3D {
    public static let zero = Vector3D(geometryZero, geometryZero, geometryZero)
    
    public let dx: GeometryType
    public let dy: GeometryType
    public let dz: GeometryType
    
    public init(_ dx: GeometryType, _ dy: GeometryType, _ dz: GeometryType) {
        self.dx = dx
        self.dy = dy
        self.dz = dz
    }
}

public struct Size3D {
    public static let zero = Size3D(geometryZero, geometryZero, geometryZero)
    
    public let width: GeometryType
    public let height: GeometryType
    public let depth: GeometryType
    
    public init(_ width: GeometryType, _ height: GeometryType, _ depth: GeometryType) {
        precondition(width >= geometryZero)
        precondition(height >= geometryZero)
        precondition(depth >= geometryZero)
        
        self.width = width
        self.height = height
        self.depth = depth
    }
}
