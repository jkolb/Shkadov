//
//  macOSMouseCursorManager.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

import CoreGraphics
import Swiftish

public protocol MouseCursorManager : class {
    var hidden: Bool { get set }
    var followsMouse: Bool { get set }
    
    func moveToPoint(_ point: Vector2<Float>)
}

public final class macOSMouseCursorManager : MouseCursorManager {
    public weak var delegate: macOSMouseCursorManagerDelegate!
    public var hidden: Bool {
        didSet {
            if hidden {
                CGDisplayHideCursor(CGMainDisplayID())
            }
            else {
                CGDisplayShowCursor(CGMainDisplayID())
            }
        }
    }
    public var followsMouse: Bool {
        didSet {
            if followsMouse {
                CGAssociateMouseAndMouseCursorPosition(1)
            }
            else {
                CGAssociateMouseAndMouseCursorPosition(0)
            }
            
            delegate.macOSMouseCursorManager(self, updatedFollowsMouse: followsMouse)
        }
    }
    
    public func moveToPoint(_ point: Vector2<Float>) {
        CGWarpMouseCursorPosition(CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
    }
    
    public init() {
        self.hidden = false
        self.followsMouse = true
    }
}

public protocol macOSMouseCursorManagerDelegate : class {
    func macOSMouseCursorManager(_ macOSMouseCursorManager: macOSMouseCursorManager, updatedFollowsMouse followsMouse: Bool)
}
