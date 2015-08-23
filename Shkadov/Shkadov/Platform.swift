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

public class Platform : NSObject {
    private var mainWindow: NSWindow!
    private var openGLContext: NSOpenGLContext!
    private var engine: Engine!
    private var initializing = true
    private var terminating = false

    public func main() {
        let application = NSApplication.sharedApplication()
        application.setActivationPolicy(.Regular)
        application.mainMenu = createMainMenu()
        application.delegate = self
        
        openGLContext = createOpenGLContext()
        
        mainWindow = createMainWindow()
        mainWindow.delegate = self
        mainWindow.title = "Test"
        mainWindow.collectionBehavior = .FullScreenPrimary
        mainWindow.contentMinSize = CGSize(width: 800.0, height: 600.0)
        
        let view = ContentView()
        let options: NSTrackingAreaOptions =  [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.InVisibleRect, NSTrackingAreaOptions.ActiveInKeyWindow]
        let trackingArea = NSTrackingArea(rect: mainWindow.contentView!.frame, options: options, owner: view, userInfo: nil)
        view.addTrackingArea(trackingArea)
        
        mainWindow.contentView = view
        
        mainWindow.makeKeyAndOrderFront(nil)
        
        application.run()
    }
    
    private func startEngine() {
        openGLContext.makeCurrentContext()
        openGLContext.view = mainWindow.contentView
        openGLContext.update()
        
        let renderer = OpenGLRenderer(context: openGLContext)
        engine = Engine(renderer: renderer)
        engine.updateViewport(mainWindow.viewport)
        engine.beginSimulation()
    }
    
    public func stopEngine() {
        mainWindow = nil
        openGLContext = nil
        NSApplication.sharedApplication().terminate(nil)
    }

    private func createMainMenu() -> NSMenu {
        let mainMenu = NSMenu()
        
        let applicationMenuItem = NSMenuItem()
        mainMenu.addItem(applicationMenuItem)
        
        let applicationMenu = NSMenu()
        applicationMenuItem.submenu = applicationMenu
        
        applicationMenu.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "q")
        
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        
        let viewMenu = NSMenu(title: "View")
        viewMenuItem.submenu = viewMenu
        
        viewMenu.addItemWithTitle("Toggle Full Screen", action: "toggleFullScreen:", keyEquivalent: "f")
        
        return mainMenu
    }

    private func createMainWindow() -> NSWindow {
        let mainScreen = NSScreen.mainScreen()!
        let screenFrame = mainScreen.frame
        var contentFrame = CGRectZero
        contentFrame.size.width = 800.0
        contentFrame.size.height = 600.0
        contentFrame.origin.x = (screenFrame.size.width - contentFrame.size.width) * 0.5
        contentFrame.origin.y = (screenFrame.size.height - contentFrame.size.height) * 0.5
        
        return NSWindow(contentRect: contentFrame, styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask, backing: .Buffered, `defer`: false)
    }
    
    private func createOpenGLContext() -> NSOpenGLContext {
        let attributes: [NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFADepthSize), NSOpenGLPixelFormatAttribute(24),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile), NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),
        ]
        
        let pixelFormat = NSOpenGLPixelFormat(attributes: attributes)
        let openGLContext = NSOpenGLContext(format: pixelFormat!, shareContext: nil)
        
        return openGLContext!
    }
}

extension Platform : NSApplicationDelegate {
    public func applicationWillFinishLaunching(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
    }
    
    public func applicationDidFinishLaunching(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
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
    }
}

extension Platform : NSWindowDelegate {
    // TODO: Check to see if there are other useful methods to override
    public func windowDidBecomeKey(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        
        if initializing {
            initializing = false
            startEngine()
        }
    }
    
    public func windowDidResignKey(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        if terminating {
            terminating = false
//            stopEngine()
        }
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
        engine.updateViewport(mainWindow.viewport)
    }
    
    public func windowWillClose(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        terminating = true
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

public extension NSWindow {
    public var viewport: Viewport {
        return self.contentRectForFrameRect(self.contentView!.bounds).viewport
    }
}

public extension CGRect {
    public var viewport: Viewport {
        return Viewport(
            x: Int32(self.origin.x),
            y: Int32(self.origin.y),
            width: UInt16(self.size.width),
            height: UInt16(self.size.height)
        )
    }
}
