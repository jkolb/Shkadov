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
    public var vertexShader: VertexFunctionHandle = VertexFunctionHandle()
    public var fragmentShader: FragmentFunctionHandle = FragmentFunctionHandle()
    public var sampleCount: Int = 1
    public var isRasterizationEnabled: Bool = true
    public var colorAttachments: [RenderPipelineColorAttachmentDescriptor] = []
    public var depthAttachmentPixelFormat: PixelFormat = .invalid
    public var stencilAttachmentPixelFormat: PixelFormat = .invalid
    
    public init() {
    }
}

public struct ColorWriteMask : OptionSet {
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    public static var red = ColorWriteMask(rawValue: 0x1 << 3)
    public static var green = ColorWriteMask(rawValue: 0x1 << 2)
    public static var blue = ColorWriteMask(rawValue: 0x1 << 1)
    public static var alpha = ColorWriteMask(rawValue: 0x1 << 0)
    public static var all = ColorWriteMask(rawValue: 0xf)
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
    public var writeMask: ColorWriteMask = .all
}

public struct RenderPipelineStateHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}

public protocol RenderPipelineStateOwner : class {
    func createRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineStateHandle
    func destroyRenderPipelineState(handle: RenderPipelineStateHandle)
}
