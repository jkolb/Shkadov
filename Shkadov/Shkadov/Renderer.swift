//
//  Renderer.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/22/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

public protocol Renderer {
    func configure()
    func renderState(state: RenderState)
}
