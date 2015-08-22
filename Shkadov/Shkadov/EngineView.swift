//
//  EngineView.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/16/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import AppKit

public class EngineView: NSView {
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func mouseDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func mouseUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func mouseDragged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func rightMouseDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func rightMouseUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func rightMouseDragged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }

    public override func otherMouseDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func otherMouseUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func otherMouseDragged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func mouseMoved(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func scrollWheel(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func keyDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func keyUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func flagsChanged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
}
