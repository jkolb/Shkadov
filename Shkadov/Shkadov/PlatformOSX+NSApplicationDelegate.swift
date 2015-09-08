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

extension PlatformOSX : NSApplicationDelegate {
    public func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        NSLog("%@", __FUNCTION__)
        return .TerminateNow
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        NSLog("%@", __FUNCTION__)
        return true
    }
    
    public func applicationWillFinishLaunching(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationDidFinishLaunching(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        startEngine()
    }
    
    public func applicationWillHide(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationDidHide(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationWillUnhide(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationDidUnhide(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationWillBecomeActive(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationDidBecomeActive(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationWillResignActive(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationDidResignActive(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    //    public func applicationWillUpdate(notification: NSNotification) {
    //        NSLog("%@", __FUNCTION__)
    //    }
    
    //    public func applicationDidUpdate(notification: NSNotification) {
    //        NSLog("%@", __FUNCTION__)
    //    }
    
    public func applicationWillTerminate(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        stopEngine()
    }
}
