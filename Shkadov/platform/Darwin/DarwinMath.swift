//
//  Math.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

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
}
