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

import AppKit

extension PlatformOSX {
    public func convertPointFromScreenToContent(screenPoint: CGPoint) -> CGPoint {
        let windowPoint = convertPointFromScreenToWindow(screenPoint)
        return convertPointFromWindowToContent(windowPoint)
    }
    
    public func convertPointFromScreenToWindow(screenPoint: CGPoint) -> CGPoint {
        let screenRect = screenPoint.rect
        let windowRect = convertRectFromScreenToWindow(screenRect)
        return windowRect.origin
    }
    
    public func convertPointFromWindowToContent(windowPoint: CGPoint) -> CGPoint {
        return mainWindow.contentView!.convertPoint(windowPoint, fromView: nil)
    }
    
    public func convertRectFromScreenToContent(screenRect: CGRect) -> CGRect {
        let windowRect = convertRectFromScreenToWindow(screenRect)
        return convertRectFromWindowToContent(windowRect)
    }
    
    public func convertRectFromScreenToWindow(screenRect: CGRect) -> CGRect {
        return mainWindow.convertRectFromScreen(screenRect)
    }
    
    public func convertRectFromWindowToContent(windowRect: CGRect) -> CGRect {
        return mainWindow.contentView!.convertRect(windowRect, fromView: nil)
    }
    
    public func convertPointFromContentToWindow(contentPoint: CGPoint) -> CGPoint {
        return mainWindow.contentView!.convertPoint(contentPoint, toView: nil)
    }
    
    public func convertPointFromWindowToScreen(windowPoint: CGPoint) -> CGPoint {
        let windowRect = windowPoint.rect
        return convertRectFromWindowToScreen(windowRect).origin
    }
    
    public func convertPointFromContentToScreen(point: CGPoint) -> CGPoint {
        let windowPoint = convertPointFromContentToWindow(point)
        return convertPointFromWindowToScreen(windowPoint)
    }
    
    public func convertRectFromContentToWindow(contentRect: CGRect) -> CGRect {
        return mainWindow.contentView!.convertRect(contentRect, toView: nil)
    }
    
    public func convertRectFromWindowToScreen(windowRect: CGRect) -> CGRect {
        return mainWindow.convertRectToScreen(windowRect)
    }
    
    public func convertRectFromContentToScreen(contentRect: CGRect) -> CGRect {
        let windowRect = convertRectFromContentToWindow(contentRect)
        return convertRectFromWindowToScreen(windowRect)
    }
    
    public func convertPointFromAppKitToCoreGraphics(appKitPoint: CGPoint) -> CGPoint {
        let primaryRect = primaryScreen.frame
        let coreGraphicsPoint = CGPoint(x: appKitPoint.x, y: primaryRect.height - appKitPoint.y)
        return coreGraphicsPoint
    }
}
