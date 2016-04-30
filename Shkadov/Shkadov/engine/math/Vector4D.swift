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

public struct Vector4D : Equatable, CustomStringConvertible {
    public var x, y, z, w: Float
    
    public init() {
        self.init(0.0, 0.0, 0.0, 0.0)
    }
    
    public init(_ v: Float) {
        self.init(v, v, v, v)
    }
    
    public init(_ x: Float, _ y: Float, _ z: Float, _ w: Float) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    public init(_ v: Vector3D, _ w: Float) {
        self.init(v.x, v.y, v.z, w)
    }
    
    public var components: [Float] {
        return [x, y, z, w]
    }
    
    public var xyz: Vector3D {
        return Vector3D(x, y, z)
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
            case 3:
                return w
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
            case 3:
                w = newValue
            default:
                fatalError("Index out of range")
            }
        }
    }
    
    public var maximum: Float {
        return max(max(max(x, y), z), w)
    }

    public var description: String {
        return "{\(x), \(y), \(z), \(w)}"
    }
}

// MARK: - Scalar Addition

public func +(lhs: Vector4D, rhs: Float) -> Vector4D {
    return Vector4D(
        lhs.x + rhs,
        lhs.y + rhs,
        lhs.z + rhs,
        lhs.w + rhs
    )
}

public func +(lhs: Float, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs + rhs.x,
        lhs + rhs.y,
        lhs + rhs.z,
        lhs + rhs.w
    )
}

// MARK: - Addition

public func +(lhs: Vector4D, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs.x + rhs.x,
        lhs.y + rhs.y,
        lhs.z + rhs.z,
        lhs.w + rhs.w
    )
}

// MARK: - Scalar Subtraction

public func -(lhs: Vector4D, rhs: Float) -> Vector4D {
    return Vector4D(
        lhs.x - rhs,
        lhs.y - rhs,
        lhs.z - rhs,
        lhs.w - rhs
    )
}

public func -(lhs: Float, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs - rhs.x,
        lhs - rhs.y,
        lhs - rhs.z,
        lhs - rhs.w
    )
}

// MARK: - Subtraction

public func -(lhs: Vector4D, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs.x - rhs.x,
        lhs.y - rhs.y,
        lhs.z - rhs.z,
        lhs.w - rhs.w
    )
}

// MARK: - Scalar Multiplication

public func *(lhs: Vector4D, rhs: Float) -> Vector4D {
    return Vector4D(
        lhs.x * rhs,
        lhs.y * rhs,
        lhs.z * rhs,
        lhs.w * rhs
    )
}

public func *(lhs: Float, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs * rhs.x,
        lhs * rhs.y,
        lhs * rhs.z,
        lhs * rhs.w
    )
}

// MARK: - Multiplication

public func *(lhs: Vector4D, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs.x * rhs.x,
        lhs.y * rhs.y,
        lhs.z * rhs.z,
        lhs.w * rhs.w
    )
}

// MARK: - Scalar Division

public func /(lhs: Vector4D, rhs: Float) -> Vector4D {
    return Vector4D(
        lhs.x / rhs,
        lhs.y / rhs,
        lhs.z / rhs,
        lhs.w / rhs
    )
}

public func /(lhs: Float, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs / rhs.x,
        lhs / rhs.y,
        lhs / rhs.z,
        lhs / rhs.w
    )
}

// MARK: - Division

public func /(lhs: Vector4D, rhs: Vector4D) -> Vector4D {
    return Vector4D(
        lhs.x / rhs.x,
        lhs.y / rhs.y,
        lhs.z / rhs.z,
        lhs.w / rhs.w
    )
}

// MARK: - Negation

public prefix func -(v: Vector4D) -> Vector4D {
    return Vector4D(
        -v.x,
        -v.y,
        -v.z,
        -v.w
    )
}

public prefix func +(v: Vector4D) -> Vector4D {
    return v
}

// MARK: - Component Sum

public func sum(vector: Vector4D) -> Float {
    return vector.x + vector.y + vector.z + vector.w
}

// MARK: - Length Squared

public func length2(vector: Vector4D) -> Float {
    return sum(vector * vector)
}

// MARK: - Length

public func length(vector: Vector4D) -> Float {
    return sqrt(length2(vector))
}

// MARK: - Normalization

public func normalize(vector: Vector4D) -> Vector4D {
    return vector * (1.0 / length(vector))
}

// MARK: - Distance Squared

public func distance2(va: Vector4D, _ vb: Vector4D) -> Float {
    let difference = vb - va
    return sum(difference * difference)
}

// MARK: - Distance

public func distance(va: Vector4D, _ vb: Vector4D) -> Float {
    return sqrt(distance2(va, vb))
}

// MARK: - Dot Product

public func dot(va: Vector4D, _ vb: Vector4D) -> Float {
    return sum(va * vb)
}

// MARK: - Equatable

public func ==(va: Vector4D, vb: Vector4D) -> Bool {
    return va.x == vb.x && va.y == vb.y && va.z == vb.z && va.w == vb.w
}

// MARK: - Approximately Equal

public func approx(va: Vector4D, _ vb: Vector4D, epsilon: Float = 1e-6) -> Bool {
    let dX = va.x.distanceTo(vb.x)
    let dY = va.y.distanceTo(vb.y)
    let dZ = va.z.distanceTo(vb.z)
    let dW = va.w.distanceTo(vb.w)
    let aX = abs(dX) <= epsilon
    let aY = abs(dY) <= epsilon
    let aZ = abs(dZ) <= epsilon
    let aW = abs(dW) <= epsilon
    return aX && aY && aZ && aW
}

// MARK: - Absolute Value

public func abs(v: Vector4D) -> Vector4D {
    return Vector4D(
        abs(v.x),
        abs(v.y),
        abs(v.z),
        abs(v.w)
    )
}
