//
//  macOSPlatform.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

import AppKit
import MetalKit

public protocol Platform : class {
    func start()
}

public final class macOSPlatform : NSObject, Platform, NSApplicationDelegate, NSWindowDelegate, MTKViewDelegate {
    fileprivate let application: NSApplication
    fileprivate let window: NSWindow
    fileprivate let viewController: NSViewController
    fileprivate let engine: Engine
    fileprivate let logger: Logger

    public init(application: NSApplication, window: NSWindow, viewController: NSViewController, engine: Engine, logger: Logger) {
        self.application = application
        self.window = window
        self.viewController = viewController
        self.engine = engine
        self.logger = logger
    }
    
    public func start() {
        logger.debug("\(#function)")
        window.makeKeyAndOrderFront(nil)
        application.run()
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
        engine.start()
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
    }
    
    public func windowDidBecomeKey(_ notification: Notification) {
        logger.debug("\(#function)")
        window.makeFirstResponder(viewController)
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
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    public func draw(in view: MTKView) {
        engine.renderFrame()
    }
}
