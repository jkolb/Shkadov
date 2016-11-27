//
//  Time.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

public protocol TimeSource : class {
    var currentTime: Time { get }
}

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
    
    public static func ==(a: Time, b: Time) -> Bool {
        return a.nanoseconds == b.nanoseconds
    }
    
    public static func <(a: Time, b: Time) -> Bool {
        return a.nanoseconds < b.nanoseconds
    }
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
    
    public static func ==(a: Duration, b: Duration) -> Bool {
        return a.nanoseconds == b.nanoseconds
    }
    
    public static func <(a: Duration, b: Duration) -> Bool {
        return a.nanoseconds < b.nanoseconds
    }
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

public func +=(a: inout Duration, b: Duration) {
    a.nanoseconds = a.nanoseconds + b.nanoseconds
}

public func -=(a: inout Duration, b: Duration) {
    a.nanoseconds = a.nanoseconds - b.nanoseconds
}

public func *=(a: inout Duration, b: TimeType) {
    a.nanoseconds = a.nanoseconds * b
}

public func /=(a: inout Duration, b: TimeType) {
    a.nanoseconds = a.nanoseconds / b
}
