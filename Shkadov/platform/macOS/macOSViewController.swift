//
//  macOSViewController.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

import AppKit
import Swiftish

public enum RawInputButtonCode : UInt8 {
    case invalid = 0
    
    case mouse0  = 1
    case mouse1  = 2
    case mouse2  = 3
    case mouse3  = 4
    case mouse4  = 5
    case mouse5  = 6
    case mouse6  = 7
    case mouse7  = 8
    case mouse8  = 9
    case mouse9  = 10
    case mouse10 = 11
    case mouse11 = 12
    case mouse12 = 13
    case mouse13 = 14
    case mouse14 = 15
    case mouse15 = 16
    
    case unknown = 255
}

public enum RawInputKeyCode : UInt8 {
    case invalid = 0
    
    case a = 1
    case b = 2
    case c = 3
    case d = 4
    case e = 5
    case f = 6
    case g = 7
    case h = 8
    case i = 9
    case j = 10
    case k = 11
    case l = 12
    case m = 13
    case n = 14
    case o = 15
    case p = 16
    case q = 17
    case r = 18
    case s = 19
    case t = 20
    case u = 21
    case v = 22
    case w = 23
    case x = 24
    case y = 25
    case z = 26
    // 27 - 49
    case zero  = 50
    case one   = 51
    case two   = 52
    case three = 53
    case four  = 54
    case five  = 55
    case six   = 56
    case seven = 57
    case eight = 58
    case nine  = 59
    // 60 - 69
    case grave = 70
    case minus = 71
    case equals = 72
    case lbracket = 73
    case rbracket = 74
    case backslash = 75
    case semicolon = 76
    case apostrophe = 77
    case comma = 78
    case period = 79
    case slash = 80
    case tab = 83
    case space = 84
    // 85 - 99
    case capslock  = 100 // Toggle only
    case `return`    = 101
    case lshift    = 102
    case rshift    = 103
    case lcontrol  = 104
    case rcontrol  = 105
    case lalt      = 106
    case ralt      = 107
    case lmeta     = 108
    case rmeta     = 109
    case insert    = 110 // fn
    case delete    = 111
    case home      = 112
    case end       = 113
    case pageup    = 114
    case pagedown  = 115
    case escape    = 116
    case backspace = 117 // DELETE
    case sysrq     = 118 // Windows
    case scroll    = 119 // Windows
    case pause     = 120 // Windows
    // 121 - 159
    case up    = 160
    case down  = 161
    case left  = 162
    case right = 163
    // 164 - 169
    case numlock         = 170 // CLEAR
    case numpad_ZERO     = 171
    case numpad_ONE      = 172
    case numpad_TWO      = 173
    case numpad_THREE    = 174
    case numpad_FOUR     = 175
    case numpad_FIVE     = 176
    case numpad_SIX      = 177
    case numpad_SEVEN    = 178
    case numpad_EIGHT    = 179
    case numpad_NINE     = 180
    case numpad_EQUALS   = 181
    case numpad_DIVIDE   = 182
    case numpad_MULTIPLY = 183
    case numpad_SUBTRACT = 184
    case numpad_ADD      = 185
    case numpad_DECIMAL  = 186
    case numpad_ENTER    = 187
    // 188 - 189
    case f1  = 190
    case f2  = 191
    case f3  = 192
    case f4  = 193
    case f5  = 194
    case f6  = 195
    case f7  = 196
    case f8  = 197
    case f9  = 198
    case f10 = 199
    case f11 = 200
    case f12 = 201
    case f13 = 202
    case f14 = 203
    case f15 = 204
    case f16 = 205
    case f17 = 206
    case f18 = 207
    case f19 = 208
    case f20 = 209
    // 210 - 254
    case unknown = 255
}

public enum RawInput {
    case buttonDown(RawInputButtonCode)
    case buttonUp(RawInputButtonCode)
    case joystickAxis(Vector2<Float>)
    case keyDown(RawInputKeyCode)
    case keyUp(RawInputKeyCode)
    case mousePosition(Vector2<Float>)
    case mouseDelta(Vector2<Float>)
    case scrollDelta(Vector2<Float>)
}

public protocol RawInputListener : class {
    func receivedRawInput(_ rawInput: RawInput)
}

