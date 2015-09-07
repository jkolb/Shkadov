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
import CoreGraphics

public class PlatformOSX : NSObject, Platform {
    private static let minimumWidth: CGFloat = 640.0
    private static let minimumHeight: CGFloat = 480.0
    private let timeBaseNumerator: TimeType
    private let timeBaseDenominator: TimeType
    public var mousePositionRelative: Bool = false {
        didSet {
            if mousePositionRelative != oldValue {
                contentView.sendMouseDelta = mousePositionRelative
                
                if mousePositionRelative {
                    CGAssociateMouseAndMouseCursorPosition(0)
                }
                else {
                    CGAssociateMouseAndMouseCursorPosition(1)
                }
            }
        }
    }
    private var mainWindow: NSWindow!
    private var contentView: ContentView!
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
        mainWindow.title = applicationName
        mainWindow.collectionBehavior = .FullScreenPrimary
        mainWindow.contentMinSize = CGSize(width: PlatformOSX.minimumWidth, height: PlatformOSX.minimumHeight)
        
        contentView = ContentView()
        contentView.engine = engine
        
        let options: NSTrackingAreaOptions =  [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.InVisibleRect, NSTrackingAreaOptions.ActiveInKeyWindow]
        let trackingArea = NSTrackingArea(rect: contentView.frame, options: options, owner: contentView, userInfo: nil)
        contentView.addTrackingArea(trackingArea)
        
        mainWindow.contentView = contentView
        openGLContext.view = contentView

        mainWindow.makeKeyAndOrderFront(nil)
        
