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

public final class OpenGLRenderer : Renderer, Synchronizable {
    public let synchronizationQueue: DispatchQueue
    public var viewport: Rectangle2D
    public weak var context: OpenGLContext!
    private let textureHandleFactory = HandleFactory()
    private var textures: [Handle : OpenGLTexture]
    private let vertexArrayHandleFactory = HandleFactory()
    private var vertexArrays: [Handle : OpenGLVertexArray]
    private let uniformHandleFactory = HandleFactory()
    private var uniforms: [Handle : OpenGLBuffer]
    private let programHandleFactory = HandleFactory()
    private var programs: [Handle : OpenGLProgram]
    
    public init(context: OpenGLContext) {
        self.context = context
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.render", attribute: .Serial)
        self.viewport = Rectangle2D.zero
        self.textures = [Handle : OpenGLTexture]()
        self.vertexArrays = [Handle : OpenGLVertexArray]()
        self.programs = [Handle : OpenGLProgram]()
        self.uniforms = [Handle : OpenGLBuffer]()
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
            let texture = OpenGLTexture()
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
    
    public func createVertexArrayFromDescriptor(vertexDescriptor: VertexDescriptor, buffer: ByteBuffer) -> Handle {
        return synchronizeReadWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            let handle = renderer.vertexArrayHandleFactory.nextHandle()

            let vertexArray = OpenGLVertexArray()
            vertexArray.bind()
            
            let vertexBuffer = OpenGLBuffer()
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

            renderer.vertexArrays[handle] = vertexArray
            
            renderer.context.unlock()
            
            return handle
        }
    }
    
    public func destoryVertexArray(handle: Handle) {
        synchronizeWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            renderer.vertexArrays.removeValueForKey(handle)
            
            renderer.context.unlock()
        }
    }
    
    public func createProgramWithVertexPath(vertexPath: String, fragmentPath: String) -> Handle {
        return synchronizeReadWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            let handle = renderer.programHandleFactory.nextHandle()
            let vertShader = try! OpenGLShader(.Vertex)
            let fragShader = try! OpenGLShader(.Fragment)
            let program = try! OpenGLProgram()
            
            do {
                try vertShader.compile(vertexPath)
            }
            catch OpenGLError.UnableToCompileShader(let message) {
                fatalError("Vertex: \(message)")
            }
            catch {
                fatalError("Vertex: \(error)")
            }
            
            do {
                try fragShader.compile(fragmentPath)
            }
            catch OpenGLError.UnableToCompileShader(let message) {
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
//                "vertexPosition": VertexAttribute.Position,
//                "vertexNormal": VertexAttribute.Normal,
                ])
            
            do {
                try program.link()
            }
            catch OpenGLError.UnableToLinkProgram(let message) {
                fatalError("Link: \(message)")
            }
            catch {
                fatalError("Link: \(error)")
            }
            
            program.addUniformName("modelViewProjectionMatrix")
            program.addUniformName("normalMatrix")
            program.addUniformName("diffuseColor")
            
            program.detachShader(vertShader)
            program.detachShader(fragShader)

            renderer.programs[handle] = program
            
            renderer.context.unlock()

            return handle
        }
    }
    
    public func createUniformForProgram(program: Handle, withName name: String) -> Handle {
        return synchronizeReadWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()

            let p = renderer.programs[program]!
            p.addUniformBlockName(name)
            let size = p.sizeOfUniformBlockWithName(name)
            
            let uniformBuffer = OpenGLBuffer()
            uniformBuffer.bindToTarget(GL_UNIFORM_BUFFER)
            OpenGL.bufferDataForTarget(GL_UNIFORM_BUFFER, size: size, data: nil, usage: GL_DYNAMIC_DRAW)
            OpenGL.bindBufferToTarget(GL_UNIFORM_BUFFER, handle: 0)

            let handle = renderer.uniformHandleFactory.nextHandle()
            renderer.uniforms[handle] = uniformBuffer
            
            renderer.context.unlock()

            return handle
        }
    }
    
    public func updateData(data: ByteBuffer, forUniform uniform: Handle) {
        synchronizeWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            let buffer = renderer.uniforms[uniform]!
            buffer.bindToTarget(GL_UNIFORM_BUFFER)
            glBufferSubData(GLenum(GL_UNIFORM_BUFFER), 0, data.capacity, data.data)
            OpenGL.bindBufferToTarget(GL_UNIFORM_BUFFER, handle: 0)
            
            renderer.context.unlock()
        }
    }
    
    public func destroyUniform(uniform: Handle) {
        synchronizeWrite { renderer in
            renderer.context.lock()
            renderer.context.makeCurrent()
            
            renderer.uniforms.removeValueForKey(uniform)
            
            renderer.context.unlock()
        }
    }
    /* Iterate uniforms in program
    GLint numBlocks;
    glGetProgramiv(prog, GL_ACTIVE_UNIFORM_BLOCKS, &numBlocks);
    
    std::vector<std::string> nameList;
    nameList.reserve(numBlocks);
    for(int blockIx = 0; blockIx < numBlocks; ++blockIx)
    {
        GLint nameLen;
        glGetActiveUniformBlockiv​(prog, blockIx, GL_UNIFORM_BLOCK_NAME_LENGTH, &nameLen);
    
        std::vector<GLchar> name;
        name.resize(nameLen);
        glGetActiveUniformBlockName​(prog, blockIx, nameLen, NULL, &name[0]);
    
        nameList.push_back(std::string());
        nameList.back().assign(name.begin(), name.end() - 1); //Remove the null terminator.
    }
    
    Can't tell the difference between shader and fragment names (so that Metal-like API could be used)?
    Would have to have some prefix just for GLSL so that you could index them differently and have mapping tables between the outside and inside indices.
    */
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
            glEnable(GLenum(GL_CULL_FACE))
            glFrontFace(GLenum(GL_CCW))
            
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
            
            var lastVertexArray = Handle.invalid
            var lastTexture = Handle.invalid
            var lastUniform = Handle.invalid
            
            for object in state.objects {
                let nextVertexArray = object.vertexArray
                
                if nextVertexArray != lastVertexArray && nextVertexArray != Handle.invalid {
                    let buffer = renderer.vertexArrays[nextVertexArray]!
                    buffer.bind()
                    lastVertexArray = nextVertexArray
                }
            
                let nextTexture = object.texture
                
                if nextTexture != lastTexture && nextTexture != Handle.invalid {
                    let texture = renderer.textures[nextTexture]!
                    texture.bind2D()
                    lastTexture = nextTexture
                }
                
                let nextUniform = object.uniform
                
                if nextUniform != lastUniform && nextUniform != Handle.invalid {
                    let uniform = renderer.uniforms[nextUniform]!
                    uniform.bindToTarget(GL_UNIFORM_BUFFER, index: 0)
                    lastUniform = nextUniform
                }
                
                OpenGL.setUniformMatrix(object.modelViewProjectionMatrix, atLocation: program.uniformLocationForName("modelViewProjectionMatrix"))
                OpenGL.setUniformMatrix(object.normalMatrix, atLocation: program.uniformLocationForName("normalMatrix"))
                OpenGL.setUniformVector(object.diffuseColor, atLocation: program.uniformLocationForName("diffuseColor"))
                OpenGL.drawArraysWithMode(GL_TRIANGLES, first: 0, count: 36)
            }
            
            renderer.context.flush()
            renderer.context.unlock()
        }
    }
}
