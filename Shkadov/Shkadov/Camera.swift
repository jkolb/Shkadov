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

public class Camera {
    private var forward = float3(0.0, 0.0, 1.0)
    private var right = float3(1.0, 0.0, 0.0)
    private var position = float3(0.0, 0.0, -4.0)
    
    public private(set) var projectionMatrix: float4x4
    
    // SPACE = JUMP          = adjust Y position accordingly over time in a curve
    // SHIFT = MOVE DOWN     = - position Y
    // SPACE = MOVE UP       = + position Y
    // A     = MOVE LEFT     = - position in direction of right
    // D     = MOVE RIGHT    = + position in direction of right
    // S     = MOVE BACKWARD = - position in direction of forward
    // W     = MOVE FORWARD  = + position in direction of forward
    // MOUSE LEFT  = LOOK LEFT  = rotate forward left
    // MOUSE RIGHT = LOOK RIGHT = rotate forward right
    // MOUSE UP    = LOOK UP    = rotate forward up
    // MOUSE DOWN  = LOOK DOWN  = rotate forward down
    
    // ONE TOUCH DRAG LEFT  = LOOK LEFT
    // ONE TOUCH DRAG RIGHT = LOOK RIGHT
    // ONE TOUCH DRAG UP    = LOOK UP
    // ONE TOUCH DRAG DOWN  = LOOK DOWN
    // TWO TOUCH DRAG LEFT  = MOVE LEFT
    // TWO TOUCH DRAG RIGHT = MOVE RIGHT
    // TWO TOUCH DRAG UP    = MOVE UP
    // TWO TOUCH DRAG DOWN  = MOVE DOWN
    // PINCH IN   = MOVE FORWARD
    // PINCH OUT  = MOVE BACKWARD
    
    public func lookUpByAmount(amount: Angle) {
        forward = normalize(float3x3(angle: amount, axis: right) * forward)
    }
    
    public func lookRightByAmount(amount: Angle) {
        right = normalize(float3x3(angle: amount, axis: forward) * right)
    }
    
    public func moveForwardByAmount(amount: Float) {
        position = position + forward * amount
    }
    
    public func moveRightByAmount(amount: Float) {
        position = position + right * amount
    }
    
    public func moveUpByAmount(amount: Float) {
        position = position + float3(0.0, 1.0, 0.0) * amount
    }
    
    public var viewMatrix: float4x4 {
        let f = forward
        let s = right
        let u = cross(s, f)
        let p = position
        
        let column0 = float4(s.x, u.x, -f.x, 0.0)
        let column1 = float4(s.y, u.y, -f.y, 0.0)
        let column2 = float4(s.z, u.z, -f.z, 0.0)
        let column3 = float4(p.x, p.y, p.z, 1.0)
        
        return float4x4([column0, column1, column2, column3])
    }
    
    public init() {
        self.projectionMatrix = float4x4(fovy: Angle(degrees: 90.0), aspect: 1.0, zNear: 0.1, zFar: 100.0)
    }
    
    public func updateWithAspectRatio(aspectRatio: Float, fovy: Angle) {
        self.projectionMatrix = float4x4(fovy: fovy, aspect: aspectRatio, zNear: 0.1, zFar: 100.0)
    }
}
