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

public enum CompareFunction {
    case never
    case less
    case equal
    case lessEqual
    case greater
    case notEqual
    case greaterEqual
    case always
}

public enum StencilOperation {
    case keep
    case zero
    case replace
    case incrementClamp
    case decrementClamp
    case invert
    case incrementWrap
    case decrementWrap
}

public struct StencilDescriptor {
    public var stencilCompareFunction: CompareFunction = .always
    public var stencilFailureOperation: StencilOperation = .keep
    public var depthFailureOperation: StencilOperation = .keep
    public var depthStencilPassOperation: StencilOperation = .keep
    public var readMask: UInt32 = 0xFFFFFFFF
    public var writeMask: UInt32 = 0xFFFFFFFF
    
    public init() { }
}

public struct DepthStencilDescriptor {
    public var depthCompareFunction: CompareFunction = .always
    public var isDepthWriteEnabled: Bool = false
    public var frontFaceStencil: StencilDescriptor = StencilDescriptor()
    public var backFaceStencil: StencilDescriptor = StencilDescriptor()
    
    public init() { }
}

public protocol DepthStencilStateOwner : class {
    func createDepthStencilState(descriptor: DepthStencilDescriptor) -> DepthStencilStateHandle
    func destroyDepthStencilState(handle: DepthStencilStateHandle)
}

public struct DepthStencilStateHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}
