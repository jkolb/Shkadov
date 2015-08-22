//
//  RenderState.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/22/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

public struct RenderState {
    public let objects: [RenderObject]
    
    public init(objects: [RenderObject]) {
        self.objects = objects
    }
}
