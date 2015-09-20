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

public final class OpenGLTexture {
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
