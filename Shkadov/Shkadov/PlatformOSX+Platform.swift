//
//  PlatformOSX+Platform.swift
//  Shkadov
//
//  Created by Justin Kolb on 9/7/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import AppKit

extension PlatformOSX : Platform {
    public var currentTime: Time {
        return Time(nanoseconds: mach_absolute_time() * timeBaseNumerator / timeBaseDenominator)
    }
    
    public func centerMouse() {
        let center = contentBounds.center2D
        mousePosition = center
    }
    
    public var mousePositionRelative: Bool {
        get {
            return relativeMouse
        }
        set {
            let changed = relativeMouse != newValue
            relativeMouse = newValue
            
            if changed {
                contentView.sendMouseDelta = relativeMouse
                
                if relativeMouse {
                    CGAssociateMouseAndMouseCursorPosition(0)
                }
                else {
                    CGAssociateMouseAndMouseCursorPosition(1)
                }
            }
        }
    }
    
    public var mousePosition: Point2D {
        get {
            let windowPoint = mainWindow.mouseLocationOutsideOfEventStream
            let contentPoint = convertPointFromWindowToContent(windowPoint)
            return contentPoint.point2D
        }
        set {
            let contentPoint = newValue.nativePoint
            let screenPoint = convertPointFromContentToScreen(contentPoint)
            let coreGraphicsPoint = convertPointFromAppKitToCoreGraphics(screenPoint)
            CGWarpMouseCursorPosition(coreGraphicsPoint)
        }
    }
}
