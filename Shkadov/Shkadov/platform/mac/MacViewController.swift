/*
The MIT License (MIT)

Copyright (c) 2016 Justin Kolb

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

public final class MacViewController : NSViewController, MacMouseCursorManagerDelegate {
    private let mouseCursorManager: MouseCursorManager
    private let renderView: NSView
    private let logger: Logger
    public weak var rawInputListener: RawInputListener!
    private var ignoreFirstDelta = false
    private var currentDownModifierKeyCodes = Set<NSEventKeyCodeType>()
    private var startingEventModifierFlags = NSEvent.modifierFlags().intersect([.DeviceIndependentModifierFlagsMask])
    private var currentDownEventModifierFlags = NSEvent.modifierFlags().intersect([.DeviceIndependentModifierFlagsMask])

    public init(mouseCursorManager: MouseCursorManager, renderView: NSView, logger: Logger) {
        self.mouseCursorManager = mouseCursorManager
        self.renderView = renderView
        self.logger = logger
        super.init(nibName: nil, bundle: nil)!
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func loadView() {
        view = renderView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let options: NSTrackingAreaOptions = [
            NSTrackingAreaOptions.MouseEnteredAndExited,
            NSTrackingAreaOptions.MouseMoved,
            NSTrackingAreaOptions.InVisibleRect,
            NSTrackingAreaOptions.ActiveInKeyWindow
        ]
        let trackingArea = NSTrackingArea(rect: CGRect.zero, options: options, owner: view, userInfo: nil)
        view.addTrackingArea(trackingArea)
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(theEvent: NSEvent) {
        logger.trace("KEY DOWN: \(theEvent)")
        postKeyDownEvent(theEvent)
    }
    
    public override func keyUp(theEvent: NSEvent) {
        logger.trace("KEY UP: \(theEvent)")
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
                logger.trace("IGNORE: \(keyCode)")
            }
            else {
                currentDownModifierKeyCodes.remove(keyCode)
                postKeyUpCode(keyCode)
                logger.trace("FLAG UP: \(keyCode)")
            }
        }
        else if transitionedToDown {
            currentDownModifierKeyCodes.insert(keyCode)
            postKeyDownCode(keyCode)
            logger.trace("FLAG DOWN: \(keyCode)")
        }
        else if isAleadyDownKeyCode(keyCode) {
            currentDownModifierKeyCodes.remove(keyCode)
            postKeyUpCode(keyCode)
            logger.trace("FLAG UP 2: \(keyCode)")
        }
        else if modifierFlagWasNotDownOnStart {
            currentDownModifierKeyCodes.insert(keyCode)
            postKeyDownCode(keyCode)
            logger.trace("FLAG DOWN 2: \(keyCode)")
        }
        else {
            logger.trace("IGNORE 2: \(keyCode)")
        }
        logger.trace("FLAGS: \(theEvent)")
    }
    
    public override func mouseDown(theEvent: NSEvent) {
        logger.trace("MOUSE DOWN: \(theEvent)")
        postButtonDownEvent(theEvent)
    }
    
    public override func otherMouseDown(theEvent: NSEvent) {
        logger.trace("OTHER MOUSE DOWN: \(theEvent)")
        postButtonDownEvent(theEvent)
    }
    
    public override func rightMouseDown(theEvent: NSEvent) {
        logger.trace("RIGHT MOUSE DOWN: \(theEvent)")
        postButtonDownEvent(theEvent)
    }
    
    public override func mouseUp(theEvent: NSEvent) {
        logger.trace("MOUSE UP: \(theEvent)")
        postButtonUpEvent(theEvent)
    }
    
    public override func otherMouseUp(theEvent: NSEvent) {
        logger.trace("OTHER MOUSE UP: \(theEvent)")
        postButtonUpEvent(theEvent)
    }
    
    public override func rightMouseUp(theEvent: NSEvent) {
        logger.trace("RIGHT MOUSE UP: \(theEvent)")
        postButtonUpEvent(theEvent)
    }
    
    public override func mouseDragged(theEvent: NSEvent) {
        logger.trace("MOUSE DRAGGED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func otherMouseDragged(theEvent: NSEvent) {
        logger.trace("OTHER MOUSE DRAGGED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func rightMouseDragged(theEvent: NSEvent) {
        logger.trace("RIGHT MOUSE DRAGGED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func mouseMoved(theEvent: NSEvent) {
        logger.trace("MOUSE MOVED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func scrollWheel(theEvent: NSEvent) {
        logger.trace("SCROLL WHEEL: \(theEvent)")
    }
    
    // MARK: - MacMouseCursorManagerDelegate
    
    public func macMouseCursorManager(macMouseCursorManager: MacMouseCursorManager, updatedFollowsMouse followsMouse: Bool) {
        ignoreFirstDelta = !followsMouse
    }

    // MARK: - Private
    
    private func isAleadyDownKeyCode(keyCode: NSEventKeyCodeType) -> Bool {
        return currentDownModifierKeyCodes.contains(keyCode)
    }
    
    private var modifierFlagWasNotDownOnStart: Bool {
        return !currentDownEventModifierFlags.subtract(startingEventModifierFlags).isEmpty
    }

    private func transformButtonNumber(buttonNumber: NSEventButtonNumberType) -> RawInputButtonCode {
        return buttonMap[buttonNumber] ?? .UNKNOWN
    }
    
    private func transformKeyCode(keyCode: NSEventKeyCodeType) -> RawInputKeyCode {
        return keyMap[keyCode] ?? .UNKNOWN
    }
    
    private func postButtonDownEvent(event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .UNKNOWN { return }
        rawInputListener.receivedRawInput(.ButtonDown(rawButtonCode))
    }
    
    private func postButtonUpEvent(event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .UNKNOWN { return }
        rawInputListener.receivedRawInput(.ButtonUp(rawButtonCode))
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
        rawInputListener.receivedRawInput(.KeyDown(rawKeyCode))
    }
    
    private func postKeyUpCode(keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .UNKNOWN { return }
        rawInputListener.receivedRawInput(.KeyUp(rawKeyCode))
    }
    
    private func postMousePositionEvent(event: NSEvent) {
        if mouseCursorManager.followsMouse {
            let contentPoint = view.convertPoint(event.locationInWindow, fromView: nil)
            let position = Vector2D(Float(contentPoint.x), Float(contentPoint.y))
            rawInputListener.receivedRawInput(.MousePosition(position))
        }
        else {
            if ignoreFirstDelta {
                // After warping the cursor the first mouse movement triggers a large delta from the mouse's original position
                ignoreFirstDelta = false
                return
            }
            
            let delta = Vector2D(Float(event.deltaX), Float(event.deltaY))
            rawInputListener.receivedRawInput(.MouseDelta(delta))
        }
    }

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
        46: .M,
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
}
