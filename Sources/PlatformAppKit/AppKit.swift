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
import CoreGraphics
import Platform
import Logger
import Swiftish
import PlatformMachO
import Utility

typealias NSEventButtonNumberType = Int
typealias NSEventKeyCodeType = UInt16

public final class AppKit : NSObject, Platform, NSApplicationDelegate {
    public weak var listener: PlatformListener?
    private let logger: Logger
    private let timeSource: TimeSource
    private var windows: [NSWindow?]
    private var ignoreFirstMouseDelta = false
    private var currentDownModifierKeyCodes = Set<NSEventKeyCodeType>()
    private var startingEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])
    private var currentDownEventModifierFlags = NSEvent.modifierFlags().intersection([.deviceIndependentFlagsMask])

    public init(loggerFactory: LoggerFactory) {
        self.cursorHidden = false
        self.cursorFollowsMouse = true
        self.logger = loggerFactory.makeLogger()
        self.timeSource = MachOTimeSource()
        self.windows = []
    }

    public var cursorHidden: Bool {
        didSet {
            if cursorHidden {
                CGDisplayHideCursor(CGMainDisplayID())
            }
            else {
                CGDisplayShowCursor(CGMainDisplayID())
            }
        }
    }
    public var cursorFollowsMouse: Bool {
        didSet {
            if cursorFollowsMouse {
                CGAssociateMouseAndMouseCursorPosition(1)
            }
            else {
                CGAssociateMouseAndMouseCursorPosition(0)
            }
            
            ignoreFirstMouseDelta = !cursorFollowsMouse
        }
    }
    
    public func moveCursor(to point: Vector2<Float>) {
        CGWarpMouseCursorPosition(CGPoint(x: CGFloat(point.x), y: CGFloat(point.y)))
    }

    public func startup() {
        let application = NSApplication.shared()
        application.setActivationPolicy(.regular)
        application.mainMenu = makeMainMenu()
        application.delegate = self
        application.run()
    }
    
    private func didStartup() {
        listener?.didStartup()
    }
    
    public var currentTime: Time {
        return timeSource.currentTime
    }

    private func makeMainMenu() -> NSMenu {
        let mainMenu = NSMenu()
        
        let applicationMenuItem = NSMenuItem()
        mainMenu.addItem(applicationMenuItem)
        
        let applicationMenu = NSMenu()
        applicationMenuItem.submenu = applicationMenu
        
        let applicationName = ProcessInfo.processInfo.processName
        applicationMenu.addItem(withTitle: "Quit \(applicationName)", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        return mainMenu
    }
    
    public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        return .terminateNow
    }
    
    public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    public func applicationWillFinishLaunching(_ notification: Notification) {
    }
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        didStartup()
    }

    public var primaryScreen: Screen? {
        guard let screens = NSScreen.screens() else {
            return nil
        }

        if screens.count == 0 {
            return nil
        }

        return AppKitScreen(instance: screens[0])
    }

    public func withScreens<R>(_ body: ([Screen]) throws -> R) throws -> R {
        guard let screens = NSScreen.screens() else {
            return try body([])
        }

        return try body(screens.map({ AppKitScreen(instance: $0) }))
    }

    private func nextWindowHandle() -> WindowHandle {
        return WindowHandle(key: windows.count)
    }

    subscript (handle: WindowHandle) -> NSWindow {
        return windows[handle.index]!
    }

    public func createWindow(region: Region2<Int>, screen: Screen) -> WindowHandle {
        let nativeScreen = screen as! AppKitScreen

        return createWindow(region: region, screen: nativeScreen.instance)
    }

    func createWindow(region: Region2<Int>, screen: NSScreen?) -> WindowHandle {
        let window = AppKitNativeWindow(
            platform: self,
            contentRect: CGRect.makeRect(region),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.collectionBehavior = .fullScreenPrimary
        window.backgroundColor = NSColor.black
        return addWindow(window)
    }

    private func addWindow(_ window: NSWindow) -> WindowHandle {
        let handle = nextWindowHandle()
        windows.insert(window, at: handle.index)
        return handle
    }

    public func borrowWindow(handle: WindowHandle) -> Window {
        return AppKitWindow(handle: handle, instance: self[handle])
    }

    public func destroyWindow(handle: WindowHandle) {
    }

    public func receivedEvent(_ event: NSEvent) -> Bool {
        switch event.type {
            case .flagsChanged:
                flagsChanged(event: event)
                return true
            case .keyDown:
                postKeyDownEvent(event)
                return true
            case .keyUp:
                postKeyUpEvent(event)
                return true
            case .leftMouseDown:
                postButtonDownEvent(event)
                return true
            case .leftMouseDragged:
                postMousePositionEvent(event)
                return true
            case .leftMouseUp:
                postButtonUpEvent(event)
                return true
            case .mouseEntered:
                logger.debug("\(event)")
                return false
            case .mouseExited:
                logger.debug("\(event)")
                return false
            case .mouseMoved:
                postMousePositionEvent(event)
                return true
            case .otherMouseDown:
                postButtonDownEvent(event)
                return true
            case .otherMouseDragged:
                postMousePositionEvent(event)
                return true
            case .otherMouseUp:
                postButtonUpEvent(event)
                return true
            case .rightMouseDown:
                postButtonDownEvent(event)
                return true
            case .rightMouseDragged:
                postMousePositionEvent(event)
                return true
            case .rightMouseUp:
                postButtonUpEvent(event)
                return true
            case .scrollWheel:
                logger.debug("\(event)")
                return false
            default:
                return false
        }
    }

    private func flagsChanged(event: NSEvent) {
        let previousDownEventModifierFlags = currentDownEventModifierFlags
        currentDownEventModifierFlags = event.modifierFlags.intersection([.deviceIndependentFlagsMask])
        let transitionedToUpModifierFlags = previousDownEventModifierFlags.subtracting(currentDownEventModifierFlags)
        let transitionedToDownModifierFlags = currentDownEventModifierFlags.subtracting(previousDownEventModifierFlags)
        let transitionedToUp = !transitionedToUpModifierFlags.isEmpty
        let transitionedToDown = !transitionedToDownModifierFlags.isEmpty
        let keyCode = event.keyCode
        
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
        logger.trace("FLAGS: \(event)")
    }
    
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
        //let contentPoint = convert(event.locationInWindow, from: nil)
        let contentPoint = event.locationInWindow
        let position = Vector2<Float>(Float(contentPoint.x), Float(contentPoint.y))
        listener?.received(input: .mouseButtonDown(rawButtonCode, position))
    }
    
    private func postButtonUpEvent(_ event: NSEvent) {
        let rawButtonCode = transformMouseButtonNumber(event.buttonNumber)
        if rawButtonCode == .unknown { return }
        //let contentPoint = convert(event.locationInWindow, from: nil)
        let contentPoint = event.locationInWindow
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
        if cursorFollowsMouse {
            //let contentPoint = convert(event.locationInWindow, from: nil)
            let contentPoint = event.locationInWindow
            let position = Vector2<Float>(Float(contentPoint.x), Float(contentPoint.y))
            listener?.received(input: .mousePosition(position))
        }
        else {
            if ignoreFirstMouseDelta {
                // After warping the cursor the first mouse movement triggers a large delta from the mouse's original position
                ignoreFirstMouseDelta = false
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
        // 52 none?
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

final class AppKitNativeWindow : NSWindow {
    private unowned(unsafe) let platform: AppKit

    public init(platform: AppKit, contentRect: NSRect, styleMask style: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        self.platform = platform
        super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
    }

    public override func sendEvent(_ event: NSEvent) {
        if !platform.receivedEvent(event) {
            super.sendEvent(event)
        }
    }
}

extension CGPoint {
    public static func makePoint(_ vector: Vector2<Int>) -> CGPoint {
        return CGPoint(x: vector.x, y: vector.y)
    }

    public var vector: Vector2<Int> {
        return Vector2<Int>(Int(x), Int(y))
    }
}

extension CGRect {
    public static func makeRect(_ region: Region2<Int>) -> CGRect {
        return CGRect(origin: CGPoint.makePoint(region.origin), size: CGSize.makeSize(region.size))
    }

    public var region: Region2<Int> {
        return Region2<Int>(origin: origin.vector, size: size.vector)
    }
}

extension CGSize {
    public static func makeSize(_ vector: Vector2<Int>) -> CGSize {
        return CGSize(width: vector.width, height: vector.height)
    }

    public var vector: Vector2<Int> {
        return Vector2<Int>(Int(width), Int(height))
    }
}
