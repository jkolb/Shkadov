//
//  EngineApplicationDelegate.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/16/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import AppKit

public class EngineApplicationDelegate: NSObject, NSApplicationDelegate {
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
