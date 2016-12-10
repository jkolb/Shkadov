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

import Swiftish

public enum TextureType {
    case type1D
    case type2D
    case type3D
}

public struct TextureUsage : OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    public static let shaderRead = TextureUsage(rawValue: 1)
    public static let shaderWrite = TextureUsage(rawValue: 2)
    public static let renderTarget = TextureUsage(rawValue: 4)
}

public struct TextureDescriptor {
    public var textureType: TextureType = .type2D
    public var pixelFormat: PixelFormat = .rgba8Unorm
    public var width: Int = 1
    public var height: Int = 1
    public var depth: Int = 1
    public var mipmapLevelCount: Int = 1
    public var storageMode: StorageMode = .sharedWithCPU
    public var textureUsage: TextureUsage = [.shaderRead]
    
    public static func texture2DDescriptor(pixelFormat: PixelFormat, width: Int, height: Int, mipmapped: Bool) -> TextureDescriptor {
        var descriptor = TextureDescriptor()
        descriptor.pixelFormat = pixelFormat
        descriptor.width = width
        descriptor.height = height
        descriptor.mipmapLevelCount = mipmapped ? Int(Float.floor(Float.log2(Float(max(width, height))))) + 1 : 1
        return descriptor
    }
    
    public init() {
    }
}

public protocol TextureOwner : class {
    func createTexture(descriptor: TextureDescriptor) -> TextureHandle
    func borrowTexture(handle: TextureHandle) -> Texture
    func generateMipmaps(handles: [TextureHandle])
    func destroyTexture(handle: TextureHandle)
    func nextRenderTexture() -> TextureHandle
}

public struct TextureHandle : Handle {
    public let key: UInt16
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt16) {
        self.key = key
    }
}

public protocol Texture {
    var handle: TextureHandle { get }
    func replace(region: Region3<Int>, mipmapLevel level: Int, slice: Int, bytes: UnsafeRawPointer, bytesPerRow: Int, bytesPerImage: Int)
}

extension Texture {
    public func replace(region: Region3<Int>, mipmapLevel level: Int, bytes: UnsafeRawPointer, bytesPerRow: Int) {
        replace(region: region, mipmapLevel: level, slice: 0, bytes: bytes, bytesPerRow: bytesPerRow, bytesPerImage: 0)
    }
}
