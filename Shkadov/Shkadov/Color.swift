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

public struct ColorRGBA8 {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8
    public let alpha: UInt8
    
    public init(rgba: UInt32) {
        self.init(
            red: UInt8((rgba & 0xFF000000) >> 24),
            green: UInt8((rgba & 0x00FF0000) >> 16),
            blue: UInt8((rgba & 0x0000FF00) >> 8),
            alpha: UInt8((rgba & 0x000000FF) >> 0)
        )
    }
    
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(red: red, green: green, blue: blue, alpha: UInt8.max)
    }
    
    public init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public var rgba: UInt32 {
        let r = UInt32(red) << 24
        let g = UInt32(green) << 16
        let b = UInt32(blue) << 8
        let a = UInt32(alpha) << 0
        return r | g | b | a
    }
    
    public var color: Color {
        return Color(rgba8: self)
    }
}

public struct Color {
    public let red: Float
    public let green: Float
    public let blue: Float
    public let alpha: Float
    
    public init(rgba8: ColorRGBA8) {
        self.init(red: Float(rgba8.red) / 255.0, green: Float(rgba8.green) / 255.0, blue: Float(rgba8.blue) / 255.0, alpha: Float(rgba8.alpha) / 255.0)
    }
    
    public init(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
