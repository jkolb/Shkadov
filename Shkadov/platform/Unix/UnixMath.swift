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

import Darwin

public extension Float {
    public static func cos(_ x: Float) -> Float {
        return Darwin.cos(x)
    }
    
    public static func sin(_ x: Float) -> Float {
        return Darwin.sin(x)
    }
    
    public static func tan(_ x: Float) -> Float {
        return Darwin.tan(x)
    }
    
    public static func asin(_ x: Float) -> Float {
        return Darwin.asin(x)
    }
    
    public static func acos(_ x: Float) -> Float {
        return Darwin.acos(x)
    }
    
    public static func atan(_ x: Float) -> Float {
        return Darwin.atan(x)
    }
    
    public static func exp(_ x: Float) -> Float {
        return Darwin.exp(x)
    }
    
    public static func pow(_ x: Float, _ y: Float) -> Float {
        return Darwin.pow(x, y)
    }
    
    public static func atan2(_ x: Float, _ y: Float) -> Float {
        return Darwin.atan2(x, y)
    }
    
    public static func trunc(_ x: Float) -> Float {
        return Darwin.trunc(x)
    }
    
    public static func sqrt(_ x: Float) -> Float {
        return x.squareRoot()
    }
    
    public static func floor(_ x: Float) -> Float {
        return Darwin.floor(x)
    }
    
    public static func ceil(_ x: Float) -> Float {
        return Darwin.ceil(x)
    }
    
    public static func log2(_ x: Float) -> Float {
        return Darwin.log2(x)
    }
}
