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

import Foundation
import OpenGL
import OpenGL.GL3
import simd

public extension GLboolean {
    public init(_ v: Bool) {
        self.init(v ? GL_TRUE : GL_FALSE)
    }
}

public struct OpenGL {
    public enum Error: ErrorType {
        case UnableToCreateShader
        case UnableToLoadShader(ErrorType)
        case UnableToCompileShader(String)
        case UnableToCreateProgram
        case UnableToLinkProgram(String)
    }
    
    public static var vendor: String {
        return getString(GL_VENDOR)
    }
    
    public static var renderer: String {
        return getString(GL_RENDERER)
    }

    public static var version: String {
        return getString(GL_VERSION)
    }
    
    public static func getString(name: Int32) -> String {
        let bytes = UnsafePointer<CChar>(glGetString(GLenum(name)))
        return String.fromCString(bytes)!
    }
    
    public static func viewport(viewport: Rectangle2D) {
        glViewport(GLint(viewport.x), GLint(viewport.y), GLsizei(viewport.width), GLsizei(viewport.height))
    }
    
    public static func clearColor(color: ColorRGBA8) {
        OpenGL.clearColor(Color(rgba8: color))
    }
    
    public static func clearColor(color: Color) {
        OpenGL.clearColorWithRed(color.red, green: color.green, blue: color.blue, alpha: color.alpha)
    }

    public static func clearColorWithRed(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) {
        glClearColor(red, green, blue, alpha)
    }
    
    public static func clearMask(mask: Int32) {
        glClear(GLbitfield(mask))
    }
    
    public static func setUniformMatrix(matrix: float4x4, atLocation location: GLint) {
        var mutableMatrix = matrix
        withUnsafePointer(&mutableMatrix) {
            OpenGL.uniformMatrix4fvAtLocation(location, count: 1, transpose: false, value: UnsafePointer<GLfloat>($0))
        }
    }
    
    public static func uniformMatrix3fvAtLocation(location: GLint, count: GLsizei, transpose: Bool, value: UnsafePointer<GLfloat>) {
        glUniformMatrix3fv(location, count, GLboolean(transpose), value)
    }
    
    public static func uniformMatrix4fvAtLocation(location: GLint, count: GLsizei, transpose: Bool, value: UnsafePointer<GLfloat>) {
        glUniformMatrix4fv(location, count, GLboolean(transpose), value)
    }

    public static func setUniformVector(vector: float4, atLocation location: GLint) {
        var mutableVector = vector
        withUnsafePointer(&mutableVector) {
            OpenGL.uniform4F(location, count: 1, value: UnsafePointer<GLfloat>($0))
        }
    }
    
    public static func uniform4F(location: GLint, count: GLsizei, value: UnsafePointer<GLfloat>) {
        glUniform4fv(location, count, value)
    }
    
    public static func drawArraysWithMode(mode: Int32, first: GLint, count: GLsizei) {
        glDrawArrays(GLenum(mode) , first, count)
    }
    
    public static func enableCapability(capability: Int32) {
        glEnable(GLenum(capability))
    }
    
    public static func enableVertexAttributeArrayAtIndex<T: RawRepresentable where T.RawValue == UInt>(index: T) {
        enableVertexAttributeArrayAtIndex(GLuint(index.rawValue))
    }
    
    public static func enableVertexAttributeArrayAtIndex(index: GLuint) {
        glEnableVertexAttribArray(index)
    }
    
    public static func disableVertexAttributeArrayAtIndex(index: GLuint) {
        glDisableVertexAttribArray(index)
    }

    public static func vertexAttribPointerForIndex<T: RawRepresentable where T.RawValue == UInt>(index: T, size: Int, type: Int32, normalized: Bool, stride: Int, offset: Int) {
        vertexAttribPointerForIndex(GLuint(index.rawValue), size: GLint(size), type: type, normalized: normalized, stride: GLsizei(stride), offset: offset)
    }
    
    public static func vertexAttribPointerForIndex(index: GLuint, size: GLint, type: Int32, normalized: Bool, stride: GLsizei, offset: Int) {
        let pointer: UnsafePointer<Void> = nil
        vertexAttribPointerForIndex(index, size: size, type: type, normalized: normalized, stride: stride, pointer: pointer.advancedBy(offset))
    }
    
    public static func vertexAttribPointerForIndex(index: GLuint, size: GLint, type: Int32, normalized: Bool, stride: GLsizei, pointer: UnsafePointer<Void>) {
        glVertexAttribPointer(index, size, GLenum(type), GLboolean(normalized), stride, pointer)
    }
    
