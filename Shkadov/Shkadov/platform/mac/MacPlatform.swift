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

import AppKit

public final class MacPlatform : NSObject, Platform, NSApplicationDelegate, NSWindowDelegate {
    public weak var delegate: PlatformDelegate!

    private let application: NSApplication
    private let window: NSWindow
    private let viewController: NSViewController
    private let logger: Logger
    
    public init(application: NSApplication, window: NSWindow, viewController: NSViewController, logger: Logger) {
        self.application = application
        self.window = window
        self.viewController = viewController
        self.logger = logger
    }
    
    public func start() {
        logger.debug("\(#function)")
        window.makeKeyAndOrderFront(nil)
        application.run()
    }

    public func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        logger.debug("\(#function)")
        return .TerminateNow
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        logger.debug("\(#function)")
        return true
    }
    
    public func applicationWillFinishLaunching(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidFinishLaunching(notification: NSNotification) {
        logger.debug("\(#function)")
        delegate.platformDidStart(self)
    }
    
    public func applicationWillHide(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidHide(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillUnhide(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidUnhide(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillBecomeActive(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidBecomeActive(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillResignActive(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidResignActive(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillTerminate(notification: NSNotification) {
        logger.debug("\(#function)")
    }

    public func windowDidBecomeKey(notification: NSNotification) {
        logger.debug("\(#function)")
        window.makeFirstResponder(viewController)
    }
    
    public func windowDidResignKey(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidBecomeMain(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidResignMain(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillResize(sender: NSWindow, toSize frameSize: NSSize) -> NSSize {
        logger.debug("\(#function) \(frameSize)")
        return frameSize
    }
    
    public func windowDidResize(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillClose(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillEnterFullScreen(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidEnterFullScreen(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillExitFullScreen(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidExitFullScreen(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillMove(notification: NSNotification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidMove(notification: NSNotification) {
        logger.debug("\(#function)")
    }
}
