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
}
