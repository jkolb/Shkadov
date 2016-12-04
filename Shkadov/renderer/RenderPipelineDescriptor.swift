/*
 The MIT License (MIT)
 
 Copyright (c) 2016 Justin Kolb
 
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

public struct RenderPipelineDescriptor {
    public var vertexShader: ShaderFunction?
    public var fragmentShader: ShaderFunction?
    public var sampleCount: Int = 0
    public var isRasterizationEnabled: Bool = false
    public var colorAttachments: [RenderPipelineColorAttachmentDescriptor] = []
    public var depthAttachmentPixelFormat: PixelFormat = .invalid
    public var stencilAttachmentPixelFormat: PixelFormat = .invalid
    
    public init() {
    }
}

public struct RenderPipelineColorAttachmentDescriptor {
    public var pixelFormat: PixelFormat = .invalid
    public var isBlendingEnabled: Bool = false
    public var sourceRGBBlendFactor: BlendFactor = .one
    public var destinationRGBBlendFactor: BlendFactor = .zero
    public var rgbBlendOperation: BlendOperation = .add
    public var sourceAlphaBlendFactor: BlendFactor = .one
    public var destinationAlphaBlendFactor: BlendFactor = .zero
    public var alphaBlendOperation: BlendOperation = .add
    
    /* Other Options */
    
    /*! Defaults to MTLColorWriteMaskAll */
//    public var writeMask: MTLColorWriteMask
}
