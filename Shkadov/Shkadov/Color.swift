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

import simd

public struct ColorRGBA8 {
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var alpha: UInt8
    
    public static var black = ColorRGBA8(red: 0, green: 0, blue: 0)
    public static var darkGrey = ColorRGBA8(red: 64, green: 64, blue: 64)
    public static var grey = ColorRGBA8(red: 128, green: 128, blue: 128)
    public static var lightGrey = ColorRGBA8(red: 192, green: 192, blue: 192)
    public static var white = ColorRGBA8(red: 255, green: 255, blue: 255)
    public static var red = ColorRGBA8(red: 255, green: 0, blue: 0)
    public static var green = ColorRGBA8(red: 0, green: 255, blue: 0)
    public static var blue = ColorRGBA8(red: 0, green: 0, blue: 255)
    public static var yellow = ColorRGBA8(red: 255, green: 255, blue: 0)
    public static var magenta = ColorRGBA8(red: 255, green: 0, blue: 255)
    public static var cyan = ColorRGBA8(red: 0, green: 255, blue: 255)
    
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
}

public struct Color {
    public var red: Float
    public var green: Float
    public var blue: Float
    public var alpha: Float
    
    public static var black = Color(red: 0, green: 0, blue: 0)
    public static var darkGrey = Color(red: 0.25, green: 0.25, blue: 0.25)
    public static var grey = Color(red: 0.5, green: 0.5, blue: 0.5)
    public static var lightGrey = Color(red: 0.75, green: 0.75, blue: 0.75)
    public static var white = Color(red: 1.0, green: 1.0, blue: 1.0)
    public static var red = Color(red: 1.0, green: 0.0, blue: 0.0)
    public static var green = Color(red: 0.0, green: 1.0, blue: 0.0)
    public static var blue = Color(red: 0.0, green: 0.0, blue: 1.0)
    public static var yellow = Color(red: 1.0, green: 1.0, blue: 0.0)
    public static var magenta = Color(red: 1.0, green: 0.0, blue: 1.0)
    public static var cyan = Color(red: 0.0, green: 1.0, blue: 1.0)

    public init(rgba8: ColorRGBA8) {
        self.init(red: Float(rgba8.red) / 255.0, green: Float(rgba8.green) / 255.0, blue: Float(rgba8.blue) / 255.0, alpha: Float(rgba8.alpha) / 255.0)
    }

    public init(red: Float, green: Float, blue: Float) {
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    public init(red: Float, green: Float, blue: Float, alpha: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension Color {
    public var vector: float4 {
        return float4(red, green, blue, alpha)
    }
}
