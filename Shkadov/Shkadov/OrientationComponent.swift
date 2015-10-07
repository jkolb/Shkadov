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
    
    public var lookAtMatrix: Matrix4x4 {
        let a = angleMatrix()
        let f = normalize(a * Vector3D(0.0, 0.0, 1.0))
        let s = normalize(a * Vector3D(1.0, 0.0, 0.0))
        let u = normalize(cross(f, s))
        let p = position
        
        let columnR0 = Vector4D(s.x, u.x, -f.x, 0.0)
        let columnR1 = Vector4D(s.y, u.y, -f.y, 0.0)
        let columnR2 = Vector4D(s.z, u.z, -f.z, 0.0)
        let columnR3 = Vector4D(0.0, 0.0, 0.0, 1.0)
        
        let rotation = Matrix4x4([columnR0, columnR1, columnR2, columnR3])
        
        let columnT0 = Vector4D(1.0, 0.0, 0.0, 0.0)
        let columnT1 = Vector4D(0.0, 1.0, 0.0, 0.0)
        let columnT2 = Vector4D(0.0, 0.0, 1.0, 0.0)
        let columnT3 = Vector4D(-p.x, -p.y, -p.z, 1.0)
        
        let translation = Matrix4x4([columnT0, columnT1, columnT2, columnT3])
        
        return rotation * translation
    }
    
    public var orientationMatrix: Matrix4x4 {
        let a = angleMatrix()
        let f = normalize(a * Vector3D(0.0, 0.0, 1.0))
        let s = normalize(a * Vector3D(1.0, 0.0, 0.0))
        let u = normalize(cross(f, s))
        let p = position
        
        let column0 = Vector4D(s.x, u.x, -f.x, 0.0)
        let column1 = Vector4D(s.y, u.y, -f.y, 0.0)
        let column2 = Vector4D(s.z, u.z, -f.z, 0.0)
        let column3 = Vector4D(p.x, p.y, p.z, 1.0)
        
        return Matrix4x4([column0, column1, column2, column3])
    }
    
    public func angleMatrix() -> Matrix3x3 {
        let yawMatrix = Matrix3x3(angle: yaw, axis: Vector3D(0.0, 1.0, 0.0))
        let pitchMatrix = Matrix3x3(angle: pitch, axis: yawMatrix * Vector3D(1.0, 0.0, 0.0))
        let a = pitchMatrix * yawMatrix
        return a
    }
    
    public func moveForwardByAmount(amount: Float) -> OrientationComponent {
        let yawMatrix = Matrix3x3(angle: yaw, axis: Vector3D(0.0, 1.0, 0.0))
        let forward = normalize(yawMatrix * Vector3D(0.0, 0.0, 1.0))
        return OrientationComponent(position: position + forward * amount, pitch: pitch, yaw: yaw)
    }
    
    public func moveRightByAmount(amount: Float) -> OrientationComponent {
        let yawMatrix = Matrix3x3(angle: yaw, axis: Vector3D(0.0, 1.0, 0.0))
        let right = normalize(yawMatrix * Vector3D(1.0, 0.0, 0.0))
        return OrientationComponent(position: position + right * amount, pitch: pitch, yaw: yaw)
    }
    
    public func moveUpByAmount(amount: Float) -> OrientationComponent {
        return OrientationComponent(position: position + Vector3D(0.0, 1.0, 0.0) * amount, pitch: pitch, yaw: yaw)
    }
}
