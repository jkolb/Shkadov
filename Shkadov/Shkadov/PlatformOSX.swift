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

public class PlatformOSX : NSObject, Platform {
    private let timeBaseNumerator: TimeType
    private let timeBaseDenominator: TimeType
    
    private var mainWindow: NSWindow!
    private var openGLContext: NSOpenGLContext!
    private var engine: Engine!

    public override init() {
        var timeBaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeBaseInfo)
        self.timeBaseNumerator = TimeType(timeBaseInfo.numer)
        self.timeBaseDenominator = TimeType(timeBaseInfo.denom)
    }
    
    public func main() {
        let application = NSApplication.sharedApplication()
        application.setActivationPolicy(.Regular)
        application.mainMenu = createMainMenu()
        application.delegate = self

        openGLContext = createOpenGLContext()
        
        let renderer = OpenGLRenderer(context: openGLContext)
        engine = Engine(platform: self, renderer: renderer)

        mainWindow = createMainWindow()
        mainWindow.delegate = self
        mainWindow.title = "Test"
        mainWindow.collectionBehavior = .FullScreenPrimary
        mainWindow.contentMinSize = CGSize(width: 800.0, height: 600.0)
        
        let view = ContentView()
        view.engine = engine
        let options: NSTrackingAreaOptions =  [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.InVisibleRect, NSTrackingAreaOptions.ActiveInKeyWindow]
        let trackingArea = NSTrackingArea(rect: mainWindow.contentView!.frame, options: options, owner: view, userInfo: nil)
        view.addTrackingArea(trackingArea)
        
        mainWindow.contentView = view
        openGLContext.view = mainWindow.contentView

        mainWindow.makeKeyAndOrderFront(nil)
        
        application.run()
    }
    
    public var currentTime: Time {
        return Time(nanoseconds: mach_absolute_time() * timeBaseNumerator / timeBaseDenominator)
    }
    
    private func startEngine() {
        engine.updateViewport(mainWindow.viewport)
        engine.start()
    }
    
    public func stopEngine() {
        engine.stop()
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
        engine.updateViewport(mainWindow.viewport)
    }
    
    public func windowWillClose(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
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
    public var viewport: Rectangle2D {
        return self.contentRectForFrameRect(self.contentView!.bounds).rectagle2D
    }
}

public extension CGPoint {
    public var point2D: Point2D {
        return Point2D(x: GeometryType(x), y: GeometryType(y))
    }
}

public extension CGSize {
    public var size2D: Size2D {
        return Size2D(width: GeometryType(width), height: GeometryType(height))
    }
}

public extension CGRect {
    public var rectagle2D: Rectangle2D {
        return Rectangle2D(origin: origin.point2D, size: size.size2D)
    }
}
