//
//  OpenGLRenderer.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/20/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import AppKit
import OpenGL
import simd

public enum VertexAttribute : GLuint {
    case Position
    case Normal
    case Color
    case TexCoord0
    case TexCoord1
}

let UNIFORM_MODELVIEWPROJECTION_MATRIX = 0
let UNIFORM_NORMAL_MATRIX = 1
var uniforms = [GLint](count: 2, repeatedValue: 0)

var gCubeVertexData: [GLfloat] = [
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5, -0.5, -0.5,        1.0, 0.0, 0.0,
    0.5, 0.5, -0.5,         1.0, 0.0, 0.0,
    0.5, -0.5, 0.5,         1.0, 0.0, 0.0,
    0.5, -0.5, 0.5,         1.0, 0.0, 0.0,
    0.5, 0.5, -0.5,         1.0, 0.0, 0.0,
    0.5, 0.5, 0.5,          1.0, 0.0, 0.0,
    
    0.5, 0.5, -0.5,         0.0, 1.0, 0.0,
    -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,
    0.5, 0.5, 0.5,          0.0, 1.0, 0.0,
    0.5, 0.5, 0.5,          0.0, 1.0, 0.0,
    -0.5, 0.5, -0.5,        0.0, 1.0, 0.0,
    -0.5, 0.5, 0.5,         0.0, 1.0, 0.0,
    
    -0.5, 0.5, -0.5,        -1.0, 0.0, 0.0,
    -0.5, -0.5, -0.5,      -1.0, 0.0, 0.0,
    -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,
    -0.5, 0.5, 0.5,         -1.0, 0.0, 0.0,
    -0.5, -0.5, -0.5,      -1.0, 0.0, 0.0,
    -0.5, -0.5, 0.5,        -1.0, 0.0, 0.0,
    
    -0.5, -0.5, -0.5,      0.0, -1.0, 0.0,
    0.5, -0.5, -0.5,        0.0, -1.0, 0.0,
    -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,
    -0.5, -0.5, 0.5,        0.0, -1.0, 0.0,
    0.5, -0.5, -0.5,        0.0, -1.0, 0.0,
    0.5, -0.5, 0.5,         0.0, -1.0, 0.0,
    
    0.5, 0.5, 0.5,          0.0, 0.0, 1.0,
    -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         0.0, 0.0, 1.0,
    0.5, -0.5, 0.5,         0.0, 0.0, 1.0,
    -0.5, 0.5, 0.5,         0.0, 0.0, 1.0,
    -0.5, -0.5, 0.5,        0.0, 0.0, 1.0,
    
    0.5, -0.5, -0.5,        0.0, 0.0, -1.0,
    -0.5, -0.5, -0.5,      0.0, 0.0, -1.0,
    0.5, 0.5, -0.5,         0.0, 0.0, -1.0,
    0.5, 0.5, -0.5,         0.0, 0.0, -1.0,
    -0.5, -0.5, -0.5,      0.0, 0.0, -1.0,
    -0.5, 0.5, -0.5,        0.0, 0.0, -1.0
]

public final class OpenGLRenderer : Renderer {
    private let context: NSOpenGLContext
    private let queue: DispatchQueue
    
    var program: OpenGL.Program!
    
    var vertexArray: OpenGL.VertexArray!
    var vertexBuffer: OpenGL.VertexBuffer!
    
    
    public init(context: NSOpenGLContext) {
        self.context = context
        self.queue = DispatchQueue.queueWithName("net.franticapparatus.engine.render", attribute: .Serial)
    }
    
    deinit {
        if NSOpenGLContext.currentContext() === self.context {
            NSOpenGLContext.clearCurrentContext()
        }
    }
    
