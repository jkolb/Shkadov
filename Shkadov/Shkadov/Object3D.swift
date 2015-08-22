//
//  Object3D.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/22/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import simd

public class Object3D {
    private var forward = float3(0.0, 0.0, 1.0)
    private var right = float3(1.0, 0.0, 0.0)
    private var position = float3(0.0, 0.0, -4.0)
    
    public var modelViewMatrix = float4x4(1.0)
    public var modelViewProjectionMatrix = float4x4(1.0)
    
    public init(position: float3) {
        self.position = position
    }
    
    public func lookUpByAmount(amount: Angle) {
        forward = float3x3(angle: amount, axis: right) * forward
    }
    
    public func lookRightByAmount(amount: Angle) {
        right = float3x3(angle: amount, axis: forward) * right
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
    
    public var normalMatrix: float4x4 {
        return modelViewMatrix.inverse.transpose;
    }
    
    public var modelMatrix: float4x4 {
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
}
