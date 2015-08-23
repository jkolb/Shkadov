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
import simd

public class ContentView: NSView {
    public weak var engine: Engine!
    public let buttonMap: [Int:Input.ButtonCode] = [
        0: .MOUSE0,
    ]
    public let keyMap: [Int:Input.KeyCode] = [
        0: .A,
    ]
    
    private func keyEvent(event: NSEvent, down: Bool) {
        NSLog("KEY: \(event)")
        
//        if let keyCode = keyMap[Int(event.keyCode)] {
//            engine.updateKeyCode(keyCode, down: down)
//        }
    }
    
    private func mouseEvent(event: NSEvent, down: Bool) {
        NSLog("MOUSE: \(event)")
        
//        if let keyCode = buttonMap[event.buttonNumber] {
//            engine.updateKeyCode(keyCode, down: down)
//        }
    }
    
    private func positionEvent(event: NSEvent) {
        NSLog("POSITION: \(event)")
        
        // NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
//        let location = event.locationInWindow
//        let position = double2(Double(location.x), Double(location.y))
//        engine.updateMousePosition(position)
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(theEvent: NSEvent) {
        keyEvent(theEvent, down: true)
    }
    
    public override func keyUp(theEvent: NSEvent) {
        keyEvent(theEvent, down: false)
    }
    
    public override func flagsChanged(theEvent: NSEvent) {
        NSLog("NSFlagsChanged \(theEvent)")
    }

    public override func mouseDown(theEvent: NSEvent) {
        mouseEvent(theEvent, down: true)
    }
    
    public override func otherMouseDown(theEvent: NSEvent) {
        mouseEvent(theEvent, down: true)
    }
    
    public override func rightMouseDown(theEvent: NSEvent) {
        mouseEvent(theEvent, down: true)
    }
    
    public override func mouseUp(theEvent: NSEvent) {
        mouseEvent(theEvent, down: false)
    }
    
    public override func otherMouseUp(theEvent: NSEvent) {
        mouseEvent(theEvent, down: false)
    }
    
    public override func rightMouseUp(theEvent: NSEvent) {
        mouseEvent(theEvent, down: false)
    }
    
    public override func mouseDragged(theEvent: NSEvent) {
        positionEvent(theEvent)
    }
    
    public override func otherMouseDragged(theEvent: NSEvent) {
        positionEvent(theEvent)
    }
    
    public override func rightMouseDragged(theEvent: NSEvent) {
        positionEvent(theEvent)
    }
    
    public override func mouseMoved(theEvent: NSEvent) {
        positionEvent(theEvent)
    }
    
    public override func scrollWheel(theEvent: NSEvent) {
//        if theEvent.momentumPhase.contains(NSEventPhase.Changed) || theEvent.momentumPhase.contains(NSEventPhase.Ended) {
//            return
//        }
        NSLog("SCROLL: (\(theEvent)")
    }
}
