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

public final class OpenGLShader {
    public let handle: GLuint
    
    public convenience init(_ shaderType: OpenGLShaderType) throws {
        try self.init(type: shaderType.GLType)
    }
    
    public init(type: Int32) throws {
        handle = OpenGL.createShaderWithType(type)
        
        if handle == 0 {
            throw OpenGLError.UnableToCreateShader
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
            throw OpenGLError.UnableToLoadShader(error)
        }
        
        var castSource = UnsafePointer<GLchar>(source)
        glShaderSource(handle, 1, &castSource, nil)
        glCompileShader(handle)
        
        var status: GLint = GL_FALSE
        glGetShaderiv(handle, GLenum(GL_COMPILE_STATUS), &status)
        
        if status != GL_TRUE {
            throw OpenGLError.UnableToCompileShader(infoLog())
        }
    }
}
