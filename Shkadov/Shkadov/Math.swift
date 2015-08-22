//
//  Math.swift
//  iOSOpenGLTemplate2
//
//  Created by Justin Kolb on 8/15/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import simd

public extension Float {
    public static var pi: Float {
        return Float(M_PI)
    }
}

public struct Angle {
    private static let degreesToRadians = (1.0 / 180.0) * Float.pi
    
    private let value: Float
    
    public init(radians: Float) {
        self.value = radians;
    }
    
    public init(degrees: Float) {
        self.init(radians: Angle.degreesToRadians * degrees)
    }
    
    public var radians: Float {
        return value
    }
    
    public var degrees: Float {
        return value
    }
}

public extension float4 {
    public init(_ v: float3, _ w: Float = 0.0) {
        self.init(v.x, v.y, v.z, w)
    }
    
    public var xyz: float3 {
        return float3(self.x, self.y, self.z)
    }
}

public extension float3x3 {
    public init(angle: Angle, axis: float3) {
        /*
        https://www.opengl.org/sdk/docs/man2/xhtml/glRotate.xml
        */
        var c: Float = 0.0
        var s: Float = 0.0
        __sincosf(angle.radians, &s, &c)
        
        let k = 1.0 - c
        
        let na = normalize(axis)
        let sa = s * na
        let ka = k * na
        
        let column0 = float3(
            na.x * ka.x + c,
            na.y * ka.x + sa.z,
            na.x * ka.z - sa.y
        )
        let column1 = float3(
            na.x * ka.y - sa.z,
            na.y * ka.y + c,
            na.y * ka.z + sa.x
        )
        let column2 = float3(
            na.x * ka.z + sa.y,
            na.y * ka.z - sa.x,
            na.z * ka.z + c
        )
        
        self.init([column0, column1, column2])
    }
}

public extension float4x4 {
    public init(translate: float3) {
        /*
        https://www.opengl.org/sdk/docs/man2/xhtml/glTranslate.xml
        */
        let column0 = float4(
            1.0,
            0.0,
            0.0,
            0.0
        )
        let column1 = float4(
            0.0,
            1.0,
            0.0,
            0.0
        )
        let column2 = float4(
            0.0,
            0.0,
            1.0,
            0.0
        )
        let column3 = float4(
            translate.x,
            translate.y,
            translate.z,
            1.0
        )
        
        self.init([column0, column1, column2, column3])
    }
    
    public init(angle: Angle, axis: float3) {
        /*
        https://www.opengl.org/sdk/docs/man2/xhtml/glRotate.xml
        */
        var c: Float = 0.0
        var s: Float = 0.0
        __sincosf(angle.radians, &s, &c)
        
        let k = 1.0 - c
        
        let na = normalize(axis)
        let sa = s * na
        let ka = k * na
        
        let column0 = float4(
            na.x * ka.x + c,
            na.y * ka.x + sa.z,
            na.x * ka.z - sa.y,
            0.0
        )
        let column1 = float4(
            na.x * ka.y - sa.z,
            na.y * ka.y + c,
            na.y * ka.z + sa.x,
            0.0
        )
        let column2 = float4(
            na.x * ka.z + sa.y,
            na.y * ka.z - sa.x,
            na.z * ka.z + c,
            0.0
        )
        let column3 = float4(
            0.0,
            0.0,
            0.0,
            1.0
        )
        
        self.init([column0, column1, column2, column3])
    }
    
    public init(fovy: Angle, aspect: Float, zNear: Float, zFar: Float) {
        precondition(fovy.radians > 0.0)
        precondition(fovy.radians < 2.0 * Float.pi)
        precondition(aspect != 0.0)
        precondition(zNear > 0.0)
        precondition(zFar > zNear)
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
        var s: Float = 0.0
        var c: Float = 0.0
        let x = 0.5 * fovy.radians
        __sincosf(x, &s, &c)
        
        // cotangent(x) = cos(x) / sin(x)
        let f = c / s
        
        let column0 = float4(
            f / aspect,
            0.0,
            0.0,
            0.0
        )
        let column1 = float4(
            0.0,
            f,
            0.0,
            0.0
        )
        let column2 = float4(
            0.0,
            0.0,
            (zFar + zNear) / (zNear - zFar),
            -1.0
        )
        let column3 = float4(
            0.0,
            0.0,
            (2.0 * zFar * zNear) / (zNear - zFar),
            0.0
        )
        
        self.init([column0, column1, column2, column3])
    }
    
    public var matrix3x3: float3x3 {
        return float3x3([self[0].xyz, self[1].xyz, self[2].xyz])
    }
}
