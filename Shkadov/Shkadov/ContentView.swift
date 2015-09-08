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

public class ContentView : NSView {
    public var sendMouseDelta = false
    public weak var engine: Engine!
    private let buttonMap: [Int:RawInput.ButtonCode] = [
        0: .MOUSE0,
        1: .MOUSE1,
        2: .MOUSE2,
        3: .MOUSE3,
        4: .MOUSE4,
        5: .MOUSE5,
        6: .MOUSE6,
        7: .MOUSE7,
        8: .MOUSE8,
        9: .MOUSE9,
        10: .MOUSE10,
        11: .MOUSE11,
        12: .MOUSE12,
        13: .MOUSE13,
        14: .MOUSE14,
        15: .MOUSE15,
    ]
    private let keyMap: [Int:RawInput.KeyCode] = [
        0: .A,
        1: .S,
        2: .D,
        3: .F,
        4: .H,
        5: .G,
        6: .Z,
        7: .X,
        8: .C,
        9: .V,
        10: .UNKNOWN,
        11: .B,
        12: .Q,
        13: .W,
        14: .E,
        15: .R,
        16: .Y,
        17: .T,
        
        49: .SPACE,
        56: .LSHIFT,
    ]
    
    private func buttonCodeForEvent(event: NSEvent) -> RawInput.ButtonCode {
        return buttonMap[event.buttonNumber] ?? .UNKNOWN
    }
    
    private func keyCodeForEvent(event: NSEvent) -> RawInput.KeyCode {
        return keyMap[Int(event.keyCode)] ?? .UNKNOWN
    }

    private func postButtonDownEvent(event: NSEvent) {
        engine.postDownEventForButtonCode(buttonCodeForEvent(event))
    }
    
    private func postButtonUpEvent(event: NSEvent) {
        engine.postUpEventForButtonCode(buttonCodeForEvent(event))
    }
    
    private func postKeyDownEvent(event: NSEvent) {
        engine.postDownEventForKeyCode(keyCodeForEvent(event))
    }
    
    private func postKeyUpEvent(event: NSEvent) {
        engine.postUpEventForKeyCode(keyCodeForEvent(event))
    }
    
    private func postMousePositionEvent(event: NSEvent) {
        if sendMouseDelta {
            let delta = event.delta2D
            engine.postMouseDeltaEvent(delta)
        }
        else {
            let position = event.locationInWindow.point2D
            engine.postMousePositionEvent(position)
        }
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(theEvent: NSEvent) {
        NSLog("KEY DOWN: \(theEvent)")
        postKeyDownEvent(theEvent)
    }
    
    public override func keyUp(theEvent: NSEvent) {
        NSLog("KEY UP: \(theEvent)")
        postKeyUpEvent(theEvent)
    }
    
    public override func flagsChanged(theEvent: NSEvent) {
        NSLog("FLAGS: \(theEvent)")
    }

    public override func mouseDown(theEvent: NSEvent) {
        postButtonDownEvent(theEvent)
    }
    
    public override func otherMouseDown(theEvent: NSEvent) {
        postButtonDownEvent(theEvent)
    }
    
    public override func rightMouseDown(theEvent: NSEvent) {
        postButtonDownEvent(theEvent)
    }
    
    public override func mouseUp(theEvent: NSEvent) {
        postButtonUpEvent(theEvent)
    }
    
    public override func otherMouseUp(theEvent: NSEvent) {
        postButtonUpEvent(theEvent)
    }
    
    public override func rightMouseUp(theEvent: NSEvent) {
        postButtonUpEvent(theEvent)
    }
    
    public override func mouseDragged(theEvent: NSEvent) {
        postMousePositionEvent(theEvent)
    }
    
    public override func otherMouseDragged(theEvent: NSEvent) {
        postMousePositionEvent(theEvent)
    }
    
    public override func rightMouseDragged(theEvent: NSEvent) {
        postMousePositionEvent(theEvent)
    }
    
    public override func mouseMoved(theEvent: NSEvent) {
//        NSLog("MOVED: (\(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func scrollWheel(theEvent: NSEvent) {
//        if theEvent.momentumPhase.contains(NSEventPhase.Changed) || theEvent.momentumPhase.contains(NSEventPhase.Ended) {
//            return
//        }
        NSLog("SCROLL: (\(theEvent)")
    }
}

public extension NSEvent {
    public var delta2D: Vector2D {
        return Vector2D(dx: GeometryType(deltaX), dy: GeometryType(deltaY))
    }
}
