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

public enum SamplerMinMagFilter {
    case nearest
    case linear
}

public enum SamplerMipFilter {
    case notMipmapped
    case nearest
    case linear
}

public enum SamplerAddressMode {
    case clampToEdge
    case mirrorClampToEdge
    case `repeat`
    case mirrorRepeat
    case clampToZero
    case clampToBorderColor
}

public enum SamplerBorderColor {
    case transparentBlack // {0,0,0,0}
    case opaqueBlack // {0,0,0,1}
    case opaqueWhite // {1,1,1,1}
}

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

public struct SamplerDescriptor {
    public var minFilter: SamplerMinMagFilter = .nearest
    public var magFilter: SamplerMinMagFilter = .nearest
    public var mipFilter: SamplerMipFilter = .notMipmapped
    public var maxAnisotropy: Int = 1
    public var sAddressMode: SamplerAddressMode = .clampToEdge
    public var tAddressMode: SamplerAddressMode = .clampToEdge
    public var rAddressMode: SamplerAddressMode = .clampToEdge
    public var borderColor: SamplerBorderColor = .transparentBlack
    public var normalizedCoordinates: Bool = true
    public var lodMinClamp: Float = 0.0
    public var lodMaxClamp: Float = Float.greatestFiniteMagnitude
    public var compareFunction: CompareFunction = .never
    
    public init() {
    }
}

public struct SamplerHandle : Handle {
    public let key: UInt16
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt16) {
        self.key = key
    }
}

public protocol SamplerOwner : class {
    func createSampler(descriptor: SamplerDescriptor) -> SamplerHandle
    func destroySampler(handle: SamplerHandle)
}
