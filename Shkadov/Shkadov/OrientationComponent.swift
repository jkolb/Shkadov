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

import simd

public struct OrientationComponent : Component {
    public static let kind = Kind(value: OrientationComponent.self)
    public var position: float3
    public var forward: float3
    public var right: float3
    public var up: float3 {
        return cross(right, forward)
    }
    
    public init(position: float3 = float3(0.0, 0.0, 0.0), forward: float3 = float3(0.0, 0.0, 1.0), right: float3 = float3(1.0, 0.0, 0.0)) {
        self.position = position
        self.forward = forward
        self.right = right
    }
    
    public var lookAtMatrix: float4x4 {
        let f = forward
        let s = right
        let u = up
        let p = position
        
        let columnR0 = float4(s.x, u.x, -f.x, 0.0)
        let columnR1 = float4(s.y, u.y, -f.y, 0.0)
        let columnR2 = float4(s.z, u.z, -f.z, 0.0)
        let columnR3 = float4(0.0, 0.0, 0.0, 1.0)
        
        let rotation = float4x4([columnR0, columnR1, columnR2, columnR3])
        
        let columnT0 = float4(1.0, 0.0, 0.0, 0.0)
        let columnT1 = float4(0.0, 1.0, 0.0, 0.0)
        let columnT2 = float4(0.0, 0.0, 1.0, 0.0)
        let columnT3 = float4(-p.x, -p.y, -p.z, 1.0)
        
        let translation = float4x4([columnT0, columnT1, columnT2, columnT3])
        
        return rotation * translation
    }
    
    public var orientationMatrix: float4x4 {
        let f = forward
        let s = right
        let u = up
        let p = position
        
        let column0 = float4(s.x, u.x, -f.x, 0.0)
        let column1 = float4(s.y, u.y, -f.y, 0.0)
        let column2 = float4(s.z, u.z, -f.z, 0.0)
        let column3 = float4(p.x, p.y, p.z, 1.0)
        
        return float4x4([column0, column1, column2, column3])
    }
    
    public mutating func lookUpByAmount(amount: Angle) {
        forward = normalize(float3x3(angle: amount, axis: right) * forward)
    }
    
    public mutating func lookRightByAmount(amount: Angle) {
        let rotation = float3x3(angle: amount, axis: up)
        right = normalize(rotation * right)
        forward = normalize(rotation * forward)
    }
    
    public mutating func moveForwardByAmount(amount: Float) {
        position = position + forward * amount
    }
    
    public mutating func moveRightByAmount(amount: Float) {
        position = position + right * amount
    }
    
    public mutating func moveUpByAmount(amount: Float) {
        position = position + float3(0.0, 1.0, 0.0) * amount
    }
}
