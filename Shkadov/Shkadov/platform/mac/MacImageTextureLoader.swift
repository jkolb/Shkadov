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

import CoreGraphics
import Foundation
import ImageIO

public final class MacImageTextureLoader : ImageTextureLoader {
    private let gpuMemory: GPUMemory
    
    public init(gpuMemory: GPUMemory) {
        self.gpuMemory = gpuMemory
    }
    
    public func loadImageTextureAtPath(path: String) throws -> Texture {
        // https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/OpenGL-MacProgGuide/opengl_texturedata/opengl_texturedata.html#//apple_ref/doc/uid/TP40001987-CH407-SW22
        let url = NSURL(fileURLWithPath: path)
        guard let imageSource = CGImageSourceCreateWithURL(url, nil) else {
            throw ImageTextureLoaderError.UnableToCreateImageFromPath(path)
        }
        
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            throw ImageTextureLoaderError.UnableToCreateImageFromPath(path)
        }
        
        let width = CGImageGetWidth(image)
        let height = CGImageGetHeight(image)
        let bitsPerComponent = 8
        let bytesPerPixel = 4 // BGRA_8888
        let bytesPerRow = bytesPerPixel * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue // RGBA
        let bitmapContext = CGBitmapContextCreate(nil, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo)
        CGContextSetBlendMode(bitmapContext, .Copy)
        // If need to flip
//        CGContextTranslateCTM(bitmapContext, 0.0, CGFloat(height))
//        CGContextScaleCTM(bitmapContext, 1.0, -1.0)
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        CGContextDrawImage(bitmapContext, rect, image)
        
        let offset = Offset3D(x: 0, y: 0, z: 0)
        let extent = Extent3D(width: width, height: height, depth: 1)
        
        let textureDescriptor = TextureDescriptor.twoDimensionalDescriptorWithPixelFormat(.RGBA8Unorm, width: width, height: height, mipmapped: true)
        let texture = gpuMemory.textureWithDescriptor(textureDescriptor)
        let region = Region3D(offset: offset, extent: extent)
        let imageData = CGBitmapContextGetData(bitmapContext)
        texture.replaceRegion(region, mipmapLevel: 0, withBytes: imageData, bytesPerRow: bytesPerRow)
        
        return texture
    }
}
