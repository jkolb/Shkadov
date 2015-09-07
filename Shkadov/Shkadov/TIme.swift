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

public typealias TimeType = UInt64

private let millisecondsPerSecond: TimeType = 1_000
private let nanosecondsPerSecond: TimeType = 1_000_000_000
private let millisecondsPerNanosecond = nanosecondsPerSecond / millisecondsPerSecond

public struct Time : Comparable, Equatable, Hashable {
    public static let zero = Time(nanoseconds: 0)
    
    public let nanoseconds: TimeType
    
    public init(seconds: Double) {
        precondition(seconds >= 0.0)
        self.nanoseconds = TimeType(seconds * Double(nanosecondsPerSecond))
    }
    
    public init(milliseconds: TimeType) {
        self.nanoseconds = milliseconds * millisecondsPerNanosecond
    }
    
    public init(nanoseconds: TimeType) {
        self.nanoseconds = nanoseconds
    }
    
    public var milliseconds: TimeType {
        return nanoseconds / millisecondsPerNanosecond
    }
    
    public var seconds: Double {
        return Double(nanoseconds) / Double(nanosecondsPerSecond)
    }
    
    public var hashValue: Int {
        return nanoseconds.hashValue
    }
}

public func ==(a: Time, b: Time) -> Bool {
    return a.nanoseconds == b.nanoseconds
}

public func <(a: Time, b: Time) -> Bool {
    return a.nanoseconds < b.nanoseconds
}

public func -(a: Time, b: Time) -> Duration {
    if a < b {
        return Duration(nanoseconds: b.nanoseconds - a.nanoseconds)
    }
    else {
        return Duration(nanoseconds: a.nanoseconds - b.nanoseconds)
    }
}

public func +(a: Time, b: Duration) -> Time {
    return Time(nanoseconds: a.nanoseconds + b.nanoseconds)
}

public struct Duration: Comparable, Equatable {
    public static let zero = Duration(nanoseconds: 0)
    
    public var nanoseconds: TimeType
    
    public init(seconds: Double) {
        precondition(seconds >= 0.0)
        self.nanoseconds = TimeType(seconds * Double(nanosecondsPerSecond))
    }
    
    public init(milliseconds: TimeType) {
        self.nanoseconds = milliseconds * millisecondsPerNanosecond
    }
    
    public init(nanoseconds: TimeType) {
        self.nanoseconds = nanoseconds
    }
    
    public var milliseconds: TimeType {
        return nanoseconds / millisecondsPerNanosecond
    }
    
    public var seconds: Double {
        return Double(nanoseconds) / Double(nanosecondsPerSecond)
    }
}

public func ==(a: Duration, b: Duration) -> Bool {
    return a.nanoseconds == b.nanoseconds
}

public func <(a: Duration, b: Duration) -> Bool {
    return a.nanoseconds < b.nanoseconds
}

public func +(a: Duration, b: Duration) -> Duration {
    return Duration(nanoseconds: a.nanoseconds + b.nanoseconds)
}

public func -(a: Duration, b: Duration) -> Duration {
    return Duration(nanoseconds: a.nanoseconds - b.nanoseconds)
}

public func *(a: Duration, b: TimeType) -> Duration {
    return Duration(nanoseconds: a.nanoseconds * b)
}

public func /(a: Duration, b: TimeType) -> Duration {
    return Duration(nanoseconds: a.nanoseconds / b)
}

public func +=(inout a: Duration, b: Duration) {
    a.nanoseconds = a.nanoseconds + b.nanoseconds
}

public func -=(inout a: Duration, b: Duration) {
    a.nanoseconds = a.nanoseconds - b.nanoseconds
}

public func *=(inout a: Duration, b: TimeType) {
    a.nanoseconds = a.nanoseconds * b
}

public func /=(inout a: Duration, b: TimeType) {
    a.nanoseconds = a.nanoseconds / b
}
