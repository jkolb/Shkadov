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

public struct Angle : Equatable, Comparable, CustomStringConvertible {
    private static let degreesToRadians: Float = 0.0174532925199433
    private static let radiansToDegrees: Float = 57.295779513082321
    public static let min: Float = -twoPI
    public static let max: Float = +twoPI
    
    public var radians: Float {
        didSet {
            radians = Angle.clamped(radians) // TODO: This looks like it might be wrong
        }
    }
    
    public init() {
        self.init(radians: 0.0)
    }
    
    public init(radians: Float) {
        self.radians = Angle.clamped(radians)
    }
    
    private static func clamped(radians: Float) -> Float {
        var clampedRadians = radians
        
        while clampedRadians >= Angle.max {
            clampedRadians -= Angle.max
        }
        
        while clampedRadians < Angle.min {
            clampedRadians += Angle.max
        }
        
        return clampedRadians
    }
    
    public init(degrees: Float) {
        self.init(radians: Angle.degreesToRadians * degrees)
    }
    
    public var degrees: Float {
        return radians * Angle.radiansToDegrees
    }
    
    public var description: String {
        return radians.description
    }
}

public func ==(a: Angle, b: Angle) -> Bool {
    return a.radians == b.radians
}

public func <(a: Angle, b: Angle) -> Bool {
    return a.radians < b.radians
}

public func +(a: Angle, b: Angle) -> Angle {
    return Angle(radians: a.radians + b.radians)
}

public func -(a: Angle, b: Angle) -> Angle {
    return Angle(radians: a.radians - b.radians)
}

public func *(a: Angle, b: Float) -> Angle {
    return Angle(radians: a.radians * b)
}

public func *(a: Float, b: Angle) -> Angle {
    return Angle(radians: a * b.radians)
}

public func /(a: Angle, b: Float) -> Angle {
    return Angle(radians: a.radians / b)
}

public func +=(inout a: Angle, b: Angle) {
    a.radians = a.radians + b.radians
}

public func -=(inout a: Angle, b: Angle) {
    a.radians = a.radians - b.radians
}

// MARK: - Negation

public prefix func -(a: Angle) -> Angle {
    return Angle(radians: -a.radians)
}

public prefix func +(a: Angle) -> Angle {
    return a
}
