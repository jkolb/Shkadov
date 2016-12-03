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
import MetalKit
import Swiftish

typealias NSEventButtonNumberType = Int
typealias NSEventKeyCodeType = UInt16

public class macOSMetalView : MTKView, macOSMouseCursorListener {
    private let logger: Logger
    public weak var rendererListener: RendererListener?
    public weak var rawInputListener: RawInputListener?
    private var followsMouse = false
    private var ignoreFirstDelta = false
    private var currentDownModifierKeyCodes = Set<NSEventKeyCodeType>()
    private var startingEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])
    private var currentDownEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])
    
    public init(frame: CGRect, device: MTLDevice, logger: Logger) {
        self.logger = logger
        super.init(frame: frame, device: device)
        
        let options: NSTrackingAreaOptions = [
            NSTrackingAreaOptions.mouseEnteredAndExited,
            NSTrackingAreaOptions.mouseMoved,
            NSTrackingAreaOptions.inVisibleRect,
            NSTrackingAreaOptions.activeInKeyWindow
        ]
        let trackingArea = NSTrackingArea(rect: CGRect.zero, options: options, owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

    public required init(coder: NSCoder) {
        fatalError()
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        rendererListener?.processFrame()
    }
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(with theEvent: NSEvent) {
        logger.trace("KEY DOWN: \(theEvent)")
        postKeyDownEvent(theEvent)
    }
    
    public override func keyUp(with theEvent: NSEvent) {
        logger.trace("KEY UP: \(theEvent)")
        postKeyUpEvent(theEvent)
    }
    
    public override func flagsChanged(with theEvent: NSEvent) {
        let previousDownEventModifierFlags = currentDownEventModifierFlags
        currentDownEventModifierFlags = theEvent.modifierFlags.intersection([.deviceIndependentFlagsMask])
        let transitionedToUpModifierFlags = previousDownEventModifierFlags.subtracting(currentDownEventModifierFlags)
        let transitionedToDownModifierFlags = currentDownEventModifierFlags.subtracting(previousDownEventModifierFlags)
        let transitionedToUp = !transitionedToUpModifierFlags.isEmpty
        let transitionedToDown = !transitionedToDownModifierFlags.isEmpty
        let keyCode = theEvent.keyCode
        
        if transitionedToUp {
            let upModifierFlagsWereDownOnStart = !startingEventModifierFlags.intersection(transitionedToUpModifierFlags).isEmpty
            
            if upModifierFlagsWereDownOnStart {
                // Do not start handling a modifier until it has been cleared out from startingEventModifierFlags
                startingEventModifierFlags.subtract(transitionedToUpModifierFlags)
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
    
    public override func mouseDown(with theEvent: NSEvent) {
        logger.trace("MOUSE DOWN: \(theEvent)")
        postButtonDownEvent(theEvent)
    }
    
    public override func otherMouseDown(with theEvent: NSEvent) {
        logger.trace("OTHER MOUSE DOWN: \(theEvent)")
        postButtonDownEvent(theEvent)
    }
    
    public override func rightMouseDown(with theEvent: NSEvent) {
        logger.trace("RIGHT MOUSE DOWN: \(theEvent)")
        postButtonDownEvent(theEvent)
    }
    
    public override func mouseUp(with theEvent: NSEvent) {
        logger.trace("MOUSE UP: \(theEvent)")
        postButtonUpEvent(theEvent)
    }
    
    public override func otherMouseUp(with theEvent: NSEvent) {
        logger.trace("OTHER MOUSE UP: \(theEvent)")
        postButtonUpEvent(theEvent)
    }
    
    public override func rightMouseUp(with theEvent: NSEvent) {
        logger.trace("RIGHT MOUSE UP: \(theEvent)")
        postButtonUpEvent(theEvent)
    }
    
    public override func mouseDragged(with theEvent: NSEvent) {
        logger.trace("MOUSE DRAGGED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func otherMouseDragged(with theEvent: NSEvent) {
        logger.trace("OTHER MOUSE DRAGGED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func rightMouseDragged(with theEvent: NSEvent) {
        logger.trace("RIGHT MOUSE DRAGGED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func mouseMoved(with theEvent: NSEvent) {
        logger.trace("MOUSE MOVED: \(theEvent)")
        postMousePositionEvent(theEvent)
    }
    
    public override func scrollWheel(with theEvent: NSEvent) {
        logger.trace("SCROLL WHEEL: \(theEvent)")
    }
    
    public func updated(followsMouse: Bool) {
        self.followsMouse = followsMouse
        ignoreFirstDelta = !followsMouse
    }
    
    // MARK: - Private
    
    private func isAleadyDownKeyCode(_ keyCode: NSEventKeyCodeType) -> Bool {
        return currentDownModifierKeyCodes.contains(keyCode)
    }
    
    private var modifierFlagWasNotDownOnStart: Bool {
        return !currentDownEventModifierFlags.subtracting(startingEventModifierFlags).isEmpty
    }
    
    private func transformButtonNumber(_ buttonNumber: NSEventButtonNumberType) -> RawInputButtonCode {
        return buttonMap[buttonNumber] ?? .unknown
    }
    
    private func transformKeyCode(_ keyCode: NSEventKeyCodeType) -> RawInputKeyCode {
        return keyMap[keyCode] ?? .unknown
    }
    
    private func postButtonDownEvent(_ event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .unknown { return }
        rawInputListener?.received(input: .buttonDown(rawButtonCode))
    }
    
    private func postButtonUpEvent(_ event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .unknown { return }
        rawInputListener?.received(input: .buttonUp(rawButtonCode))
    }
    
    private func postKeyDownEvent(_ event: NSEvent) {
        postKeyDownCode(event.keyCode)
    }
    
    private func postKeyUpEvent(_ event: NSEvent) {
        postKeyUpCode(event.keyCode)
    }
    
    private func postKeyDownCode(_ keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .unknown { return }
        rawInputListener?.received(input: .keyDown(rawKeyCode))
    }
    
    private func postKeyUpCode(_ keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .unknown { return }
        rawInputListener?.received(input: .keyUp(rawKeyCode))
    }
    
    private func postMousePositionEvent(_ event: NSEvent) {
        if followsMouse {
            let contentPoint = convert(event.locationInWindow, from: nil)
            let position = Vector2<Float>(Float(contentPoint.x), Float(contentPoint.y))
            rawInputListener?.received(input: .mousePosition(position))
        }
        else {
            if ignoreFirstDelta {
                // After warping the cursor the first mouse movement triggers a large delta from the mouse's original position
                ignoreFirstDelta = false
                return
            }
            
            let delta = Vector2<Float>(Float(event.deltaX), Float(event.deltaY))
            rawInputListener?.received(input: .mouseDelta(delta))
        }
    }
    
    private let buttonMap: [NSEventButtonNumberType : RawInputButtonCode] = [
        0: .mouse0,
        1: .mouse1,
        2: .mouse2,
        3: .mouse3,
        4: .mouse4,
        5: .mouse5,
        6: .mouse6,
        7: .mouse7,
        8: .mouse8,
        9: .mouse9,
        10: .mouse10,
        11: .mouse11,
        12: .mouse12,
        13: .mouse13,
        14: .mouse14,
        15: .mouse15,
        ]
    private let keyMap: [NSEventKeyCodeType : RawInputKeyCode] = [
        0: .a,
        1: .s,
        2: .d,
        3: .f,
        4: .h,
        5: .g,
        6: .z,
        7: .x,
        8: .c,
        9: .v,
        10: .unknown,
        11: .b,
        12: .q,
        13: .w,
        14: .e,
        15: .r,
        16: .y,
        17: .t,
        36: .return,
        46: .m,
        48: .tab,
        49: .space,
        53: .escape,
        54: .rmeta,
        55: .lmeta,
        56: .lshift,
        57: .capslock,
        58: .lalt,
        59: .lcontrol,
        60: .rshift,
        61: .ralt,
        62: .rcontrol,
        ]
}
