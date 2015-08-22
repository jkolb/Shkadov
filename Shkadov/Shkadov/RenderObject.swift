//
//  RenderObject.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/22/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import simd

public struct RenderObject {
    public let modelViewProjectionMatrix: float4x4
    public let normalMatrix: float4x4
    
    public init(modelViewProjectionMatrix: float4x4, normalMatrix: float4x4) {
        self.modelViewProjectionMatrix = modelViewProjectionMatrix
        self.normalMatrix = normalMatrix
    }
}
