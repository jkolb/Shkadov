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

public struct Matrix2x2 : Equatable, CustomStringConvertible {
    public typealias ColType = Vector2D
    public typealias RowType = Vector2D
    
    private let col0, col1: ColType
    
    private var row0: RowType {
        return Vector2D(col0.x, col1.x)
    }
    
    private var row1: RowType {
        return Vector2D(col0.y, col1.y)
    }
    
    public init() {
        self.init(1.0)
    }
    
    public init(_ v: Float) {
        self.init(
            ColType(v, 0.0),
            ColType(0.0, v)
        )
    }
    
    public init(
        _ x0: Float, _ y0: Float,
        _ x1: Float, _ y1: Float
        )
    {
        self.init(
            ColType(x0, y0),
            ColType(x1, y1)
        )
    }
    
    public init(
        _ col0: ColType,
        _ col1: ColType
        )
    {
        self.col0 = col0
        self.col1 = col1
    }
    
    public subscript(index: Int) -> ColType {
        switch index {
        case 0:
            return col0
        case 1:
            return col1
        default:
            fatalError("Index out of range")
        }
    }
    
    public func col(index: Int) -> ColType {
        return self[index]
    }
    
    public func row(index: Int) -> RowType {
        switch index {
        case 0:
            return row0
        case 1:
            return row1
        default:
            fatalError("Index out of range")
        }
    }
    
    public var description: String {
        return "{\(col0), \(col1)}"
    }
}

// MARK: - Scalar Addition

public func +(lhs: Matrix2x2, rhs: Float) -> Matrix2x2 {
    return Matrix2x2(
        lhs.col0 + rhs,
        lhs.col1 + rhs
    )
}

public func +(lhs: Float, rhs: Matrix2x2) -> Matrix2x2 {
    return Matrix2x2(
        lhs + rhs.col0,
        lhs + rhs.col1
    )
}

// MARK: - Addition

public func +(lhs: Matrix2x2, rhs: Matrix2x2) -> Matrix2x2 {
    return Matrix2x2(
        lhs.col0 + rhs.col0,
        lhs.col1 + rhs.col1
    )
}

// MARK: - Scalar Subtraction

public func -(lhs: Matrix2x2, rhs: Float) -> Matrix2x2 {
    return Matrix2x2(
        lhs.col0 - rhs,
        lhs.col1 - rhs
    )
}

public func -(lhs: Float, rhs: Matrix2x2) -> Matrix2x2 {
    return Matrix2x2(
        lhs - rhs.col0,
        lhs - rhs.col1
    )
}

// MARK: - Subtraction

public func -(lhs: Matrix2x2, rhs: Matrix2x2) -> Matrix2x2 {
    return Matrix2x2(
        lhs.col0 - rhs.col0,
        lhs.col1 - rhs.col1
    )
}

// MARK: - Scalar Multiplication

public func *(lhs: Matrix2x2, rhs: Float) -> Matrix2x2 {
    return Matrix2x2(
        lhs.col0 * rhs,
        lhs.col1 * rhs
    )
}

public func *(lhs: Float, rhs: Matrix2x2) -> Matrix2x2 {
    return Matrix2x2(
        lhs * rhs.col0,
        lhs * rhs.col1
    )
}

// MARK: - Multiplication

public func *(m: Matrix2x2, v: Vector2D) -> Vector2D {
    let x = m.col0.x * v.x + m.col1.x * v.y
    let y = m.col0.y * v.x + m.col1.y * v.y
    return Vector2D(x, y)
}

public func *(v: Vector2D, m: Matrix2x2) -> Vector2D {
    let x = v.x * m.col0.x + v.y * m.col0.y
    let y = v.x * m.col1.x + v.y * m.col1.y
    return Vector2D(x, y)
}

public func *(m1: Matrix2x2, m2: Matrix2x2) -> Matrix2x2 {
    let a00 = m1.col0.x
    let a01 = m1.col0.y
    let a10 = m1.col1.x
    let a11 = m1.col1.y
    
    let b00 = m2.col0.x
    let b01 = m2.col0.y
    let b10 = m2.col1.x
    let b11 = m2.col1.y
    
    let x0 = a00 * b00 + a10 * b01
    let y0 = a01 * b00 + a11 * b01
    let x1 = a00 * b10 + a10 * b11
    let y1 = a01 * b10 + a11 * b11
    
    return Matrix2x2(
        x0, y0,
        x1, y1
    )
}

// MARK: - Scalar Division

public func /(lhs: Matrix2x2, rhs: Float) -> Matrix2x2 {
    return Matrix2x2(
        lhs.col0 / rhs,
        lhs.col1 / rhs
    )
}

public func /(lhs: Float, rhs: Matrix2x2) -> Matrix2x2 {
    return Matrix2x2(
        lhs / rhs.col0,
        lhs / rhs.col1
    )
}

// MARK: - Division

public func /(m: Matrix2x2, v: Vector2D) -> Vector2D {
    return inverse(m) * v
}

public func /(v: Vector2D, m: Matrix2x2) -> Vector2D {
    return v * inverse(m)
}

public func /(m1: Matrix2x2, m2: Matrix2x2) -> Matrix2x2 {
    return m1 * inverse(m2)
}

// MARK: - Inverse

public func inverse(m: Matrix2x2) -> Matrix2x2 {
    let a = m.col0.x
    let b = m.col1.x
    let c = m.col0.y
    let d = m.col1.y
    
    let ad = a * d
    let bc = b * c
    
    let oneOverDeterminant = 1 / (ad - bc)
    
    let x0 = +d * oneOverDeterminant
    let x1 = -b * oneOverDeterminant
    let y0 = -c * oneOverDeterminant
    let y1 = +a * oneOverDeterminant
    
    return Matrix2x2(
        x0, y0,
        x1, y1
    )
}

// MARK: - Negation

public prefix func -(m: Matrix2x2) -> Matrix2x2 {
    return Matrix2x2(
        -m.col0,
        -m.col1
    )
}

public prefix func +(m: Matrix2x2) -> Matrix2x2 {
    return m
}

// MARK: - Equatable

public func ==(va: Matrix2x2, vb: Matrix2x2) -> Bool {
    return va.col0 == vb.col0 && va.col1 == vb.col1
}

// MARK: Approximately Equal

public func approx(ma: Matrix2x2, _ mb: Matrix2x2, epsilon: Float = 1e-6) -> Bool {
    let a0 = approx(ma.col0, mb.col0, epsilon: epsilon)
    let a1 = approx(ma.col1, mb.col1, epsilon: epsilon)
    return a0 && a1
}
