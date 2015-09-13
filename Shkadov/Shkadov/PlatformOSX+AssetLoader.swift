/*
The MIT License (MIT)

Copyright (c) 2015 Justin Kolb

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

import Foundation
import ImageIO

extension PlatformOSX : AssetLoader {
    public func pathToFile(name: String) -> String {
        return NSBundle.mainBundle().pathForResource(name, ofType: nil)!
    }

    /*
        https://developer.apple.com/library/mac/documentation/GraphicsImaging/Conceptual/OpenGL-MacProgGuide/opengl_texturedata/opengl_texturedata.html#//apple_ref/doc/uid/TP40001987-CH407-SW22
        Creating a Texture from a Quartz Image Source
     */
    public func loadTextureData(path: String) -> TextureData {
        let fileURL = NSURL.fileURLWithPath(path)
        guard let imageSource = CGImageSourceCreateWithURL(fileURL, nil) else {
            fatalError("Unable to create image source for path '\(path)'")
        }
        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            fatalError("Unable to create image for path '\(path)'")
        }
        let pixelWidth = CGImageGetWidth(image)
        let pixelHeight = CGImageGetHeight(image)
        let pixelSize = PixelSize(width: pixelWidth, height: pixelHeight)
        let format = TextureFormat.RGBA8
        let textureData = TextureData(format: format, size: pixelSize)

        guard let colorSpace = CGColorSpaceCreateDeviceRGB() else {
            fatalError("Unable to create color space")
        }
        
        let bytesPerRow = pixelWidth * format.bytesPerSample
        // Assumes Little Endian as the macros for Host order are ignored by Swift
        let bitmapInfo = CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue
        guard let bitmapContext = CGBitmapContextCreate(textureData.rawData, pixelWidth, pixelHeight, format.bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo) else {
            fatalError("Unable to create bitmap context")
        }
        
        CGContextSetBlendMode(bitmapContext, .Copy)
        CGContextDrawImage(bitmapContext, CGRect(x: 0, y: 0, width: pixelWidth, height: pixelHeight), image)
        
        return textureData
    }
}
