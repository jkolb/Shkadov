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

public func atan(angle: Angle) -> Float {
    return atan(angle.radians)
}

public func atan2(v: Vector2D) -> Angle {
    return Angle(radians: Darwin.atan2(v.y, v.x))
}

public func cos(angle: Angle) -> Float {
    return cos(angle.radians)
}

public func sin(angle: Angle) -> Float {
    return sin(angle.radians)
}

public func tan(angle: Angle) -> Float {
    return tan(angle.radians)
}

public func sincos(angle: Angle) -> (Float, Float) {
    return sincos(angle.radians)
}

public func atan(radians: Float) -> Float {
    return Darwin.atan(radians)
}

public func cos(radians: Float) -> Float {
    return Darwin.cos(radians)
}

public func sin(radians: Float) -> Float {
    return Darwin.sin(radians)
}

public func tan(radians: Float) -> Float {
    return Darwin.tan(radians)
}

public func sincos(radians: Float) -> (Float, Float) {
    var c: Float = 0.0
    var s: Float = 0.0
    __sincosf(radians, &s, &c)
    return (s, c)
}

public func sqrt(x: Float) -> Float {
    return Darwin.sqrt(x)
}

public func log2(x: Float) -> Float {
    return Darwin.log2(x)
}

public func floor(x: Float) -> Float {
    return Darwin.floor(x)
}

public func ceil(x: Float) -> Float {
    return Darwin.ceil(x)
}
