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

public struct Matrix3x3 : Equatable, CustomStringConvertible {
    public typealias ColType = Vector3D
    public typealias RowType = Vector3D
    
    private let col0, col1, col2: ColType
    
    private var row0: RowType {
        return Vector3D(col0.x, col1.x, col2.x)
    }
    
    private var row1: RowType {
        return Vector3D(col0.y, col1.y, col2.y)
    }
    
    private var row2: RowType {
        return Vector3D(col0.z, col1.z, col2.z)
    }
    
    public init() {
        self.init(1.0)
    }
    
    public init(_ v: Float) {
        self.init(
            ColType(v, 0.0, 0.0),
            ColType(0.0, v, 0.0),
            ColType(0.0, 0.0, v)
        )
    }
    
    public init(_ d: Vector3D) {
        self.init(
            ColType(d.x, 0.0, 0.0),
            ColType(0.0, d.y, 0.0),
            ColType(0.0, 0.0, d.z)
        )
    }
    
    public init(
        _ x0: Float, _ y0: Float, _ z0: Float,
        _ x1: Float, _ y1: Float, _ z1: Float,
        _ x2: Float, _ y2: Float, _ z2: Float
        )
    {
        self.init(
            ColType(x0, y0, z0),
            ColType(x1, y1, z1),
            ColType(x2, y2, z2)
        )
    }
    
    public init(
        _ col0: ColType,
        _ col1: ColType,
        _ col2: ColType
        )
    {
        self.col0 = col0
        self.col1 = col1
        self.col2 = col2
    }
    
    public static func rotationMatrixWithAngle(angle: Angle, axis: Vector3D) -> Matrix3x3 {
        /*
        https://www.opengl.org/sdk/docs/man2/xhtml/glRotate.xml
        */
        let (s, c) = sincos(angle)
        let k = 1.0 - c
        
        let na = normalize(axis)
        let sa = s * na
        let ka = k * na
        
        let column0 = Vector3D(
            na.x * ka.x + c,
            na.y * ka.x + sa.z,
            na.x * ka.z - sa.y
        )
        let column1 = Vector3D(
            na.x * ka.y - sa.z,
            na.y * ka.y + c,
            na.y * ka.z + sa.x
        )
        let column2 = Vector3D(
            na.x * ka.z + sa.y,
            na.y * ka.z - sa.x,
            na.z * ka.z + c
        )
        
        return Matrix3x3(column0, column1, column2)
    }
    
    public subscript(index: Int) -> ColType {
        switch index {
        case 0:
            return col0
        case 1:
            return col1
        case 2:
            return col2
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
        case 2:
            return row2
        default:
            fatalError("Index out of range")
        }
    }
    
    public var transpose: Matrix3x3 {
        return Matrix3x3(row(0), row(1), row(2))
    }

    public var description: String {
        return "{\(col0), \(col1), \(col2)}"
    }
}

// MARK: - Scalar Addition

public func +(lhs: Matrix3x3, rhs: Float) -> Matrix3x3 {
    return Matrix3x3(
        lhs.col0 + rhs,
        lhs.col1 + rhs,
        lhs.col2 + rhs
    )
}

public func +(lhs: Float, rhs: Matrix3x3) -> Matrix3x3 {
    return Matrix3x3(
        lhs + rhs.col0,
        lhs + rhs.col1,
        lhs + rhs.col2
    )
}

// MARK: - Addition

public func +(lhs: Matrix3x3, rhs: Matrix3x3) -> Matrix3x3 {
    return Matrix3x3(
        lhs.col0 + rhs.col0,
        lhs.col1 + rhs.col1,
        lhs.col2 + rhs.col2
    )
}

// MARK: - Scalar Subtraction

public func -(lhs: Matrix3x3, rhs: Float) -> Matrix3x3 {
    return Matrix3x3(
        lhs.col0 - rhs,
        lhs.col1 - rhs,
        lhs.col2 - rhs
    )
}

public func -(lhs: Float, rhs: Matrix3x3) -> Matrix3x3 {
    return Matrix3x3(
        lhs - rhs.col0,
        lhs - rhs.col1,
        lhs - rhs.col2
    )
}

// MARK: - Subtraction

public func -(lhs: Matrix3x3, rhs: Matrix3x3) -> Matrix3x3 {
    return Matrix3x3(
        lhs.col0 - rhs.col0,
        lhs.col1 - rhs.col1,
        lhs.col2 - rhs.col2
    )
}

// MARK: - Scalar Multiplication

public func *(lhs: Matrix3x3, rhs: Float) -> Matrix3x3 {
    return Matrix3x3(
        lhs.col0 * rhs,
        lhs.col1 * rhs,
        lhs.col2 * rhs
    )
}

public func *(lhs: Float, rhs: Matrix3x3) -> Matrix3x3 {
    return Matrix3x3(
        lhs * rhs.col0,
        lhs * rhs.col1,
        lhs * rhs.col2
    )
}

// MARK: - Multiplication

public func *(m: Matrix3x3, v: Vector3D) -> Vector3D {
    let x = m.col0.x * v.x + m.col1.x * v.y + m.col2.x * v.z
    let y = m.col0.y * v.x + m.col1.y * v.y + m.col2.y * v.z
    let z = m.col0.z * v.x + m.col1.z * v.y + m.col2.z * v.z
    return Vector3D(x, y, z)
}

