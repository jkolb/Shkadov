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

public struct Transform3D : Equatable, CustomStringConvertible {
    public var scale: Vector3D
    public var rotation: Quaternion
    public var translation: Vector3D
    
    public init(translation: Vector3D = Vector3D(), rotation: Quaternion = Quaternion(), scale: Vector3D = Vector3D(1.0)) {
        self.scale = scale
        self.rotation = rotation
        self.translation = translation
    }
    
    public var isIdentity: Bool {
        return scale == Vector3D(1.0) && rotation == Quaternion() && translation == Vector3D()
    }
    
    public var hasScale: Bool {
        return scale != Vector3D(1.0)
    }
    
    public var hasRotation: Bool {
        return rotation != Quaternion()
    }
    
    public var hasTranslation: Bool {
        return translation != Vector3D()
    }

    public var description: String {
        return "{\(scale), \(rotation), \(translation)}"
    }
    
    public var inverse: Transform3D {
        return Transform3D(scale: 1.0 / scale, rotation: conjugate(rotation), translation: -translation)
    }
    
    public var matrix: Matrix4x4 {
        let r: Matrix3x3
        
        if hasRotation {
            r = rotation.matrix
        }
        else {
            r = Matrix3x3(1.0)
        }
        
        let sr: Matrix3x3
        
        if hasScale {
            let s = Matrix3x3(scale)
            sr = r * s
        }
        else {
            sr = r
        }
        
        let t = translation
        
        return Matrix4x4(
            Vector4D(sr[0], 0.0),
            Vector4D(sr[1], 0.0),
            Vector4D(sr[2], 0.0),
            Vector4D(t, 1.0)
        )
    }
    
    public var inverseMatrix: Matrix4x4 {
        let ri: Matrix3x3
        
        if hasRotation {
            ri = rotation.matrix.transpose
        }
        else {
            ri = Matrix3x3(1.0)
        }
        
        let sri: Matrix3x3
        
        if hasScale {
            let si = Matrix3x3(1.0 / scale)
            sri = si * ri
        }
        else {
            sri = ri
        }
        
        let ti:  Vector3D
        
        if hasTranslation {
            ti = sri * -translation
        }
        else {
            ti = Vector3D()
        }
        
        return Matrix4x4(
            Vector4D(sri[0], 0.0),
            Vector4D(sri[1], 0.0),
            Vector4D(sri[2], 0.0),
            Vector4D(ti, 1.0)
        )
    }
    
    public func applyTo(v: Vector3D) -> Vector3D {
        return v * scale * rotation + translation
    }
    
    public func applyTo(b: AABB) -> AABB {
        return AABB(containingPoints: b.corners.map({ applyTo($0) }))
    }
    
    public func applyTo(p: Plane) -> Plane {
        let pointOnPlane = p.normal * p.distanceToOrigin
        let transformedNormal = p.normal * rotation
        let transformedPoint = applyTo(pointOnPlane)
        let transformedDistance = dot(transformedNormal, transformedPoint)
        return Plane(normal: transformedNormal, distanceToOrigin: transformedDistance)
    }
    
    public func applyTo(f: Frustum) -> Frustum {
        return Frustum(
            top: applyTo(f.top),
            bottom: applyTo(f.bottom),
            right: applyTo(f.right),
            left: applyTo(f.left),
            near: applyTo(f.near),
            far: applyTo(f.far)
        )
    }
    
    public func applyTo(s: Sphere) -> Sphere {
        return Sphere(
            center: s.center + translation,
            radius: s.radius * scale.maximum
        )
    }
    
    public func applyTo(r: Ray3D) -> Ray3D {
        return Ray3D(origin: applyTo(r.origin), direction: r.direction * rotation)
    }
}

public func ==(lhs: Transform3D, rhs: Transform3D) -> Bool {
    return lhs.translation == rhs.translation && lhs.rotation == rhs.rotation && lhs.scale == rhs.scale
}

public func +(lhs: Transform3D, rhs: Transform3D) -> Transform3D {
    return Transform3D(
        scale: lhs.scale * rhs.scale,
        rotation: lhs.rotation * rhs.rotation,
        translation: lhs.rotation * rhs.translation * lhs.scale + lhs.translation
    )
}
