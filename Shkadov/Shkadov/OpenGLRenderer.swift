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
let UNIFORM_DIFFUSE_COLOR = 2
var uniforms = [GLint](count: 3, repeatedValue: 0)

public final class OpenGLRenderer : Renderer, Synchronizable {
    public let synchronizationQueue: DispatchQueue
    public var viewport: Rectangle2D
    public weak var context: OpenGLContext!
    private let textureHandleFactory = HandleFactory()
    private var textures: [Handle : OpenGL.Texture]
    private let bufferHandleFactory = HandleFactory()
    private var buffers: [Handle : OpenGL.VertexArray]
    private let programHandleFactory = HandleFactory()
    private var programs: [Handle : OpenGL.Program]
    
    public init(context: OpenGLContext) {
        self.context = context
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.render", attribute: .Serial)
        self.viewport = Rectangle2D.zero
        self.textures = Dictionary<Handle, OpenGL.Texture>()
        self.buffers = Dictionary<Handle, OpenGL.VertexArray>()
        self.programs = Dictionary<Handle, OpenGL.Program>()
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

    public func createTextureFromData(textureData: TextureData) -> Handle {
        return synchronizeReadWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()

            let handle = renderer.textureHandleFactory.nextHandle()
            let texture = OpenGL.Texture()
            renderer.textures[handle] = texture
            texture.bind2D()
            texture.data2D(textureData.size.width, height: textureData.size.height, pixels: textureData.rawData)
            
            renderer.context.unlock()
            
            return handle
        }
    }

    public func destroyTexture(handle: Handle) {
        synchronizeWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            renderer.textures.removeValueForKey(handle)
            
            renderer.context.unlock()
        }
    }
    
    public func createBufferFromDescriptor(vertexDescriptor: VertexDescriptor, buffer: ByteBuffer) -> Handle {
        return synchronizeReadWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            let handle = renderer.bufferHandleFactory.nextHandle()

            let vertexArray = OpenGL.VertexArray()
            vertexArray.bind()
            
            let vertexBuffer = OpenGL.VertexBuffer()
            vertexBuffer.bindToTarget(GL_ARRAY_BUFFER)
            
            vertexArray.addBuffer(vertexBuffer)
            
            OpenGL.bufferDataForTarget(GL_ARRAY_BUFFER, size: buffer.capacity, data: buffer.data, usage: GL_STATIC_DRAW)
            
            let dataTypes = [
                Int8.kind : GL_BYTE,
                UInt8.kind : GL_UNSIGNED_BYTE,
                Int16.kind : GL_SHORT,
                UInt16.kind : GL_UNSIGNED_SHORT,
                Int32.kind : GL_INT,
                UInt32.kind : GL_UNSIGNED_INT,
                Float.kind : GL_FLOAT,
                Double.kind : GL_DOUBLE,
                Int1010102.kind : GL_INT_2_10_10_10_REV,
                UInt1010102.kind : GL_UNSIGNED_INT_2_10_10_10_REV,
            ]
            
            for attribute in vertexDescriptor.attributes {
                let format = vertexDescriptor.formatForAttribute(attribute)
                let offset = vertexDescriptor.offsetForAttribute(attribute)
                let dataType = dataTypes[format.kind]!
                
                OpenGL.enableVertexAttributeArrayAtIndex(attribute)
                
                if format.isFloatingPoint {
                    OpenGL.vertexAttribPointerForIndex(attribute, size: format.count, type: dataType, normalized: format.isNormalized, stride: vertexDescriptor.size, offset: offset)
                }
                else {
                    OpenGL.vertexAttribPointerForIndex(attribute, size: format.count, type: dataType, stride: vertexDescriptor.size, offset: offset)
                }
            }
            
            OpenGL.unbindVertexArray()

            renderer.buffers[handle] = vertexArray
            
            renderer.context.unlock()
            
            return handle
        }
    }
    
    public func destoryBuffer(handle: Handle) {
        synchronizeWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            renderer.buffers.removeValueForKey(handle)
            
            renderer.context.unlock()
        }
    }
    
    public func createProgramWithVertexPath(vertexPath: String, fragmentPath: String) -> Handle {
        return synchronizeReadWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            let handle = renderer.programHandleFactory.nextHandle()
            let vertShader = try! OpenGL.Shader(.Vertex)
            let fragShader = try! OpenGL.Shader(.Fragment)
            let program = try! OpenGL.Program()
            
            do {
                try vertShader.compile(vertexPath)
            }
            catch OpenGL.Error.UnableToCompileShader(let message) {
                fatalError("Vertex: \(message)")
            }
            catch {
                fatalError("Vertex: \(error)")
            }
            
            do {
                try fragShader.compile(fragmentPath)
            }
            catch OpenGL.Error.UnableToCompileShader(let message) {
                fatalError("Fragment: \(message)")
            }
            catch {
                fatalError("Fragment: \(error)")
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
                fatalError("Link: \(message)")
            }
            catch {
                fatalError("Link: \(error)")
            }
            
            // Get uniform locations.
            uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = program.uniformLocationWithName("modelViewProjectionMatrix")
            uniforms[UNIFORM_NORMAL_MATRIX] = program.uniformLocationWithName("normalMatrix")
            uniforms[UNIFORM_DIFFUSE_COLOR] = program.uniformLocationWithName("diffuseColor")
            
            program.detachShader(vertShader)
            program.detachShader(fragShader)

            renderer.programs[handle] = program
            
            renderer.context.unlock()

            return handle
        }
    }
    
    public func destroyProgram(handle: Handle) {
        synchronizeWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            renderer.programs.removeValueForKey(handle)
            
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
            
            renderer.context.swapInterval = 1
            
            OpenGL.enableCapability(GL_DEPTH_TEST)
            
            renderer.context.unlock()
        }
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

            OpenGL.clearColor(ColorRGBA8.lightGrey)
            OpenGL.clearMask(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
            
            let program = renderer.programs[state.program]!
            program.use()
            
            var lastBuffer = Handle.invalid
            
            for object in state.objects {
                let nextBuffer = object.buffer
                
                if nextBuffer != lastBuffer {
                    let buffer = renderer.buffers[nextBuffer]!
                    buffer.bind()
                    lastBuffer = nextBuffer
                }
                
                OpenGL.setUniformMatrix(object.modelViewProjectionMatrix, atLocation: uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX])
                OpenGL.setUniformMatrix(object.normalMatrix, atLocation: uniforms[UNIFORM_NORMAL_MATRIX])
                OpenGL.setUniformVector(object.diffuseColor, atLocation: uniforms[UNIFORM_DIFFUSE_COLOR])
                OpenGL.drawArraysWithMode(GL_TRIANGLES, first: 0, count: 36)
            }
            
            renderer.context.flush()
            renderer.context.unlock()
        }
    }
}
