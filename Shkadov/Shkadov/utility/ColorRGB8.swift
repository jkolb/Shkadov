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

public struct ColorRGBA8 {
    public static var black = ColorRGBA8(red: 0, green: 0, blue: 0)
    public static var grey = ColorRGBA8(red: 128, green: 128, blue: 128)
    public static var white = ColorRGBA8(red: 255, green: 255, blue: 255)
    public static var red = ColorRGBA8(red: 255, green: 0, blue: 0)
    public static var green = ColorRGBA8(red: 0, green: 128, blue: 0)
    public static var blue = ColorRGBA8(red: 0, green: 0, blue: 255)
    public static var yellow = ColorRGBA8(red: 255, green: 255, blue: 0)
    public static var magenta = ColorRGBA8(red: 255, green: 0, blue: 255)
    public static var cyan = ColorRGBA8(red: 0, green: 255, blue: 255)
    public static var brown = ColorRGBA8(red: 165, green: 42, blue: 42)
    public static var pink = ColorRGBA8(red: 255, green: 192, blue: 203)
    public static var lime = ColorRGBA8(red: 0, green: 255, blue: 0)
    public static var orange = ColorRGBA8(red: 255, green: 165, blue: 0)
    public static var silver = ColorRGBA8(red: 192, green: 192, blue: 192)
    public static var teal = ColorRGBA8(red: 0, green: 128, blue: 128)
    public static var olive = ColorRGBA8(red: 128, green: 128, blue: 0)
    public static var purple = ColorRGBA8(red: 128, green: 0, blue: 128)
    public static var navy = ColorRGBA8(red: 0, green: 0, blue: 128)
    public static var maroon = ColorRGBA8(red: 128, green: 0, blue: 0)
    
    public var red: UInt8
    public var green: UInt8
    public var blue: UInt8
    public var alpha: UInt8
    
    public init(rgb: UInt32) {
        precondition(rgb <= 0xFFFFFF)
        self.init(
            red: UInt8((rgb & 0x00FF0000) >> 16),
            green: UInt8((rgb & 0x0000FF00) >> 8),
            blue: UInt8((rgb & 0x000000FF) >> 0)
        )
    }
    
    public init(rgba: UInt32) {
        self.init(
            red: UInt8((rgba & 0xFF000000) >> 24),
            green: UInt8((rgba & 0x00FF0000) >> 16),
            blue: UInt8((rgba & 0x0000FF00) >> 8),
            alpha: UInt8((rgba & 0x000000FF) >> 0)
        )
    }
    
    public init(red: UInt8 = 0, green: UInt8 = 0, blue: UInt8 = 0, alpha: UInt8 = 255) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}
