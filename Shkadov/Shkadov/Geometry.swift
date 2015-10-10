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

public struct Angle : Equatable, Comparable, CustomStringConvertible, CustomDebugStringConvertible {
    private static let degreesToRadians: GeometryType = π / 180.0
    private static let radiansToDegrees: GeometryType = 180.0 / π
    public static let min: GeometryType = -2.0 * π
    public static let max: GeometryType = +2.0 * π
    
    public var radians: GeometryType {
        didSet {
            radians = Angle.clamped(radians)
        }
    }
    
    public init(radians: GeometryType = 0.0) {
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

public struct Angle3D {
    let roll: Angle
    let pitch: Angle
    let yaw: Angle
    
    public init(roll: Angle = Angle(), pitch: Angle = Angle(), yaw: Angle = Angle()) {
        self.roll = roll
        self.pitch = pitch
        self.yaw = yaw
    }
    
    public var rotation: Matrix3x3 {
        let yawMatrix = Matrix3x3(angle: yaw, axis: Vector3D.yAxis)
        let pitchMatrix = Matrix3x3(angle: pitch, axis: Vector3D.xAxis)
        let rollMatrix = Matrix3x3(angle: roll, axis: Vector3D.zAxis)
        return rollMatrix * pitchMatrix * yawMatrix
    }
}

public struct Point2D {
    public let x: GeometryType
    public let y: GeometryType
    
    public init(_ x: GeometryType = 0.0, _ y: GeometryType = 0.0) {
        self.x = x
        self.y = y
    }
}

public struct Size2D {
    public let width: GeometryType
    public let height: GeometryType
    
    public init(_ width: GeometryType = 0.0, _ height: GeometryType = 0.0) {
        precondition(width >= 0.0)
        precondition(height >= 0.0)
        
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
    public static let zero = Rectangle2D(origin: Point2D(), size: Size2D())
    
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
    public let x: GeometryType
    public let y: GeometryType
    public let z: GeometryType
    
    public init(_ x: GeometryType = 0.0, _ y: GeometryType = 0.0, _ z: GeometryType = 0.0) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public func +(a: Point3D, b: Vector3D) -> Point3D {
    return Point3D(a.x + b.x, a.y + b.y, a.z + b.z)
}

public struct Size3D {
    public let width: GeometryType
    public let height: GeometryType
    public let depth: GeometryType
    
    public init(_ width: GeometryType = 0.0, _ height: GeometryType = 0.0, _ depth: GeometryType = 0.0) {
        precondition(width >= 0.0)
        precondition(height >= 0.0)
        precondition(depth >= 0.0)
        
        self.width = width
        self.height = height
        self.depth = depth
    }
}
