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

import Metal
import Swiftish

public final class MetalTextureOwner : TextureOwner {
    private let device: MTLDevice
    private var textures: [MTLTexture?]
    
    public init(device: MTLDevice) {
        self.device = device
        self.textures = []
        textures.reserveCapacity(128)
    }
    
    public func createTexture(descriptor: TextureDescriptor) -> TextureHandle {
        textures.append(device.makeTexture(descriptor: map(descriptor)))
        return TextureHandle(key: UInt16(textures.count))
    }
    
    public func borrowTexture(handle: TextureHandle) -> Texture {
        return MetalTexture(handle: handle, instance: self[handle])
    }
    
    public func generateMipmaps(handles: [TextureHandle]) {
        
    }
    
    public func destroyTexture(handle: TextureHandle) {
        textures[handle.index] = nil
    }
    
    internal subscript (handle: TextureHandle) -> MTLTexture {
        return textures[handle.index]!
    }
    
    private func map(_ descriptor: TextureDescriptor) -> MTLTextureDescriptor {
        let metalDescriptor = MTLTextureDescriptor()
        metalDescriptor.textureType = map(descriptor.textureType)
        metalDescriptor.pixelFormat = MetalDataTypes.map(descriptor.pixelFormat)
        metalDescriptor.width = descriptor.width
        metalDescriptor.height = descriptor.height
        metalDescriptor.depth = descriptor.depth
        metalDescriptor.mipmapLevelCount = descriptor.mipmapLevelCount
        metalDescriptor.usage = map(descriptor.textureUsage)
        return metalDescriptor
    }
    
    private func map(_ textureType: TextureType) -> MTLTextureType {
        switch textureType {
        case .type1D:
            return .type1D
        case .type2D:
            return .type2D
        case .type3D:
            return .type3D
        }
    }
    
    private func map(_ textureUsage: TextureUsage) -> MTLTextureUsage {
        var usage = MTLTextureUsage()
        
        if textureUsage.contains(.shaderRead) {
            usage.formUnion(.shaderRead)
        }
        
        if textureUsage.contains(.shaderWrite) {
            usage.formUnion(.shaderWrite)
        }
        
        if textureUsage.contains(.renderTarget) {
            usage.formUnion(.renderTarget)
        }
        
        return usage
    }
}

public struct MetalTexture : Texture {
    public let handle: TextureHandle
    public unowned(unsafe) let instance: MTLTexture
    
    public init(handle: TextureHandle, instance: MTLTexture) {
        self.handle = handle
        self.instance = instance
    }
    
    public func replace(region: Region3<Int>, mipmapLevel level: Int, slice: Int, bytes: UnsafeRawPointer, bytesPerRow: Int, bytesPerImage: Int) {
        instance.replace(region: MetalDataTypes.map(region), mipmapLevel: level, slice: slice, withBytes: bytes, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerImage)
    }
}
