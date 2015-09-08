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

extension PlatformOSX : NSWindowDelegate {
    // TODO: Check to see if there are other useful methods to override
    public func windowDidBecomeKey(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowDidResignKey(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowDidBecomeMain(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowDidResignMain(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        NSLog("%@", __FUNCTION__)
        return frameSize
    }
    
    public func windowDidResize(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        updateViewport()
        
        if mousePositionRelative {
            centerMouse()
        }
    }
    
    public func windowWillClose(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        saveSizeAndPosition()
    }
    
    public func windowWillEnterFullScreen(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowDidEnterFullScreen(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowWillExitFullScreen(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowDidExitFullScreen(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowWillMove(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func windowDidMove(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
}
