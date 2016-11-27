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

import CoreGraphics
import Swiftish

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
    
    public func move(to point: Vector2<Float>) {
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
