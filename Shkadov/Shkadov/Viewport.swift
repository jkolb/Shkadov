//
//  Viewport.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/22/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import CoreGraphics

public struct Viewport {
    public let x: Int32
    public let y: Int32
    public let width: UInt16
    public let height: UInt16
    
    public init(x: Int32, y: Int32, width: UInt16, height: UInt16) {
        precondition(width > 0)
        precondition(height > 0)
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    public var aspectRatio: Float {
        return Float(width) / Float(height)
    }
}
