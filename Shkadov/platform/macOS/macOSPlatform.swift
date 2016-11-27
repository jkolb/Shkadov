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

public final class macOSPlatform : NSObject, Platform, NSApplicationDelegate, NSWindowDelegate {
    public weak var delegate: PlatformDelegate?
    fileprivate let logger: Logger

    public init(logger: Logger) {
        self.logger = logger
    }
    
    public func start() {
        logger.debug("\(#function)")
        let application = makeApplication()
//        window.makeKeyAndOrderFront(nil)
        application.run()
    }

    private func makeApplication() -> NSApplication {
        let application = NSApplication.shared()
        application.setActivationPolicy(.regular)
        application.mainMenu = makeMainMenu()
        application.delegate = self
        return application
    }
    
    private func makeMainMenu() -> NSMenu {
        let mainMenu = NSMenu()
        
        let applicationMenuItem = NSMenuItem()
        mainMenu.addItem(applicationMenuItem)
        
        let applicationMenu = NSMenu()
        applicationMenuItem.submenu = applicationMenu
        
        let applicationName = ProcessInfo.processInfo.processName
        applicationMenu.addItem(withTitle: "Quit \(applicationName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        
        let viewMenu = NSMenu(title: "View")
        viewMenuItem.submenu = viewMenu
        
        viewMenu.addItem(withTitle: "Toggle Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
        
        return mainMenu
    }
    
    public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        logger.debug("\(#function)")
        return .terminateNow
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        logger.debug("\(#function)")
        return true
    }
    
    public func applicationWillFinishLaunching(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        logger.debug("\(#function)")
//        engine.start()
    }
    
    public func applicationWillHide(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidHide(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillUnhide(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidUnhide(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillBecomeActive(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidBecomeActive(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillResignActive(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationDidResignActive(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func applicationWillTerminate(_ notification: Notification) {
        logger.debug("\(#function)")
        delegate?.platformWillTerminate(platform: self)
    }
    
    public func windowDidBecomeKey(_ notification: Notification) {
        logger.debug("\(#function)")
//        window.makeFirstResponder(viewController)
    }
    
    public func windowDidResignKey(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidBecomeMain(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidResignMain(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        logger.debug("\(#function) \(frameSize)")
        return frameSize
    }
    
    public func windowDidResize(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillClose(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillEnterFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidEnterFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillExitFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidExitFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillMove(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowDidMove(_ notification: Notification) {
        logger.debug("\(#function)")
    }
}
