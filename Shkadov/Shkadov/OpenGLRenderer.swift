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

import AppKit
import OpenGL
import OpenGL.GL3
import simd

let UNIFORM_MODELVIEWPROJECTION_MATRIX = 0
let UNIFORM_NORMAL_MATRIX = 1
var uniforms = [GLint](count: 2, repeatedValue: 0)

public final class OpenGLRenderer : Renderer, Synchronizable {
    public let synchronizationQueue: DispatchQueue
    public var viewport: Rectangle2D
    public weak var context: OpenGLContext!
    private var program: OpenGL.Program!
    private var vertexArray: OpenGL.VertexArray!
    private var vertexBuffer: OpenGL.VertexBuffer!
    private var mesh: Mesh!
    
    public init(context: OpenGLContext) {
        self.context = context
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.render", attribute: .Serial)
        self.viewport = Rectangle2D.zero
        
        var vertexDescriptor = VertexDescriptor()
        vertexDescriptor.addAttribute(.Position, format: .Float3)
        vertexDescriptor.addAttribute(.Normal, format: .Float3)
        vertexDescriptor.addAttribute(.Color, format: .Float4)
        self.mesh = Mesh(vertexDescriptor: vertexDescriptor)
        
        self.mesh.addCubeWithSize(1.0, color: ColorRGBA8(red: 20, green: 50, blue: 150))
    }
    
    deinit {
        if NSOpenGLContext.currentContext() === self.context {
            NSOpenGLContext.clearCurrentContext()
        }
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        synchronizeWriteAndWait { renderer in
            renderer.context.lock()
            renderer.context.update()
            renderer.context.makeCurrent()
            
            renderer.viewport = viewport
            OpenGL.viewport(viewport)
            
            renderer.context.unlock()
        }
    }

    public func configure() {
        synchronizeWriteAndWait { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            #if DEBUG
                print("Vendor: \(OpenGL.vendor)")
                print("Renderer: \(OpenGL.renderer)")
                print("Version: \(OpenGL.version)")
            #endif
            
            do {
                try renderer.loadShaders()
            }
            catch {
                NSLog("Error")
            }

            renderer.context.swapInterval = 1
            
            OpenGL.enableCapability(GL_DEPTH_TEST)
            
            renderer.vertexArray = OpenGL.VertexArray()
            renderer.vertexArray.bind()
            
            renderer.vertexBuffer = OpenGL.VertexBuffer()
            renderer.vertexBuffer.bindToTarget(GL_ARRAY_BUFFER)
            
            let vertexDescriptor = renderer.mesh.vertexDescriptor

            OpenGL.bufferDataForTarget(GL_ARRAY_BUFFER, size: vertexDescriptor.size * renderer.mesh.data.count, data: &renderer.mesh.data, usage: GL_STATIC_DRAW)

            for attribute in vertexDescriptor.attributes {
                let format = vertexDescriptor.formatForAttribute(attribute)
                let offset = vertexDescriptor.offsetForAttribute(attribute)
                let dataType: Int32
                
                switch format.kind {
                case Float.kind:
                    dataType = GL_FLOAT
                default:
                    fatalError("Unknown kind \(format.kind)")
                }
                
                OpenGL.enableVertexAttributeArrayAtIndex(attribute)
                OpenGL.vertexAttribPointerForIndex(attribute, size: format.count, type: dataType, normalized: false, stride: vertexDescriptor.size, offset: offset)
            }
            
//            OpenGL.bufferDataForTarget(GL_ARRAY_BUFFER, size: sizeof(UInt32) * renderer.mesh.data.count, data: &renderer.mesh.data, usage: GL_STATIC_DRAW)
//
//            OpenGL.enableVertexAttributeArrayAtIndex(VertexAttribute.Position)
//            OpenGL.vertexAttribPointerForIndex(VertexAttribute.Position, size: 3, type: GL_FLOAT, normalized: false, stride: renderer.mesh.stride, offset: 0)
//            
//            OpenGL.enableVertexAttributeArrayAtIndex(VertexAttribute.Normal)
//            OpenGL.vertexAttribPointerForIndex(VertexAttribute.Normal, size: 3, type: GL_FLOAT, normalized: false, stride: renderer.mesh.stride, offset: 3 * sizeof(GLfloat))
//            
//            OpenGL.enableVertexAttributeArrayAtIndex(VertexAttribute.Color)
//            OpenGL.vertexAttribPointerForIndex(VertexAttribute.Color, size: 4, type: GL_FLOAT, normalized: false, stride: renderer.mesh.stride, offset: 3 * sizeof(GLfloat) * 2)
            
            OpenGL.unbindVertexArray()
            
            renderer.context.unlock()
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
            "color": VertexAttribute.Color,
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
        synchronizeWriteAndWait { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()

            OpenGL.clearColor(ColorRGBA8(red: 255, green: 165, blue: 165))
            OpenGL.clearMask(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
            
            renderer.program.use()
            
            renderer.vertexArray.bind()
            
            for object in state.objects {
                OpenGL.setUniformMatrix(object.modelViewProjectionMatrix, atLocation: uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX])
                OpenGL.setUniformMatrix(object.normalMatrix, atLocation: uniforms[UNIFORM_NORMAL_MATRIX])
                OpenGL.drawArraysWithMode(GL_TRIANGLES, first: 0, count: 36)
            }
            
            renderer.context.flush()
            renderer.context.unlock()
        }
    }
}
