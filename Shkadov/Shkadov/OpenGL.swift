//
//  OpenGL.swift
//  iOSOpenGLTemplate2
//
//  Created by Justin Kolb on 8/15/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import Foundation
import OpenGL
import OpenGL.GL3
import simd

public extension GLboolean {
    public init(_ v: Bool) {
        self.init(v ? GL_TRUE : GL_FALSE)
    }
}

public struct ColorRGBA8 {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let alpha: UInt8
    
    public init(rgba: UInt32) {
        self.init(
            red: UInt8((rgba & 0xFF000000) >> 24),
            green: UInt8((rgba & 0x00FF0000) >> 16),
            blue: UInt8((rgba & 0x0000FF00) >> 8),
            alpha: UInt8((rgba & 0x000000FF) >> 0)
        )
    }

    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(red: red, green: green, blue: blue, alpha: UInt8.max)
    }
    
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public struct Color {
    public let red: Float
    public let green: Float
    public let blue: Float
    public let alpha: Float

    public init(rgba8: ColorRGBA8) {
        self.init(red: Float(rgba8.red) / 255.0, green: Float(rgba8.green) / 255.0, blue: Float(rgba8.blue) / 255.0, alpha: Float(rgba8.alpha) / 255.0)
    }
    
    public init(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
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
    
    public static func viewport(x: Int32, y: Int32, width: UInt16, height: UInt16) {
        glViewport(x, y, GLsizei(width), GLsizei(height))
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
    
    public static func drawArraysWithMode(mode: Int32, first: GLint, count: GLsizei) {
        glDrawArrays(GLenum(mode) , first, count)
    }
    
    public static func enableCapability(capability: Int32) {
        glEnable(GLenum(capability))
    }
    
    public static func enableVertexAttributeArrayAtIndex<T: RawRepresentable where T.RawValue == GLuint>(index: T) {
        enableVertexAttributeArrayAtIndex(index.rawValue)
    }
    
    public static func enableVertexAttributeArrayAtIndex(index: GLuint) {
        glEnableVertexAttribArray(index)
    }
    
    public static func disableVertexAttributeArrayAtIndex(index: GLuint) {
        glDisableVertexAttribArray(index)
    }

    public static func vertexAttribPointerForIndex<T: RawRepresentable where T.RawValue == GLuint>(index: T, size: GLint, type: Int32, normalized: Bool, stride: GLsizei, offset: Int) {
        vertexAttribPointerForIndex(index.rawValue, size: size, type: type, normalized: normalized, stride: stride, offset: offset)
    }
    
    public static func vertexAttribPointerForIndex(index: GLuint, size: GLint, type: Int32, normalized: Bool, stride: GLsizei, offset: Int) {
        let pointer: UnsafePointer<Void> = nil
        vertexAttribPointerForIndex(index, size: size, type: type, normalized: normalized, stride: stride, pointer: pointer.advancedBy(offset))
    }
    
    public static func vertexAttribPointerForIndex(index: GLuint, size: GLint, type: Int32, normalized: Bool, stride: GLsizei, pointer: UnsafePointer<Void>) {
        glVertexAttribPointer(index, size, GLenum(type), GLboolean(normalized), stride, pointer)
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
            glGetProgramiv(handle, GLenum(GL_INFO_LOG_LENGTH), &logLength);
            
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
                glGetProgramInfoLog(handle, logLength, &logLength, log);
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
        
        public func bindAttributeLocations<T: RawRepresentable where T.RawValue == GLuint>(indexByName: [String:T]) {
            for (name, index) in indexByName {
                bindAttributeLocation(index, name: name)
            }
        }
        
        public func bindAttributeLocation(index: GLuint, name: String) {
            glBindAttribLocation(handle, index, name)
        }
        
        public func bindAttributeLocation<T: RawRepresentable where T.RawValue == GLuint>(index: T, name: String) {
            bindAttributeLocation(index.rawValue, name: name)
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
        
        private var GLType: Int32 {
            switch (self) {
            case .Fragment:
                return GL_FRAGMENT_SHADER
            case .Vertex:
                return GL_VERTEX_SHADER
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
            glGetShaderiv(handle, GLenum(GL_INFO_LOG_LENGTH), &logLength);
            
            if logLength > 0 {
                let log = UnsafeMutablePointer<GLchar>(malloc(Int(logLength)))
                glGetShaderInfoLog(handle, logLength, &logLength, log);
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
            
            var status: GLint = GL_FALSE;
            glGetShaderiv(handle, GLenum(GL_COMPILE_STATUS), &status)
            
            if status != GL_TRUE {
                throw Error.UnableToCompileShader(infoLog())
            }
        }
    }

    public final class VertexArray {
        public private(set) var handle: GLuint = 0
        
        public init() {
            glGenVertexArrays(1, &handle)
        }
        
        public func bind() {
            OpenGL.bindVertexArrayWithHandle(handle)
        }
        
        deinit {
            glDeleteVertexArrays(1, &handle)
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
}