        application.run()
    }
    
    public var currentTime: Time {
        return Time(nanoseconds: mach_absolute_time() * timeBaseNumerator / timeBaseDenominator)
    }

    public func centerMouse() {
        let center = contentBounds.center2D
        mousePosition = center
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

    private func convertPointFromScreenToContent(screenPoint: CGPoint) -> CGPoint {
        let windowPoint = convertPointFromScreenToWindow(screenPoint)
        return convertPointFromWindowToContent(windowPoint)
    }
    
    private func convertPointFromScreenToWindow(screenPoint: CGPoint) -> CGPoint {
        let screenRect = screenPoint.rect
        let windowRect = convertRectFromScreenToWindow(screenRect)
        return windowRect.origin
    }
    
    private func convertPointFromWindowToContent(windowPoint: CGPoint) -> CGPoint {
        return mainWindow.contentView!.convertPoint(windowPoint, fromView: nil)
    }
    
    private func convertRectFromScreenToContent(screenRect: CGRect) -> CGRect {
        let windowRect = convertRectFromScreenToWindow(screenRect)
        return convertRectFromWindowToContent(windowRect)
    }
    
    private func convertRectFromScreenToWindow(screenRect: CGRect) -> CGRect {
        return mainWindow.convertRectFromScreen(screenRect)
    }
    
    private func convertRectFromWindowToContent(windowRect: CGRect) -> CGRect {
        return mainWindow.contentView!.convertRect(windowRect, fromView: nil)
    }
    
    private func convertPointFromContentToWindow(contentPoint: CGPoint) -> CGPoint {
        return mainWindow.contentView!.convertPoint(contentPoint, toView: nil)
    }
    
    private func convertPointFromWindowToScreen(windowPoint: CGPoint) -> CGPoint {
        let windowRect = windowPoint.rect
        return convertRectFromWindowToScreen(windowRect).origin
    }

    private func convertPointFromContentToScreen(point: CGPoint) -> CGPoint {
        let windowPoint = convertPointFromContentToWindow(point)
        return convertPointFromWindowToScreen(windowPoint)
    }

    private func convertRectFromContentToWindow(contentRect: CGRect) -> CGRect {
        return mainWindow.contentView!.convertRect(contentRect, toView: nil)
    }
    
    private func convertRectFromWindowToScreen(windowRect: CGRect) -> CGRect {
        return mainWindow.convertRectToScreen(windowRect)
    }
    
    private func convertRectFromContentToScreen(contentRect: CGRect) -> CGRect {
        let windowRect = convertRectFromContentToWindow(contentRect)
        return convertRectFromWindowToScreen(windowRect)
    }

    private func convertPointFromAppKitToCoreGraphics(appKitPoint: CGPoint) -> CGPoint {
        let primaryRect = primaryScreen.frame
        let coreGraphicsPoint = CGPoint(x: appKitPoint.x, y: primaryRect.height - appKitPoint.y)
        return coreGraphicsPoint
    }
    
    private var primaryScreen: NSScreen {
        return NSScreen.screens()![0]
    }
    
    private var applicationName: String {
        return NSProcessInfo.processInfo().processName
    }
    
    private func startEngine() {
        engine.updateViewport(viewport)
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
        
        applicationMenu.addItemWithTitle("Quit \(applicationName)", action: "terminate:", keyEquivalent: "q")
        
        let viewMenuItem = NSMenuItem()
        mainMenu.addItem(viewMenuItem)
        
        let viewMenu = NSMenu(title: "View")
        viewMenuItem.submenu = viewMenu
        
        viewMenu.addItemWithTitle("Toggle Full Screen", action: "toggleFullScreen:", keyEquivalent: "f")
        
        return mainMenu
    }

    private func createMainWindow() -> NSWindow {
        let contentFrame = initialWindowContentFrame()
        
        return NSWindow(contentRect: contentFrame, styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask, backing: .Buffered, `defer`: false)
    }
    
    private func initialWindowContentFrame() -> CGRect {
        if let contentFrame = loadWindowContentFrame() {
            return contentFrame
        }
        
        var contentFrame = CGRect.zero
        let mainScreen = NSScreen.mainScreen()!
        let screenFrame = mainScreen.frame
        contentFrame.size.width = floor(screenFrame.width * 0.5)
        contentFrame.size.height = floor(screenFrame.height * 0.5)
        
        if contentFrame.width < PlatformOSX.minimumWidth || contentFrame.height < PlatformOSX.minimumHeight {
            contentFrame.size.width = PlatformOSX.minimumWidth
            contentFrame.size.height = PlatformOSX.minimumHeight
        }
        
        contentFrame.origin.x = floor((screenFrame.width - contentFrame.width) * 0.5)
        contentFrame.origin.y = floor((screenFrame.height - contentFrame.height) * 0.5)
        
        if contentFrame.minX < 0.0 { contentFrame.origin.x = 0.0 }
        if contentFrame.minY < 0.0 { contentFrame.origin.y = 0.0 }

        return contentFrame
    }
    
    private var viewport: Rectangle2D {
        return contentBounds.rectagle2D
    }

    private var contentBounds: CGRect {
        return mainWindow.contentView!.bounds
    }
    
    private var contentFrame: CGRect {
        let windowFrame = mainWindow.frame
        let contentFrame = mainWindow.contentRectForFrameRect(windowFrame)
        return contentFrame
    }
    
    private func loadWindowContentFrame() -> CGRect? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let contentFrameDictionary = userDefaults.dictionaryForKey("net.franticapparatus.config.contentFrame") {
            var contentFrame = CGRect.zero
            
            if CGRectMakeWithDictionaryRepresentation(contentFrameDictionary, &contentFrame) {
                return contentFrame
            }
        }
        
        return nil
    }
    
    private func storeWindowContentFrame(contentFrame: CGRect) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let contentFrameDictionary = CGRectCreateDictionaryRepresentation(contentFrame)
        userDefaults.setObject(contentFrameDictionary, forKey: "net.franticapparatus.config.contentFrame")
        userDefaults.synchronize()
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
        engine.updateViewport(viewport)
        
        if mousePositionRelative {
            centerMouse()
        }
    }
    
    public func windowWillClose(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        storeWindowContentFrame(contentFrame)
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

public extension Point2D {
    public var nativePoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

public extension CGPoint {
    public var point2D: Point2D {
        return Point2D(x: GeometryType(x), y: GeometryType(y))
    }
    
    public var rect: CGRect {
        return CGRect(origin: self, size: CGSize.zero)
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
    
    public var center2D: Point2D {
        return CGPoint(x: midX, y: midY).point2D
    }
}
