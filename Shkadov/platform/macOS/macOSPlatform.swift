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
import Swiftish

public final class macOSPlatform : NSObject, Platform, NSApplicationDelegate, NSWindowDelegate {
    public weak var listener: PlatformListener?
    private let config: WindowConfig
    private let logger: Logger
    private let window: NSWindow
    private var started: Bool
    
    public init(config: WindowConfig, contentView: NSView, logger: Logger) {
        self.started = false
        self.config = config
        self.logger = logger
        let contentRect = NSRect(
            x: 0,
            y: 0,
            width: config.width,
            height: config.height
        )
        self.window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        super.init()
        window.title = config.title
        window.collectionBehavior = .fullScreenPrimary
        window.contentView = contentView
        window.delegate = self
        window.center()
    }

    public var screensSize: Vector2<Int> {
        if let screen = window.screen {
            return screen.frame.size.toVector()
        }

        return Vector2<Int>()
    }

    public var isFullScreen: Bool {
        return NSApplication.shared().presentationOptions.contains(.fullScreen)
    }
    
    public func toggleFullScreen() {
        window.toggleFullScreen(nil)
    }
    
    public func enterFullScreen() {
        if isFullScreen { return }
        
        toggleFullScreen()
    }
    
    public func exitFullScreen() {
        if !isFullScreen { return }
        
        toggleFullScreen()
    }
    
    public func windowDidBecomeKey(_ notification: Notification) {
        logger.debug("\(#function)")
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
        
        if started {
            if let listener = listener {
                let updatedSize = listener.willResizeScreen(size: Vector2<Int>(Int(frameSize.width), Int(frameSize.height)))
                logger.debug("\(updatedSize)")
                return NSSize(width: updatedSize.width, height: updatedSize.height)
            }
        }
        
        return frameSize
    }
    
    public func windowDidResize(_ notification: Notification) {
        logger.debug("\(#function)")
        
        if started {
            listener?.didResizeScreen()
        }
    }
    
    public func windowWillClose(_ notification: Notification) {
        logger.debug("\(#function)")
    }
    
    public func windowWillEnterFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")

        if started {
            listener?.willEnterFullScreen()
        }
    }
    
    public func windowDidEnterFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")
        
        if !started {
            didStartup()
        }
        else {
            listener?.didEnterFullScreen()
        }
    }
    
    public func windowWillExitFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")
        
        if started {
            listener?.willExitFullScreen()
        }
    }
    
    public func windowDidExitFullScreen(_ notification: Notification) {
        logger.debug("\(#function)")
        
        if started {
            listener?.didExitFullScreen()
        }
    }
    
    public func windowWillMove(_ notification: Notification) {
        logger.debug("\(#function)")
        
        if started {
            listener?.willMoveScreen()
        }
    }
    
    public func windowDidMove(_ notification: Notification) {
        logger.debug("\(#function)")
        
        if started {
            listener?.didMoveScreen()
        }
    }
    
    public func startup() {
        precondition(!started)
        let application = NSApplication.shared()
        application.setActivationPolicy(.regular)
        application.mainMenu = makeMainMenu()
        application.delegate = self
        window.makeKeyAndOrderFront(nil)
        application.run()
    }
    
    private func didStartup() {
        started = true
        listener?.didStartup()
    }
    
    public func shutdown() {
        precondition(started)
        NSApplication.shared().terminate(nil)
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
        
        if config.fullscreen {
            enterFullScreen()
        }
        else {
            didStartup()
        }
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
        listener?.willShutdown()
    }
}

extension CGSize {
    public func toVector() -> Vector2<Int> {
        return Vector2<Int>(Int(width), Int(height))
    }
}
