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

public class PlatformOSX : NSObject {
    private static let minimumWidth: CGFloat = 640.0
    private static let minimumHeight: CGFloat = 480.0
    public let timeBaseNumerator: TimeType
    public let timeBaseDenominator: TimeType
    public private(set) var mainWindow: NSWindow!
    public private(set) var viewController: ViewController!
    private var engine: Engine!
    public var relativeMouse = false
    
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
        
        let renderer = MetalRenderer()
        engine = Engine(platform: self, renderer: renderer, assetLoader: self)

        mainWindow = createMainWindow()
        mainWindow.delegate = self
        mainWindow.title = applicationName
        mainWindow.collectionBehavior = .FullScreenPrimary
        mainWindow.contentMinSize = CGSize(width: PlatformOSX.minimumWidth, height: PlatformOSX.minimumHeight)
        
        viewController = ViewController()
        viewController.engine = engine
        viewController.viewSource = renderer
        
        let options: NSTrackingAreaOptions = [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.InVisibleRect, NSTrackingAreaOptions.ActiveInKeyWindow]
        let trackingArea = NSTrackingArea(rect: viewController.view.frame, options: options, owner: viewController.view, userInfo: nil)
        viewController.view.addTrackingArea(trackingArea)
        
        mainWindow.contentView = viewController.view

        mainWindow.makeKeyAndOrderFront(nil)
        mainWindow.makeFirstResponder(viewController)
        
        application.run()
    }
    
    public var primaryScreen: NSScreen {
        return NSScreen.screens()![0]
    }
    
    private var applicationName: String {
        return NSProcessInfo.processInfo().processName
    }
    
    public func startEngine() {
        engine.updateViewport(viewport)
        engine.start()
    }
    
    public func stopEngine() {
        engine.stop()
    }

    public func updateViewport() {
        engine.updateViewport(viewport)
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

    public var contentBounds: CGRect {
        return mainWindow.contentView!.bounds
    }
    
    private var contentFrame: CGRect {
        let windowFrame = mainWindow.frame
        let contentFrame = mainWindow.contentRectForFrameRect(windowFrame)
        return contentFrame
    }
    
    public func saveSizeAndPosition() {
        storeWindowContentFrame(contentFrame)
    }
}
