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

typealias NSEventButtonNumberType = Int
typealias NSEventKeyCodeType = UInt16

public class ContentView : NSView {
    public var sendMouseDelta = false {
        didSet {
            ignoreFirstDelta = true
        }
    }
    private var ignoreFirstDelta = false
    private var currentDownModifierKeyCodes = Set<NSEventKeyCodeType>()
    private var startingEventModifierFlags = NSEvent.modifierFlags().intersect([.DeviceIndependentModifierFlagsMask])
    private var currentDownEventModifierFlags = NSEvent.modifierFlags().intersect([.DeviceIndependentModifierFlagsMask])
    public weak var engine: Engine!
    private let buttonMap: [NSEventButtonNumberType : RawInputButtonCode] = [
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
    private let keyMap: [NSEventKeyCodeType : RawInputKeyCode] = [
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
        36: .RETURN,
        48: .TAB,
        49: .SPACE,
        53: .ESCAPE,
        54: .RMETA,
        55: .LMETA,
        56: .LSHIFT,
        57: .CAPSLOCK,
        58: .LALT,
        59: .LCONTROL,
        60: .RSHIFT,
        61: .RALT,
        62: .RCONTROL,
    ]
    
    private func transformButtonNumber(buttonNumber: NSEventButtonNumberType) -> RawInputButtonCode {
        return buttonMap[buttonNumber] ?? .UNKNOWN
    }
    
    private func transformKeyCode(keyCode: NSEventKeyCodeType) -> RawInputKeyCode {
        return keyMap[keyCode] ?? .UNKNOWN
    }

    private func postButtonDownEvent(event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .UNKNOWN { return }
        engine.postInputEventForKind(.ButtonDown(rawButtonCode))
    }
    
    private func postButtonUpEvent(event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .UNKNOWN { return }
        engine.postInputEventForKind(.ButtonUp(rawButtonCode))
    }
    
    private func postKeyDownEvent(event: NSEvent) {
        postKeyDownCode(event.keyCode)
    }
    
    private func postKeyUpEvent(event: NSEvent) {
        postKeyUpCode(event.keyCode)
    }
    
    private func postKeyDownCode(keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .UNKNOWN { return }
        engine.postInputEventForKind(.KeyDown(rawKeyCode))
    }
    
    private func postKeyUpCode(keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .UNKNOWN { return }
        engine.postInputEventForKind(.KeyUp(rawKeyCode))
    }
    
    private func postMousePositionEvent(event: NSEvent) {
        if sendMouseDelta {
            if ignoreFirstDelta {
                // After warping the cursor the first mouse movement triggers a large delta from the mouse's original position
                ignoreFirstDelta = false
                return
            }
            
            let delta = event.delta2D
            engine.postInputEventForKind(.MouseDelta(delta))
        }
        else {
            let contentPoint = convertPoint(event.locationInWindow, fromView: nil)
            let position = contentPoint.point2D
            engine.postInputEventForKind(.MousePosition(position))
        }
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(theEvent: NSEvent) {
//        NSLog("KEY DOWN: \(theEvent)")
        postKeyDownEvent(theEvent)
    }
    
    public override func keyUp(theEvent: NSEvent) {
//        NSLog("KEY UP: \(theEvent)")
        postKeyUpEvent(theEvent)
    }
    
    public override func flagsChanged(theEvent: NSEvent) {
        let previousDownEventModifierFlags = currentDownEventModifierFlags
        currentDownEventModifierFlags = theEvent.modifierFlags.intersect([.DeviceIndependentModifierFlagsMask])
        let transitionedToUpModifierFlags = previousDownEventModifierFlags.subtract(currentDownEventModifierFlags)
        let transitionedToDownModifierFlags = currentDownEventModifierFlags.subtract(previousDownEventModifierFlags)
        let transitionedToUp = !transitionedToUpModifierFlags.isEmpty
        let transitionedToDown = !transitionedToDownModifierFlags.isEmpty
        let keyCode = theEvent.keyCode
        
        if transitionedToUp {
            let upModifierFlagsWereDownOnStart = !startingEventModifierFlags.intersect(transitionedToUpModifierFlags).isEmpty
            
            if upModifierFlagsWereDownOnStart {
                // Do not start handling a modifier until it has been cleared out from startingEventModifierFlags
                startingEventModifierFlags.subtractInPlace(transitionedToUpModifierFlags)
//                NSLog("IGNORE: \(keyCode)")
            }
            else {
                currentDownModifierKeyCodes.remove(keyCode)
                postKeyUpCode(keyCode)
//                NSLog("FLAG UP: \(keyCode)")
            }
        }
        else if transitionedToDown {
            currentDownModifierKeyCodes.insert(keyCode)
            postKeyDownCode(keyCode)
//            NSLog("FLAG DOWN: \(keyCode)")
        }
        else if isAleadyDownKeyCode(keyCode) {
            currentDownModifierKeyCodes.remove(keyCode)
            postKeyUpCode(keyCode)
//            NSLog("FLAG UP 2: \(keyCode)")
        }
        else if modifierFlagWasNotDownOnStart {
            currentDownModifierKeyCodes.insert(keyCode)
            postKeyDownCode(keyCode)
//            NSLog("FLAG DOWN 2: \(keyCode)")
        }
        else {
//            NSLog("IGNORE 2: \(keyCode)")
        }
        //NSLog("FLAGS: \(theEvent)")
    }

    private func isAleadyDownKeyCode(keyCode: NSEventKeyCodeType) -> Bool {
        return currentDownModifierKeyCodes.contains(keyCode)
    }
    
    private var modifierFlagWasNotDownOnStart: Bool {
        return !currentDownEventModifierFlags.subtract(startingEventModifierFlags).isEmpty
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
        return Vector2D(GeometryType(deltaX), GeometryType(deltaY))
    }
}
