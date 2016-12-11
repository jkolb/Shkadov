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
import Swiftish

typealias NSEventButtonNumberType = Int
typealias NSEventKeyCodeType = UInt16

public class macOSInputView : NSView, macOSMouseCursorListener {
    private let logger: Logger
    internal weak var listener: RawInputListener?
    private var followsMouse = true
    private var ignoreFirstDelta = false
    private var currentDownModifierKeyCodes = Set<NSEventKeyCodeType>()
    private var startingEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])
    private var currentDownEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])
    
    public init(frame: CGRect, logger: Logger) {
        self.logger = logger
        super.init(frame: frame)
        
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
    
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func keyDown(with theEvent: NSEvent) {
        logger.debug("KEY DOWN: \(theEvent)")
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
    
    private func transformMouseButtonNumber(_ buttonNumber: NSEventButtonNumberType) -> RawInputButtonCode {
        return mouseButtonMap[buttonNumber] ?? .unknown
    }
    
    private func transformKeyCode(_ keyCode: NSEventKeyCodeType) -> RawInputKeyCode {
        return keyMap[keyCode] ?? .unknown
    }
    
    private func postButtonDownEvent(_ event: NSEvent) {
        let rawButtonCode = transformMouseButtonNumber(event.buttonNumber)
        if rawButtonCode == .unknown { return }
        let contentPoint = convert(event.locationInWindow, from: nil)
        let position = Vector2<Float>(Float(contentPoint.x), Float(contentPoint.y))
        listener?.received(input: .mouseButtonDown(rawButtonCode, position))
    }
    
    private func postButtonUpEvent(_ event: NSEvent) {
        let rawButtonCode = transformMouseButtonNumber(event.buttonNumber)
        if rawButtonCode == .unknown { return }
        let contentPoint = convert(event.locationInWindow, from: nil)
        let position = Vector2<Float>(Float(contentPoint.x), Float(contentPoint.y))
        listener?.received(input: .mouseButtonUp(rawButtonCode, position))
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
        listener?.received(input: .keyDown(rawKeyCode))
    }
    
    private func postKeyUpCode(_ keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .unknown { return }
        listener?.received(input: .keyUp(rawKeyCode))
    }
    
    private func postMousePositionEvent(_ event: NSEvent) {
        if followsMouse {
            let contentPoint = convert(event.locationInWindow, from: nil)
            let position = Vector2<Float>(Float(contentPoint.x), Float(contentPoint.y))
            listener?.received(input: .mousePosition(position))
        }
        else {
            if ignoreFirstDelta {
                // After warping the cursor the first mouse movement triggers a large delta from the mouse's original position
                ignoreFirstDelta = false
                return
            }
            
            let delta = Vector2<Float>(Float(event.deltaX), Float(event.deltaY))
            listener?.received(input: .mouseDelta(delta))
        }
    }
    
    private let mouseButtonMap: [NSEventButtonNumberType : RawInputButtonCode] = [
        0: .button0,
        1: .button1,
        2: .button2,
        3: .button3,
        4: .button4,
        5: .button5,
        6: .button6,
        7: .button7,
        8: .button8,
        9: .button9,
        10: .button10,
        11: .button11,
        12: .button12,
        13: .button13,
        14: .button14,
        15: .button15,
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
        10: .unknown, // ISO_Section
        11: .b,
        12: .q,
        13: .w,
        14: .e,
        15: .r,
        16: .y,
        17: .t,
        18: .one,
        19: .two,
        20: .three,
        21: .four,
        22: .six,
        23: .five,
        24: .equals, // equal
        25: .nine,
        26: .seven,
        27: .minus,
        28: .eight,
        29: .zero,
        30: .rbracket,
        31: .o,
        32: .u,
        33: .lbracket,
        34: .i,
        35: .p,
        36: .return,
        37: .l,
        38: .j,
        39: .apostrophe, // quote
        40: .k,
        41: .semicolon,
        42: .backslash,
        43: .comma,
        44: .slash,
        45: .n,
        46: .m,
        47: .period,
        48: .tab,
        49: .space,
        50: .grave,
        51: .backspace, // Delete
        52: .unknown,
        53: .escape,
        54: .rmeta, // Command
        55: .lmeta, // Command
        56: .lshift,
        57: .capslock,
        58: .lalt, // Option
        59: .lcontrol,
        60: .rshift,
        61: .ralt, // Option
        62: .rcontrol,
        63: .insert, // Function
        64: .f17,
        65: .numpad_DECIMAL,
        // 66 none?
        67: .numpad_MULTIPLY,
        // 68 none?
        69: .numpad_ADD, // Plus
        71: .numlock, // Clear
        72: .unknown, // Volume Up
        73: .unknown, // Volumn Down
        74: .unknown, // Mute
        75: .numpad_DIVIDE,
        76: .numpad_ENTER,
        // 77 none?
        78: .numpad_SUBTRACT, // Minus
        79: .f18,
        80: .f19,
        81: .numpad_EQUALS,
        82: .numpad_ZERO,
        83: .numpad_ONE,
        84: .numpad_TWO,
        85: .numpad_THREE,
        86: .numpad_FOUR,
        87: .numpad_FIVE,
        88: .numpad_SIX,
        89: .numpad_SEVEN,
        90: .f20,
        91: .numpad_EIGHT,
        92: .numpad_NINE,
        93: .unknown, // JIS_Yen
        94: .unknown, // JIS_Underscore
        95: .unknown, // JIS_KeyPadComma
        96: .f5,
        97: .f6,
        98: .f7,
        99: .f3,
        100: .f8,
        101: .f9,
        102: .unknown, // JIS_Eisu
        103: .f11,
        104: .unknown, // JIS_Kana
        105: .f13,
        106: .f16,
        107: .f14,
        // 108 none?
        109: .f10,
        // 110 none?
        111: .f12,
        // 112 none?
        113: .f15,
        114: .unknown, // Help
        115: .home,
        116: .pageup,
        117: .delete, // Forward Delete
        118: .f4,
        119: .end,
        120: .f2,
        121: .pagedown,
        122: .f1,
        123: .left,
        124: .right,
        125: .down,
        126: .up,
        ]
}
