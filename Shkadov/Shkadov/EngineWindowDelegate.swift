//
//  EngineWindowDelegate.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/16/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import AppKit

public class EngineWindowDelegate: NSObject, NSWindowDelegate {
    private var initializing = true
    private var terminating = false
    
    // TODO: Check to see if there are other useful methods to override
    public func windowDidBecomeKey(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        
        if initializing {
            initializing = false
            EngineMain()
        }
    }
    
    public func windowDidResignKey(notification: NSNotification) {
        NSLog("%@", __FUNCTION__)
        if terminating {
            terminating = false
//            EngineShutdown()
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
