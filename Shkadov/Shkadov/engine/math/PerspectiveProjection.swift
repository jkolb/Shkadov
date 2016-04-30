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

/*
fovy	Specifies the field of view angle (in radians) in the y direction.
aspect	Indicates the aspect ratio. This value determines the field of view in the x direction and is the ratio of x (width) to y (height). x/y
zNear	Specifies the distance from the viewer to the closest clipping plane. This value must be positive. zNear must never be set to 0.
zFar	Specifies the distance from the viewer to the farthest clipping plane. This value must be positive.

Similar to gluPerspective: https://www.opengl.org/sdk/docs/man2/xhtml/gluPerspective.xml

Given: f = cotangent(fovy / 2)

(     f                                  )
|  ------   0       0            0       |
|  aspect                                |
|                                        |
|                                        |
|     0     f       0            0       |
|                                        |
|                                        |
|               zFar+zNear  2*zFar*zNear |
|     0     0   ----------  ------------ |
|               zNear-zFar   zNear-zFar  |
|                                        |
|                                        |
|     0     0      -1            0       |
(                                        )
*/
public struct PerspectiveProjection : Equatable {
    public var fovx: Angle {
        get {
            return Angle(radians: 2.0 * atan(tan(fovy * 0.5) * aspectRatio))
        }
        set {
            fovy = Angle(radians: 2.0 * atan(tan(newValue * 0.5) * inverseAspectRatio))
        }
    }
    public var fovy: Angle
    public var aspectRatio: Float
    public var inverseAspectRatio: Float {
        get {
            return 1.0 / aspectRatio;
        }
        set {
            aspectRatio = 1.0 / newValue
        }
    }
    public var zNear: Float
    public var zFar: Float
    
    public init() {
        self.init(fovy: Angle(degrees: 90.0), aspectRatio: 1.0, zNear: 1.0, zFar: 10_000.0)
    }

    public init(fovx: Angle, aspectRatio: Float, zNear: Float, zFar: Float) {
        self.init(
            fovy: Angle(radians: 2.0 * atan(tan(fovx * 0.5) * (1.0 / aspectRatio))),
            aspectRatio: aspectRatio,
            zNear: zNear,
            zFar: zFar
        )
    }
    
    public init(fovy: Angle, aspectRatio: Float, zNear: Float, zFar: Float) {
        precondition(fovy > Angle(degrees: 0.0))
        precondition(fovy <= Angle(degrees: 179.0))
        precondition(aspectRatio > 0.0)
        precondition(zNear > 0.0)
        precondition(zFar > zNear)
        self.fovy = fovy
        self.aspectRatio = aspectRatio
        self.zNear = zNear
        self.zFar = zFar
    }
    
    public var matrix: Matrix4x4 {
        let x = 0.5 * fovy
        let (s, c) = sincos(x)
        
        // cotangent(x) = cos(x) / sin(x)
        let f = c / s
        
        let col0 = Vector4D(
            f / aspectRatio,
            0.0,
            0.0,
            0.0
        )
        let col1 = Vector4D(
            0.0,
            f,
            0.0,
            0.0
        )
        let col2 = Vector4D(
            0.0,
            0.0,
            (zFar + zNear) / (zNear - zFar),
            -1.0
        )
        let col3 = Vector4D(
            0.0,
            0.0,
            (2.0 * zFar * zNear) / (zNear - zFar),
            0.0
        )
        
        return Matrix4x4(col0, col1, col2, col3)
    }
    
    public var frustum: Frustum {
        // Pointing down the -Z axis, camera frustum in world space using a right handed coordinate system
        let (sy, cy) = sincos(fovy * 0.5)
        let (sx, cx) = sincos(fovx * 0.5)
        
        return Frustum(
            top:  Plane(normal: Vector3D(0.0, -cy, -sy), distanceToOrigin: 0.0),
            bottom: Plane(normal: Vector3D(0.0, +cy, -sy), distanceToOrigin: 0.0),
            right: Plane(normal: Vector3D(-cx, 0.0, -sx), distanceToOrigin: 0.0),
            left: Plane(normal: Vector3D(+cx, 0.0, -sx), distanceToOrigin: 0.0),
            near: Plane(normal: Vector3D(0.0, 0.0, -1.0), distanceToOrigin: +zNear),
            far: Plane(normal: Vector3D(0.0, 0.0, +1.0), distanceToOrigin: -zFar)
        )
    }
}

public func ==(lhs: PerspectiveProjection, rhs: PerspectiveProjection) -> Bool {
    return lhs.fovy == rhs.fovy && lhs.aspectRatio == rhs.aspectRatio && lhs.zNear == rhs.zNear && lhs.zFar == rhs.zFar
}
