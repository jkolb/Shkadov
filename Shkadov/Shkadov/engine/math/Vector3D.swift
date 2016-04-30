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

public struct Vector3D : Equatable, CustomStringConvertible {
    public static let xAxis = Vector3D(1.0, 0.0, 0.0)
    public static let yAxis = Vector3D(0.0, 1.0, 0.0)
    public static let zAxis = Vector3D(0.0, 0.0, 1.0)
    
    public var x, y, z: Float
    
    public init() {
        self.init(0.0, 0.0, 0.0)
    }
    
    public init(_ v: Float) {
        self.init(v, v, v)
    }
    
    public init(_ x: Float, _ y: Float, _ z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    public init(_ v: Vector4D) {
        self.init(v.x, v.y, v.z)
    }
    
    public var components: [Float] {
        return [x, y, z]
    }
    
    public subscript(index: Int) -> Float {
        get {
            switch index {
            case 0:
                return x
            case 1:
                return y
            case 2:
                return z
            default:
                fatalError("Index out of range")
            }
        }
        set {
            switch index {
            case 0:
                x = newValue
            case 1:
                y = newValue
            case 2:
                z = newValue
            default:
                fatalError("Index out of range")
            }
        }
    }
    
    public var maximum: Float {
        return max(max(x, y), z)
    }

    public var description: String {
        return "{\(x), \(y), \(z)}"
    }
}

// MARK: - Scalar Addition

public func +(lhs: Vector3D, rhs: Float) -> Vector3D {
    return Vector3D(
        lhs.x + rhs,
        lhs.y + rhs,
        lhs.z + rhs
    )
}

public func +(lhs: Float, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs + rhs.x,
        lhs + rhs.y,
        lhs + rhs.z
    )
}

// MARK: - Addition

public func +(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs.x + rhs.x,
        lhs.y + rhs.y,
        lhs.z + rhs.z
    )
}

// MARK: - Scalar Subtraction

public func -(lhs: Vector3D, rhs: Float) -> Vector3D {
    return Vector3D(
        lhs.x - rhs,
        lhs.y - rhs,
        lhs.z - rhs
    )
}

public func -(lhs: Float, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs - rhs.x,
        lhs - rhs.y,
        lhs - rhs.z
    )
}

// MARK: - Subtraction

public func -(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs.x - rhs.x,
        lhs.y - rhs.y,
        lhs.z - rhs.z
    )
}

// MARK: - Scalar Multiplication

public func *(lhs: Vector3D, rhs: Float) -> Vector3D {
    return Vector3D(
        lhs.x * rhs,
        lhs.y * rhs,
        lhs.z * rhs
    )
}

public func *(lhs: Float, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs * rhs.x,
        lhs * rhs.y,
        lhs * rhs.z
    )
}

// MARK: - Multiplication

public func *(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs.x * rhs.x,
        lhs.y * rhs.y,
        lhs.z * rhs.z
    )
}

// MARK: - Scalar Division

public func /(lhs: Vector3D, rhs: Float) -> Vector3D {
    return Vector3D(
        lhs.x / rhs,
        lhs.y / rhs,
        lhs.z / rhs
    )
}

public func /(lhs: Float, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs / rhs.x,
        lhs / rhs.y,
        lhs / rhs.z
    )
}

// MARK: - Division

public func /(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
    return Vector3D(
        lhs.x / rhs.x,
        lhs.y / rhs.y,
        lhs.z / rhs.z
    )
}

// MARK: - Negation

public prefix func -(v: Vector3D) -> Vector3D {
    return Vector3D(
        -v.x,
        -v.y,
        -v.z
    )
}

public prefix func +(v: Vector3D) -> Vector3D {
    return v
}

// MARK: - Component Sum

public func sum(vector: Vector3D) -> Float {
    return vector.x + vector.y + vector.z
}

// MARK: - Length Squared

public func length2(vector: Vector3D) -> Float {
    return sum(vector * vector)
}

// MARK: - Length

public func length(vector: Vector3D) -> Float {
    return sqrt(length2(vector))
}

// MARK: - Normalization

public func normalize(vector: Vector3D) -> Vector3D {
    return vector * (1.0 / length(vector))
}

// MARK: - Distance Squared

public func distance2(va: Vector3D, _ vb: Vector3D) -> Float {
    let difference = vb - va
    return sum(difference * difference)
}

// MARK: - Distance

public func distance(va: Vector3D, _ vb: Vector3D) -> Float {
    return sqrt(distance2(va, vb))
}

// MARK: - Cross Product

public func cross(va: Vector3D, _ vb: Vector3D) -> Vector3D {
    return Vector3D(
        va.y * vb.z - vb.y * va.z,
        va.z * vb.x - vb.z * va.x,
        va.x * vb.y - vb.x * va.y
    )
}

// MARK: - Dot Product

public func dot(va: Vector3D, _ vb: Vector3D) -> Float {
    return sum(va * vb)
}

// MARK: - Equatable

public func ==(va: Vector3D, vb: Vector3D) -> Bool {
    return va.x == vb.x && va.y == vb.y && va.z == vb.z
}

// MARK: - Approximately Equal

public func approx(va: Vector3D, _ vb: Vector3D, epsilon: Float = 1e-6) -> Bool {
    let dX = va.x.distanceTo(vb.x)
    let dY = va.y.distanceTo(vb.y)
    let dZ = va.z.distanceTo(vb.z)
    let aX = abs(dX) <= epsilon
    let aY = abs(dY) <= epsilon
    let aZ = abs(dZ) <= epsilon
    return aX && aY && aZ
}

// MARK: - Absolute Value

public func abs(v: Vector3D) -> Vector3D {
    return Vector3D(
        abs(v.x),
        abs(v.y),
        abs(v.z)
    )
}