    public static func vertexAttribPointerForIndex<T: RawRepresentable where T.RawValue == UInt>(index: T, size: Int, type: Int32, stride: Int, offset: Int) {
        vertexAttribPointerForIndex(GLuint(index.rawValue), size: GLint(size), type: type, stride: GLsizei(stride), offset: offset)
    }
    
    public static func vertexAttribPointerForIndex(index: GLuint, size: GLint, type: Int32, stride: GLsizei, offset: Int) {
        let pointer: UnsafePointer<Void> = nil
        vertexAttribPointerForIndex(index, size: size, type: type, stride: stride, pointer: pointer.advancedBy(offset))
    }
    
    public static func vertexAttribPointerForIndex(index: GLuint, size: GLint, type: Int32, stride: GLsizei, pointer: UnsafePointer<Void>) {
        glVertexAttribIPointer(index, size, GLenum(type), stride, pointer)
    }
    
    public static func getUniformLocationWithName(name: String, fromProgramWithHandle handle: GLuint) -> GLint {
        return glGetUniformLocation(handle, name)
    }
    
    public static func bindVertexArrayWithHandle(handle: GLuint) {
        glBindVertexArray(handle)
    }
    
    public static func unbindVertexArray() {
        bindVertexArrayWithHandle(0)
    }
    
    public static func bindBufferToTarget(target: Int32, handle: GLuint) {
        glBindBuffer(GLenum(target), handle)
    }
    
    public static func unbindBufferFromTarget(target: Int32) {
        bindBufferToTarget(target, handle: 0)
    }
    
    public static func bufferDataForTarget(target: Int32, size: GLsizeiptr, data: UnsafePointer<Void>, usage: Int32) {
        glBufferData(GLenum(target), size, data, GLenum(usage))
    }

    public static func useProgramWithHandle(handle: GLuint) {
        glUseProgram(handle)
    }
    
    public static func clearUsedProgram() {
        useProgramWithHandle(0)
    }
    
    public static func createProgram() -> GLuint {
        return glCreateProgram()
    }
    
    public static func deleteProgramWithHandle(handle: GLuint) {
        glDeleteProgram(handle)
    }
    
    public static func attachShaderWithHandle(shaderHandle: GLuint, toProgramWithHandle programHandle: GLuint) {
        glAttachShader(programHandle, shaderHandle)
    }
    
    public static func detachShaderWithHandle(shaderHandle: GLuint, fromProgramWithHandle programHandle: GLuint) {
        glDetachShader(programHandle, shaderHandle)
    }
    
    public static func linkProgramWithHandle(handle: GLuint) {
        glLinkProgram(handle)
    }
    
    public static func createShaderWithType(type: Int32) -> GLuint {
        return glCreateShader(GLenum(type))
    }
    
    public final class Program {
        public let handle: GLuint
        private var shaders = [Shader]()
        
        public init() throws {
            handle = OpenGL.createProgram()
            
            if handle == 0 {
                throw Error.UnableToCreateProgram
            }
        }
        
        deinit {
            for shader in shaders {
                detachShader(shader)
            }
            
            OpenGL.deleteProgramWithHandle(handle)
        }

        public func attachShader(shader: Shader) {
            shaders.append(shader)
            OpenGL.attachShaderWithHandle(shader.handle, toProgramWithHandle: handle)
        }
        
        public func detachShader(shader: Shader) {
            if let index = shaders.indexOf({$0.handle == shader.handle}) {
                OpenGL.detachShaderWithHandle(shader.handle, fromProgramWithHandle: handle)
                shaders.removeAtIndex(index)
            }
        }
        
        public func infoLog() -> String {
            var logString = ""
            var logLength: GLint = 0
            glGetProgramiv(handle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
                glGetProgramInfoLog(handle, logLength, &logLength, log)
                logString = String.fromCString(log)!
                free(log)
            }
            
            return logString
        }
        
        public func bindAttributeLocations(indexByName: [String:GLuint]) {
            for (name, index) in indexByName {
                bindAttributeLocation(index, name: name)
            }
        }
        
        public func bindAttributeLocations<T: RawRepresentable where T.RawValue == UInt>(indexByName: [String:T]) {
            for (name, index) in indexByName {
                bindAttributeLocation(index, name: name)
            }
        }
        
