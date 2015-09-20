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

import OpenGL

public final class OpenGLProgram {
    public let handle: GLuint
    private var shaders = [OpenGLShader]()
    private var uniformLocations = [String : GLint]()
    private var uniformBlockIndices = [String : GLuint]()
    
    public init() throws {
        handle = OpenGL.createProgram()
        
        if handle == 0 {
            throw OpenGLError.UnableToCreateProgram
        }
    }
    
    deinit {
        for shader in shaders {
            detachShader(shader)
        }
        
        OpenGL.deleteProgramWithHandle(handle)
    }
    
    public func attachShader(shader: OpenGLShader) {
        shaders.append(shader)
        OpenGL.attachShaderWithHandle(shader.handle, toProgramWithHandle: handle)
    }
    
    public func detachShader(shader: OpenGLShader) {
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
            throw OpenGLError.UnableToLinkProgram(infoLog())
        }
    }
    
    public func addUniformName(name: String) {
        precondition(uniformLocations[name] == nil, "Duplicate uniform name `\(name)`")
        let location = uniformLocationWithName(name)
        
        if location < 0 {
            fatalError("Non-active uniform `\(name)`")
        }
        
        uniformLocations[name] = location
    }
    
    public func uniformLocationForName(name: String) -> GLint {
        return uniformLocations[name]!
    }
    
    public func uniformLocationWithName(name: String) -> GLint {
        return OpenGL.getUniformLocationWithName(name, fromProgramWithHandle: handle)
    }
    
    public func addUniformBlockName(name: String) {
        precondition(uniformBlockIndices[name] == nil, "Duplication uniform block name `\(name)`")
        let index = getUniformBlockIndexForName(name)
        
        if index == GLuint(GL_INVALID_INDEX) {
            fatalError("Non-active uniform block `\(name)`")
        }
        
        uniformBlockIndices[name] = index
    }
    
    public func uniformBlockIndexForName(name: String) -> GLuint {
        return uniformBlockIndices[name]!
    }
    
    public func getUniformBlockIndexForName(name: String) -> GLuint {
        return glGetUniformBlockIndex(handle, name)
    }
    
    public func sizeOfUniformBlockWithName(name: String) -> Int {
        let index = uniformBlockIndices[name]!
        return getSizeForActiveUniformBlockAtIndex(index)
    }
    
    public func getSizeForActiveUniformBlockAtIndex(index: GLuint) -> Int {
        var size: GLint = 0
        glGetActiveUniformBlockiv(handle, index, GLenum(GL_UNIFORM_BLOCK_DATA_SIZE), &size)
        return Int(size)
    }
    
    public func use() {
        OpenGL.useProgramWithHandle(handle)
    }
}
