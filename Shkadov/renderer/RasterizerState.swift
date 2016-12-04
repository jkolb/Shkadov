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

public struct RasterizerStateDescriptor {
    public var viewport: Viewport? = nil
    public var frontFaceWinding: Winding = .clockwise
    public var cullMode: CullMode = .none
    public var depthClipMode: DepthClipMode = .clip
    public var scissorRect: ScissorRect? = nil
    public var fillMode: TriangleFillMode = .fill
    
    public init() { }
}

public struct RasterizerStateHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}

public protocol RasterizerStateOwner : class {
    func createRasterizerState(descriptor: RasterizerStateDescriptor) -> RasterizerStateHandle
    func destroyRasterizerState(handle: RasterizerStateHandle)
}