public func *(v: Vector3D, m: Matrix3x3) -> Vector3D {
    let x = m.col0.x * v.x + m.col0.y * v.y + m.col0.z * v.z
    let y = m.col1.x * v.x + m.col1.y * v.y + m.col1.z * v.z
    let z = m.col2.x * v.x + m.col2.y * v.y + m.col2.z * v.z
    return Vector3D(x, y, z)
}

public func *(m1: Matrix3x3, m2: Matrix3x3) -> Matrix3x3 {
    let a00 = m1.col0.x
    let a01 = m1.col0.y
    let a02 = m1.col0.z
    let a10 = m1.col1.x
    let a11 = m1.col1.y
    let a12 = m1.col1.z
    let a20 = m1.col2.x
    let a21 = m1.col2.y
    let a22 = m1.col2.z
    
    let b00 = m2.col0.x
    let b01 = m2.col0.y
    let b02 = m2.col0.z
    let b10 = m2.col1.x
    let b11 = m2.col1.y
    let b12 = m2.col1.z
    let b20 = m2.col2.x
    let b21 = m2.col2.y
    let b22 = m2.col2.z
    
    let x0 = a00 * b00 + a10 * b01 + a20 * b02
    let y0 = a01 * b00 + a11 * b01 + a21 * b02
    let z0 = a02 * b00 + a12 * b01 + a22 * b02
    let x1 = a00 * b10 + a10 * b11 + a20 * b12
    let y1 = a01 * b10 + a11 * b11 + a21 * b12
    let z1 = a02 * b10 + a12 * b11 + a22 * b12
    let x2 = a00 * b20 + a10 * b21 + a20 * b22
    let y2 = a01 * b20 + a11 * b21 + a21 * b22
    let z2 = a02 * b20 + a12 * b21 + a22 * b22
    
    return Matrix3x3(
        x0, y0, z0,
        x1, y1, z1,
        x2, y2, z2
    )
}

// MARK: - Scalar Division

public func /(lhs: Matrix3x3, rhs: Float) -> Matrix3x3 {
    return Matrix3x3(
        lhs.col0 / rhs,
        lhs.col1 / rhs,
        lhs.col2 / rhs
    )
}

public func /(lhs: Float, rhs: Matrix3x3) -> Matrix3x3 {
    return Matrix3x3(
        lhs / rhs.col0,
        lhs / rhs.col1,
        lhs / rhs.col2
    )
}

// MARK: - Division

public func /(m: Matrix3x3, v: Vector3D) -> Vector3D {
    return inverse(m) * v
}

public func /(v: Vector3D, m: Matrix3x3) -> Vector3D {
    return v * inverse(m)
}

public func /(m1: Matrix3x3, m2: Matrix3x3) -> Matrix3x3 {
    return m1 * inverse(m2)
}

// MARK: - Inverse

public func inverse(m: Matrix3x3) -> Matrix3x3 {
    let m00 = m.col0.x
    let m10 = m.col1.x
    let m20 = m.col2.x
    let m01 = m.col0.y
    let m11 = m.col1.y
    let m21 = m.col2.y
    let m02 = m.col0.z
    let m12 = m.col1.z
    let m22 = m.col2.z
    
    let a = +(m00 * (m11 * m22 - m21 * m12))
    let b = -(m10 * (m01 * m22 - m21 * m02))
    let c = +(m20 * (m01 * m12 - m11 * m02))
    
    let oneOverDeterminant = 1 / (a + b + c)
    
    let x0 = +(m11 * m22 - m21 * m12) * oneOverDeterminant
    let y0 = -(m10 * m22 - m20 * m12) * oneOverDeterminant
    let z0 = +(m10 * m21 - m20 * m11) * oneOverDeterminant
    let x1 = -(m01 * m22 - m21 * m02) * oneOverDeterminant
    let y1 = +(m00 * m22 - m20 * m02) * oneOverDeterminant
    let z1 = -(m00 * m21 - m20 * m01) * oneOverDeterminant
    let x2 = +(m01 * m12 - m11 * m02) * oneOverDeterminant
    let y2 = -(m00 * m12 - m10 * m02) * oneOverDeterminant
    let z2 = +(m00 * m11 - m10 * m01) * oneOverDeterminant
    
    return Matrix3x3(
        x0, y0, z0,
        x1, y1, z1,
        x2, y2, z2
    )
}

// MARK: - Negation

public prefix func -(m: Matrix3x3) -> Matrix3x3 {
    return Matrix3x3(
        -m.col0,
        -m.col1,
        -m.col2
    )
}

public prefix func +(m: Matrix3x3) -> Matrix3x3 {
    return m
}

// MARK: - Equatable

public func ==(va: Matrix3x3, vb: Matrix3x3) -> Bool {
    return va.col0 == vb.col0 && va.col1 == vb.col1 && va.col2 == vb.col2
}

// MARK: Approximately Equal

public func approx(ma: Matrix3x3, _ mb: Matrix3x3, epsilon: Float = 1e-6) -> Bool {
    let a0 = approx(ma.col0, mb.col0, epsilon: epsilon)
    let a1 = approx(ma.col1, mb.col1, epsilon: epsilon)
    let a2 = approx(ma.col2, mb.col2, epsilon: epsilon)
    return a0 && a1 && a2
}