    public func configure() {
        queue.dispatchSerialized { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.context.makeCurrentContext()
            
            do {
                try strongSelf.loadShaders()
            }
            catch {
                NSLog("Error")
            }
            
            var swapInt: GLint = 1
            strongSelf.context.setValues(&swapInt, forParameter: .GLCPSwapInterval)
            
            OpenGL.viewport(0, y: 0, width: 800, height: 600)
            
            OpenGL.enableCapability(GL_DEPTH_TEST)
            
            strongSelf.vertexArray = OpenGL.VertexArray()
            strongSelf.vertexArray.bind()
            
            strongSelf.vertexBuffer = OpenGL.VertexBuffer()
            strongSelf.vertexBuffer.bindToTarget(GL_ARRAY_BUFFER)
            OpenGL.bufferDataForTarget(GL_ARRAY_BUFFER, size: sizeof(GLfloat) * gCubeVertexData.count, data: &gCubeVertexData, usage: GL_STATIC_DRAW)
            
            OpenGL.enableVertexAttributeArrayAtIndex(VertexAttribute.Position)
            OpenGL.vertexAttribPointerForIndex(VertexAttribute.Position, size: 3, type: GL_FLOAT, normalized: false, stride: 24, offset: 0)
            
            OpenGL.enableVertexAttributeArrayAtIndex(VertexAttribute.Normal)
            OpenGL.vertexAttribPointerForIndex(VertexAttribute.Normal, size: 3, type: GL_FLOAT, normalized: false, stride: 24, offset: 3 * sizeof(GLfloat))
            
            OpenGL.unbindVertexArray()
        }
    }
    
    func loadShaders() throws {
        let vertShader = try OpenGL.Shader(.Vertex)
        let fragShader = try OpenGL.Shader(.Fragment)
        
        // Create shader program.
        program = try OpenGL.Program()
        
        // Create and compile vertex shader.
        do {
            try vertShader.compile(NSBundle.mainBundle().pathForResource("Shader", ofType: "vsh")!)
        }
        catch OpenGL.Error.UnableToCompileShader(let message) {
            NSLog("Vertex: \(message)")
        }
        catch {
            NSLog("Vertex: \(error)")
        }

        do {
            try fragShader.compile(NSBundle.mainBundle().pathForResource("Shader", ofType: "fsh")!)
        }
        catch OpenGL.Error.UnableToCompileShader(let message) {
            NSLog("Fragment: \(message)")
        }
        catch {
            NSLog("Fragment: \(error)")
        }
        
        program.attachShader(vertShader)
        program.attachShader(fragShader)
        
        // Bind attribute locations.
        // This needs to be done prior to linking.
        program.bindAttributeLocations([
            "position": VertexAttribute.Position,
            "normal": VertexAttribute.Normal,
            ])
        
        do {
            try program.link()
        }
        catch OpenGL.Error.UnableToLinkProgram(let message) {
            NSLog("Link: \(message)")
        }
        catch {
            NSLog("Link: \(error)")
        }
        
        // Get uniform locations.
        uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = program.uniformLocationWithName("modelViewProjectionMatrix")
        uniforms[UNIFORM_NORMAL_MATRIX] = program.uniformLocationWithName("normalMatrix")
        
        program.detachShader(vertShader)
        program.detachShader(fragShader)
    }
    
    func validateProgram(prog: GLuint) -> Bool {
        var logLength: GLsizei = 0
        var status: GLint = 0
        
        glValidateProgram(prog)
        glGetProgramiv(prog, GLenum(GL_INFO_LOG_LENGTH), &logLength)
        if logLength > 0 {
            var log: [GLchar] = [GLchar](count: Int(logLength), repeatedValue: 0)
            glGetProgramInfoLog(prog, logLength, &logLength, &log)
            print("Program validate log: \n\(log)")
        }
        
        glGetProgramiv(prog, GLenum(GL_VALIDATE_STATUS), &status)
        var returnVal = true
        if status == 0 {
            returnVal = false
        }
        return returnVal
    }

    public func renderState(state: RenderState) {
        queue.dispatchSerialized { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.context.makeCurrentContext()
            
            OpenGL.clearColor(ColorRGBA8(red: 255, green: 165, blue: 165))
            OpenGL.clearMask(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
            
            strongSelf.program.use()
            
            strongSelf.vertexArray.bind()
            
            for object in state.objects {
                OpenGL.setUniformMatrix(object.modelViewProjectionMatrix, atLocation: uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX])
                OpenGL.setUniformMatrix(object.normalMatrix, atLocation: uniforms[UNIFORM_NORMAL_MATRIX])
                OpenGL.drawArraysWithMode(GL_TRIANGLES, first: 0, count: 36)
            }
            
            CGLFlushDrawable(strongSelf.context.CGLContextObj)
        }
    }
}
