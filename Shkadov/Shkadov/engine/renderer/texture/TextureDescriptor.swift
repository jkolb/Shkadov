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

public struct TextureDescriptor {
    public var textureType: TextureType
    public var pixelFormat: PixelFormat
    public var extent: Extent3D
    public var mipmapLevelCount: Int
    public var storageMode: GPUStorageMode
    public var textureUsage: TextureUsage
    
    public static func twoDimensionalDescriptorWithPixelFormat(pixelFormat: PixelFormat, width: Int, height: Int, mipmapped: Bool) -> TextureDescriptor {
        return TextureDescriptor(
            textureType: .TwoDimensional,
            pixelFormat: .RGBA8Unorm,
            extent: Extent3D(width: width, height: height, depth: 1),
            mipmapLevelCount: mipmapped ? Int(floor(log2(Float(max(width, height))))) + 1 : 1,
            storageMode: .Managed,
            textureUsage: .ShaderRead
        )
    }
    
    public init(textureType: TextureType, pixelFormat: PixelFormat, extent: Extent3D, mipmapLevelCount: Int, storageMode: GPUStorageMode, textureUsage: TextureUsage) {
        self.textureType = textureType
        self.pixelFormat = pixelFormat
        self.extent = extent
        self.mipmapLevelCount = mipmapLevelCount
        self.storageMode = storageMode
        self.textureUsage = textureUsage
    }
}
