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

public struct Vector2D : Equatable, CustomStringConvertible {
    public var x, y: Float
    
    public init() {
        self.init(0.0, 0.0)
    }
    
    public init(_ v: Float) {
        self.init(v, v)
    }
    
    public init(_ x: Float, _ y: Float) {
        self.x = x
        self.y = y
    }
    
    public var components: [Float] {
        return [x, y]
    }
    
    public subscript(index: Int) -> Float {
        get {
            switch index {
            case 0:
                return x
            case 1:
                return y
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
            default:
                fatalError("Index out of range")
            }
        }
    }
    
    public var maximum: Float {
        return max(x, y)
    }
    
    public var description: String {
        return "{\(x), \(y)}"
    }
    
    public var angle: Angle {
        return atan2(self)
    }
}

// MARK: - Scalar Addition

public func +(lhs: Vector2D, rhs: Float) -> Vector2D {
    return Vector2D(
        lhs.x + rhs,
        lhs.y + rhs
    )
}

public func +(lhs: Float, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs + rhs.x,
        lhs + rhs.y
    )
}

// MARK: - Addition

public func +(lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs.x + rhs.x,
        lhs.y + rhs.y
    )
}

// MARK: - Scalar Subtraction

public func -(lhs: Vector2D, rhs: Float) -> Vector2D {
    return Vector2D(
        lhs.x - rhs,
        lhs.y - rhs
    )
}

public func -(lhs: Float, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs - rhs.x,
        lhs - rhs.y
    )
}

// MARK: - Subtraction

public func -(lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs.x - rhs.x,
        lhs.y - rhs.y
    )
}

// MARK: - Scalar Multiplication

public func *(lhs: Vector2D, rhs: Float) -> Vector2D {
    return Vector2D(
        lhs.x * rhs,
        lhs.y * rhs
    )
}

public func *(lhs: Float, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs * rhs.x,
        lhs * rhs.y
    )
}

// MARK: - Multiplication

public func *(lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs.x * rhs.x,
        lhs.y * rhs.y
    )
}

// MARK: - Scalar Division

public func /(lhs: Vector2D, rhs: Float) -> Vector2D {
    return Vector2D(
        lhs.x / rhs,
        lhs.y / rhs
    )
}

public func /(lhs: Float, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs / rhs.x,
        lhs / rhs.y
    )
}

// MARK: - Division

public func /(lhs: Vector2D, rhs: Vector2D) -> Vector2D {
    return Vector2D(
        lhs.x / rhs.x,
        lhs.y / rhs.y
    )
}

// MARK: - Negation

public prefix func -(v: Vector2D) -> Vector2D {
    return Vector2D(
        -v.x,
        -v.y
    )
}

public prefix func +(v: Vector2D) -> Vector2D {
    return v
}

// MARK: - Component Sum

public func sum(vector: Vector2D) -> Float {
    return vector.x + vector.y
}

// MARK: - Length Squared

public func length2(vector: Vector2D) -> Float {
    return sum(vector * vector)
}

// MARK: - Length

public func length(vector: Vector2D) -> Float {
    return sqrt(length2(vector))
}

// MARK: - Normalization

public func normalize(vector: Vector2D) -> Vector2D {
    return vector * (1.0 / length(vector))
}

// MARK: - Distance Squared

public func distance2(va: Vector2D, _ vb: Vector2D) -> Float {
    let difference = vb - va
    return sum(difference * difference)
}

// MARK: - Distance

public func distance(va: Vector2D, _ vb: Vector2D) -> Float {
    return sqrt(distance2(va, vb))
}

// MARK: - Dot Product

public func dot(va: Vector2D, _ vb: Vector2D) -> Float {
    return sum(va * vb)
}

// MARK: - Equatable

public func ==(va: Vector2D, vb: Vector2D) -> Bool {
    return va.x == vb.x && va.y == vb.y
}

// MARK: - Approximately Equal

public func approx(va: Vector2D, _ vb: Vector2D, epsilon: Float = 1e-6) -> Bool {
    let dX = va.x.distanceTo(vb.x)
    let dY = va.y.distanceTo(vb.y)
    let aX = abs(dX) <= epsilon
    let aY = abs(dY) <= epsilon
    return aX && aY
}

// MARK: - Absolute Value

public func abs(v: Vector2D) -> Vector2D {
    return Vector2D(
        abs(v.x),
        abs(v.y)
    )
}
