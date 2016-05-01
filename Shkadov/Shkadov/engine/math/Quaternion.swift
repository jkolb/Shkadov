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

public struct Quaternion : Equatable, CustomStringConvertible {
    public static let identity = Quaternion(1.0, Vector3D.zero)
    public let w: Float
    public let xyz: Vector3D
    
    public init(_ w: Float, _ x: Float, _ y: Float, _ z: Float) {
        self.init(w, Vector3D(x, y, z))
    }

    public init(_ w: Float, _ xyz: Vector3D) {
        self.w = w
        self.xyz = xyz
    }

    public static func axis(axis: Vector3D, angle: Angle) -> Quaternion {
        let halfAngle = angle * 0.5
        return Quaternion(cos(halfAngle), sin(halfAngle) * axis)
    }

    public var description: String {
        return "{\(w), \(xyz)}"
    }
    
    public var matrix: Matrix3x3 {
        let v = xyz
        let twoWV = 2.0 * (w * v)
        let twoV2 = 2.0 * (v * v)
        let twoXY = 2.0 * (v.x * v.y)
        let twoXZ = 2.0 * (v.x * v.z)
        let twoYZ = 2.0 * (v.y * v.z)
        
        let col0 = Vector3D(1.0 - twoV2.y - twoV2.z, twoXY + twoWV.z, twoXZ - twoWV.y)
        let col1 = Vector3D(twoXY - twoWV.z, 1.0 - twoV2.x - twoV2.z, twoYZ + twoWV.x)
        let col2 = Vector3D(twoXZ + twoWV.y, twoYZ - twoWV.x, 1.0 - twoV2.x - twoV2.y)
        
        return Matrix3x3(col0, col1, col2)
    }
}

// MARK: - Equatable

public func ==(va: Quaternion, vb: Quaternion) -> Bool {
    return va.w == vb.w && va.xyz == vb.xyz
}

// MARK: - Addition

public func +(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    return Quaternion(lhs.w + rhs.w, lhs.xyz + rhs.xyz)
}

// MARK: - Subtraction

public func -(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    return Quaternion(lhs.w - rhs.w, lhs.xyz - rhs.xyz)
}

// MARK: - Multiplication

public func *(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
    let ps = lhs.w
    let pv = lhs.xyz
    let qs = rhs.w
    let qv = rhs.xyz
    let s = ps * qs - dot(pv, qv)
    let v = cross(pv, qv) + ps * qv + qs * pv
    return Quaternion(s, v)
}

// MARK: - Scalar Multiplication

public func *(lhs: Float, rhs: Quaternion) -> Quaternion {
    return Quaternion(lhs * rhs.w, lhs * rhs.xyz)
}

public func *(lhs: Quaternion, rhs: Float) -> Quaternion {
    return Quaternion(lhs.w * rhs, lhs.xyz * rhs)
}

// MARK: - Rotation

public func *(q: Quaternion, r: Vector3D) -> Vector3D {
    let qXr = cross(q.xyz, r)
    let twoQ = 2.0 * q
    return r + twoQ.w * qXr + cross(twoQ.xyz, qXr)
}

public func *(r: Vector3D, q: Quaternion) -> Vector3D {
    let qXr = cross(q.xyz, r)
    let twoQ = 2.0 * q
    return r + twoQ.w * qXr + cross(twoQ.xyz, qXr)
}

// MARK: Conjugate

public func conjugate(q: Quaternion) -> Quaternion {
    return Quaternion(q.w, -q.xyz)
}

// MARK: Dot Product

public func dot(lhs: Quaternion, _ rhs: Quaternion) -> Float {
    return lhs.w * rhs.w + dot(lhs.xyz, rhs.xyz)
}

// MARK: Length Squared

public func length2(q: Quaternion) -> Float {
    return q.w * q.w + sum(q.xyz * q.xyz)
}

// MARK: Length

public func length(q: Quaternion) -> Float {
    return sqrt(length2(q))
}

// MARK: Normalize

public func normalize(q: Quaternion) -> Quaternion {
    return q * (1.0 / length(q))
}
