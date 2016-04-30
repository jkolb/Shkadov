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