typealias NSEventButtonNumberType = Int
typealias NSEventKeyCodeType = UInt16

public final class macOSViewController : NSViewController, macOSMouseCursorManagerDelegate {
    fileprivate let mouseCursorManager: MouseCursorManager
    fileprivate let renderView: NSView
    fileprivate let logger: Logger
    public weak var rawInputListener: RawInputListener!
    fileprivate var ignoreFirstDelta = false
    fileprivate var currentDownModifierKeyCodes = Set<NSEventKeyCodeType>()
    fileprivate var startingEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])
    fileprivate var currentDownEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])
    
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
            NSTrackingAreaOptions.mouseEnteredAndExited,
            NSTrackingAreaOptions.mouseMoved,
            NSTrackingAreaOptions.inVisibleRect,
            NSTrackingAreaOptions.activeInKeyWindow
        ]
        let trackingArea = NSTrackingArea(rect: CGRect.zero, options: options, owner: view, userInfo: nil)
        view.addTrackingArea(trackingArea)
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
    
    // MARK: - macOSMouseCursorManagerDelegate
    
    public func macOSMouseCursorManager(_ macOSMouseCursorManager: macOSMouseCursorManager, updatedFollowsMouse followsMouse: Bool) {
        ignoreFirstDelta = !followsMouse
    }
    
    // MARK: - Private
    
    fileprivate func isAleadyDownKeyCode(_ keyCode: NSEventKeyCodeType) -> Bool {
        return currentDownModifierKeyCodes.contains(keyCode)
    }
    
    fileprivate var modifierFlagWasNotDownOnStart: Bool {
        return !currentDownEventModifierFlags.subtracting(startingEventModifierFlags).isEmpty
    }
    
    fileprivate func transformButtonNumber(_ buttonNumber: NSEventButtonNumberType) -> RawInputButtonCode {
        return buttonMap[buttonNumber] ?? .unknown
    }
    
    fileprivate func transformKeyCode(_ keyCode: NSEventKeyCodeType) -> RawInputKeyCode {
        return keyMap[keyCode] ?? .unknown
    }
    
    fileprivate func postButtonDownEvent(_ event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .unknown { return }
        rawInputListener.receivedRawInput(.buttonDown(rawButtonCode))
    }
    
    fileprivate func postButtonUpEvent(_ event: NSEvent) {
        let rawButtonCode = transformButtonNumber(event.buttonNumber)
        if rawButtonCode == .unknown { return }
        rawInputListener.receivedRawInput(.buttonUp(rawButtonCode))
    }
    
    fileprivate func postKeyDownEvent(_ event: NSEvent) {
        postKeyDownCode(event.keyCode)
    }
    
    fileprivate func postKeyUpEvent(_ event: NSEvent) {
        postKeyUpCode(event.keyCode)
    }
    
    fileprivate func postKeyDownCode(_ keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .unknown { return }
        rawInputListener.receivedRawInput(.keyDown(rawKeyCode))
    }
    
    fileprivate func postKeyUpCode(_ keyCode: NSEventKeyCodeType) {
        let rawKeyCode = transformKeyCode(keyCode)
        if rawKeyCode == .unknown { return }
        rawInputListener.receivedRawInput(.keyUp(rawKeyCode))
    }
    
    fileprivate func postMousePositionEvent(_ event: NSEvent) {
        if mouseCursorManager.followsMouse {
            let contentPoint = view.convert(event.locationInWindow, from: nil)
            let position = Vector2<Float>(Float(contentPoint.x), Float(contentPoint.y))
            rawInputListener.receivedRawInput(.mousePosition(position))
        }
        else {
            if ignoreFirstDelta {
                // After warping the cursor the first mouse movement triggers a large delta from the mouse's original position
                ignoreFirstDelta = false
                return
            }
            
            let delta = Vector2<Float>(Float(event.deltaX), Float(event.deltaY))
            rawInputListener.receivedRawInput(.mouseDelta(delta))
        }
    }
    
    fileprivate let buttonMap: [NSEventButtonNumberType : RawInputButtonCode] = [
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
    fileprivate let keyMap: [NSEventKeyCodeType : RawInputKeyCode] = [
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
