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

public enum LoadAction {
    case dontCare
    case load
    case clear
}

public enum StoreAction {
    case dontCare
    case store
    case multisampleResolve
    case storeAndMultisampleResolve
    case unknown
}

public struct ClearColor {
    var r: Float
    var g: Float
    var b: Float
    var a: Float
    
    public init() {
        self.init(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
    }
    
    public init(r: Float, g: Float, b: Float, a: Float) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

public struct RenderPassColorAttachmentDescriptor {
    public var clearColor: ClearColor = ClearColor()
    public var level: Int = 0
    public var slice: Int = 0
    public var depthPlane: Int = 0
    public var resolve: Bool = false
    public var resolveLevel: Int = 0
    public var resolveSlice: Int = 0
    public var resolveDepthPlane: Int = 0
    public var loadAction: LoadAction = .dontCare
    public var storeAction: StoreAction = .dontCare
    
    public init() { }
}

public struct RenderPassDepthAttachmentDescriptor {
    public var clearDepth: Float = 0.0
    public var level: Int = 0
    public var slice: Int = 0
    public var depthPlane: Int = 0
    public var resolve: Bool = false
    public var resolveLevel: Int = 0
    public var resolveSlice: Int = 0
    public var resolveDepthPlane: Int = 0
    public var loadAction: LoadAction = .dontCare
    public var storeAction: StoreAction = .dontCare
    
    public init() { }
}

public struct RenderPassStencilAttachmentDescriptor {
    public var clearStencil: UInt32 = 0
    public var level: Int = 0
    public var slice: Int = 0
    public var depthPlane: Int = 0
    public var resolve: Bool = false
    public var resolveLevel: Int = 0
    public var resolveSlice: Int = 0
    public var resolveDepthPlane: Int = 0
    public var loadAction: LoadAction = .dontCare
    public var storeAction: StoreAction = .dontCare
    
    public init() { }
}

public struct RenderPassDescriptor {
    public var colorAttachments: [RenderPassColorAttachmentDescriptor] = []
    public var depthAttachment: RenderPassDepthAttachmentDescriptor = RenderPassDepthAttachmentDescriptor()
    public var stencilAttachment: RenderPassStencilAttachmentDescriptor = RenderPassStencilAttachmentDescriptor()
    public var renderTargetArrayLength: Int = 0
    
    public init() { }
}

public protocol RenderPassOwner : class {
    func createRenderPass(descriptor: RenderPassDescriptor) -> RenderPassHandle
    func destroyRenderPass(handle: RenderPassHandle)
}

public struct RenderPassHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}
