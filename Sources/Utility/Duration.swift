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

public struct Duration: Comparable, Equatable {
    public static let zero = Duration(nanoseconds: 0)
    
    public var nanoseconds: TimeType
    
    public init(seconds: Double) {
        precondition(seconds >= 0.0)
        self.nanoseconds = TimeType(seconds * Double(Time.nanosecondsPerSecond))
    }
    
    public init(milliseconds: TimeType) {
        self.nanoseconds = milliseconds * Time.millisecondsPerNanosecond
    }
    
    public init(nanoseconds: TimeType) {
        self.nanoseconds = nanoseconds
    }
    
    public var milliseconds: TimeType {
        return nanoseconds / Time.millisecondsPerNanosecond
    }
    
    public var seconds: Double {
        return Double(nanoseconds) / Double(Time.nanosecondsPerSecond)
    }
    
    public static func ==(a: Duration, b: Duration) -> Bool {
        return a.nanoseconds == b.nanoseconds
    }
    
    public static func <(a: Duration, b: Duration) -> Bool {
        return a.nanoseconds < b.nanoseconds
    }

    public static func +(a: Duration, b: Duration) -> Duration {
        return Duration(nanoseconds: a.nanoseconds + b.nanoseconds)
    }

    public static func -(a: Duration, b: Duration) -> Duration {
        return Duration(nanoseconds: a.nanoseconds - b.nanoseconds)
    }

    public static func *(a: Duration, b: TimeType) -> Duration {
        return Duration(nanoseconds: a.nanoseconds * b)
    }

    public static func /(a: Duration, b: TimeType) -> Duration {
        return Duration(nanoseconds: a.nanoseconds / b)
    }

    public static func +=(a: inout Duration, b: Duration) {
        a.nanoseconds = a.nanoseconds + b.nanoseconds
    }

    public static func -=(a: inout Duration, b: Duration) {
        a.nanoseconds = a.nanoseconds - b.nanoseconds
    }

    public static func *=(a: inout Duration, b: TimeType) {
        a.nanoseconds = a.nanoseconds * b
    }

    public static func /=(a: inout Duration, b: TimeType) {
        a.nanoseconds = a.nanoseconds / b
    }
}
