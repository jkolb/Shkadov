//
//  main.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/16/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import AppKit

private var mainWindow: NSWindow!
private var openGLContext: NSOpenGLContext!
private var windowDelegate: EngineWindowDelegate!
private var applicationDelegate: EngineApplicationDelegate!
private var engine: Engine!

func main() {
    let application = NSApplication.sharedApplication()
    application.setActivationPolicy(.Regular)
    application.mainMenu = createMainMenu()
    
    applicationDelegate = EngineApplicationDelegate()
    
    application.delegate = applicationDelegate
    
    openGLContext = createOpenGLContext()
    
    windowDelegate = EngineWindowDelegate()
    
    mainWindow = createMainWindow()
    mainWindow.delegate = windowDelegate
    mainWindow.title = "Test"
    mainWindow.collectionBehavior = .FullScreenPrimary
    mainWindow.contentMinSize = CGSize(width: 800.0, height: 600.0)
    
    let view = EngineView()
    let options: NSTrackingAreaOptions =  [NSTrackingAreaOptions.MouseEnteredAndExited, NSTrackingAreaOptions.MouseMoved, NSTrackingAreaOptions.InVisibleRect, NSTrackingAreaOptions.ActiveInKeyWindow]
    let trackingArea = NSTrackingArea(rect: mainWindow.contentView!.frame, options: options, owner: view, userInfo: nil)
    view.addTrackingArea(trackingArea)
    
    mainWindow.contentView = view

    mainWindow.makeKeyAndOrderFront(nil)
    
    application.run()
}

public func EngineMain() {
    openGLContext.makeCurrentContext()
    openGLContext.view = mainWindow.contentView
    openGLContext.update()

    let renderer = OpenGLRenderer(context: openGLContext)
    engine = Engine(renderer: renderer)
    
    engine.beginSimulation()
}

public func EngineShutdown() {
    mainWindow = nil
    openGLContext = nil
    windowDelegate = nil
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

main()