        public func bindAttributeLocation(index: GLuint, name: String) {
            glBindAttribLocation(handle, index, name)
        }
        
        public func bindAttributeLocation<T: RawRepresentable where T.RawValue == UInt>(index: T, name: String) {
            bindAttributeLocation(GLuint(index.rawValue), name: name)
        }
        
        public func link() throws {
            OpenGL.linkProgramWithHandle(handle)
            
            var status: GLint = GL_FALSE
            glGetProgramiv(handle, GLenum(GL_LINK_STATUS), &status)
            
            if status != GL_TRUE {
                throw Error.UnableToLinkProgram(infoLog())
            }
        }

        public func uniformLocationWithName(name: String) -> GLint {
            return OpenGL.getUniformLocationWithName(name, fromProgramWithHandle: handle)
        }
        
        public func use() {
            OpenGL.useProgramWithHandle(handle)
        }
    }
    
    public enum ShaderType {
        case Fragment
        case Vertex
        case Geometry
        
        private var GLType: Int32 {
            switch (self) {
            case .Fragment:
                return GL_FRAGMENT_SHADER
            case .Vertex:
                return GL_VERTEX_SHADER
            case .Geometry:
                return GL_GEOMETRY_SHADER
            }
        }
    }
    
    public final class Shader {
        public let handle: GLuint
        
        public convenience init(_ shaderType: ShaderType) throws {
            try self.init(type: shaderType.GLType)
        }
        
        public init(type: Int32) throws {
            handle = OpenGL.createShaderWithType(type)
            
            if handle == 0 {
                throw Error.UnableToCreateShader
            }
        }
        
        deinit {
            glDeleteShader(handle)
        }

        public func infoLog() -> String {
            var logString = ""
            var logLength: GLint = 0
            glGetShaderiv(handle, GLenum(GL_INFO_LOG_LENGTH), &logLength)
            
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
                glGetShaderInfoLog(handle, logLength, &logLength, log)
                logString = String.fromCString(log)!
                free(log)
            }
            
            return logString
        }
        
        public func compile(file: String) throws {
            var source: UnsafePointer<Int8>
            
            do {
                source = try NSString(contentsOfFile: file, encoding: NSUTF8StringEncoding).UTF8String
            } catch {
                throw Error.UnableToLoadShader(error)
            }

            var castSource = UnsafePointer<GLchar>(source)
            glShaderSource(handle, 1, &castSource, nil)
            glCompileShader(handle)
            
            var status: GLint = GL_FALSE
            glGetShaderiv(handle, GLenum(GL_COMPILE_STATUS), &status)
            
            if status != GL_TRUE {
                throw Error.UnableToCompileShader(infoLog())
            }
        }
    }

    public final class VertexArray {
        public private(set) var handle: GLuint = 0
        private var buffers = [VertexBuffer]()
        
        public init() {
            glGenVertexArrays(1, &handle)
        }
        
        public func bind() {
            OpenGL.bindVertexArrayWithHandle(handle)
        }
        
        deinit {
            glDeleteVertexArrays(1, &handle)
        }
        
        public func addBuffer(buffer: VertexBuffer) {
            buffers.append(buffer)
        }
    }
    
    public final class VertexBuffer {
        public private(set) var handle: GLuint = 0
        
        public init() {
            glGenBuffers(1, &handle)
        }
        
        public func bindToTarget(target: Int32) {
            OpenGL.bindBufferToTarget(target, handle: handle)
        }
        
        deinit {
            glDeleteBuffers(1, &handle)
        }
    }
    
    public final class Texture {
        public private(set) var handle: GLuint = 0

        public init() {
            glGenTextures(1, &handle)
        }
        
        public func bind2D() {
            bindToTarget(GL_TEXTURE_2D)
        }
        
        public func data2D(width: Int, height: Int, pixels: UnsafePointer<Void>) {
            let level: GLint = 0
            let internalFormat: GLint = GL_RGBA8
            let border: GLint = 0
            let format: GLenum = GLenum(GL_BGRA)
            let type: GLenum = GLenum(GL_UNSIGNED_INT_8_8_8_8_REV)
            
            glTexImage2D(GLenum(GL_TEXTURE_2D), level, internalFormat, GLsizei(width), GLsizei(height), border, format, type, pixels)
        }
        
        public func bindToTarget(target: Int32) {
            glBindTexture(GLenum(target), handle)
        }
        
        deinit {
            glDeleteTextures(1, &handle)
        }
    }
}
