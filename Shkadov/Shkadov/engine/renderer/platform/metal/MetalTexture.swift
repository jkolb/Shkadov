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

public final class MetalTexture : Texture {
    private let texture: MTLTexture

    public init(texture: MTLTexture) {
        self.texture = texture
    }
    
    public var textureType: TextureType {
        return MetalTextureTypeMapper.map(texture.textureType)
    }
    
    public var pixelFormat: PixelFormat {
        return MetalPixelFormatMapper.map(texture.pixelFormat)
    }
    
    public var extent: Extent3D {
        return Extent3D(width: texture.width, height: texture.height, depth: texture.depth)
    }
    
    public var mipmapLevelCount: Int {
        return texture.mipmapLevelCount
    }
    
    public var storageMode: GPUStorageMode {
        return GPUStorageModeMapper.map(texture.storageMode)
    }
    
    public var textureUsage: TextureUsage {
        return MetalTextureUsageMapper.map(texture.usage)
    }
    
    public func replaceRegion(region: Region3D, mipmapLevel: Int, withBytes pixelBytes: UnsafePointer<Void>, bytesPerRow: Int) {
        let metalRegion = MetalRegionMapper.map(region)
        texture.replaceRegion(metalRegion, mipmapLevel: mipmapLevel, withBytes: pixelBytes, bytesPerRow: bytesPerRow)
    }
    
    public func downCast<T>(castType: T.Type) -> T {
        return texture as! T
    }
}
