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

public struct OrientationComponent : Component {
    public static let kind = Kind(dataType: OrientationComponent.self)
    public let position: Point3D
    public let pitch: Angle // Up/Down
    public let yaw: Angle // Right/Left
    
    public init(
        position: Point3D = Point3D(),
        pitch: Angle = Angle(),
        yaw: Angle = Angle()
    ) {
        self.position = position
        self.pitch = pitch
        self.yaw = yaw
    }
    
    public var inverseTransform: Matrix4x4 {
        let f = normalize(rotation * Vector3D.zAxis)
        let s = normalize(rotation * Vector3D.xAxis)
        let u = normalize(cross(f, s))
        let r = Matrix3x3([s, u, -f])
        let t = r * -Vector3D(position.x, position.y, position.z)
        
        let column0 = Vector4D(r[0], 0.0)
        let column1 = Vector4D(r[1], 0.0)
        let column2 = Vector4D(r[2], 0.0)
        let column3 = Vector4D(t, 1.0)
        
        return Matrix4x4([column0, column1, column2, column3])
    }
    
    public var transform: Matrix4x4 {
        let f = normalize(rotation * Vector3D.zAxis)
        let s = normalize(rotation * Vector3D.xAxis)
        let u = normalize(cross(f, s))
        let r = Matrix3x3([s, u, -f]).transpose
        let t = Vector3D(position.x, position.y, position.z)
        
        let column0 = Vector4D(r[0], 0.0)
        let column1 = Vector4D(r[1], 0.0)
        let column2 = Vector4D(r[2], 0.0)
        let column3 = Vector4D(t, 1.0)
        
        return Matrix4x4([column0, column1, column2, column3])
    }
    
    public var rotation: Matrix3x3 {
        let yawMatrix = Matrix3x3(angle: yaw, axis: Vector3D.yAxis)
        let pitchMatrix = Matrix3x3(angle: pitch, axis: Vector3D.xAxis)
        return pitchMatrix * yawMatrix
    }
}
