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

import Platform
import Logger
import ShkadovXCB
import Swiftish
import Utility

public final class XCB : Platform {
    public weak var listener: PlatformListener?
    private let logger: Logger
    private let connection: XCBConnection
    private var running: Bool
    private var windows: [xcb_window_t?]

    public init(displayName: String?, loggerFactory: LoggerFactory) {
        self.logger = loggerFactory.makeLogger()
        self.connection = try! XCBConnection(displayName: displayName)
        self.windows = []
        self.running = false
    }

    public func startup() {
        running = true
        didStartup()

        while running {
            handleEvents()
        }
    }
    
    private func didStartup() {
        listener?.didStartup()
    }

    public var currentTime: Time {
        return Time.zero
    }

    public var cursorHidden: Bool = false
    public var cursorFollowsMouse: Bool = true

    public func moveCursor(to point: Vector2<Float>) {

    }

    private func handleEvents() {
        while let event = connection.pollForEvent() {
            if event.isKeyEvent {
                handle(keyEvent: event.asKeyEvent())
            }
            else if event.isButtonEvent {
                handle(buttonEvent: event.asButtonEvent())
            }
            else if event.isMotionEvent {
                handle(motionEvent: event.asMotionEvent())
            }
        }
    }

    private func handle(keyEvent: XCBKeyEvent) {
        logger.debug("\(keyEvent)")
    }

    private func handle(buttonEvent: XCBButtonEvent) {
        logger.debug("\(buttonEvent)")
    }

    private func handle(motionEvent: XCBMotionEvent) {
        logger.debug("\(motionEvent)")
    }

    public var primaryScreen: Screen? {
        do {
            if let instance = try connection.primaryScreen() {
                let screens = try makeScreens(for: instance)

                for screen in screens {
                    if screen.region.origin == Vector2<Int>() {
                        return screen
                    }
                }

                return nil
            }
            else {
                return nil
            }
        }
        catch {
            return nil
        }
    }

    public func withScreens<R>(_ body: ([Screen]) throws -> R) throws -> R {
        var screens = [Screen]()

        for screen in connection.screens() {
            screens.append(contentsOf: try makeScreens(for: screen))
        }

        return try body(screens)
    }

    private func makeScreens(for screen: xcb_screen_t) throws -> [Screen] {
        var screens = [Screen]()

        try connection.getScreenResources(window: screen.root).withReply { (screenResources) in
            for crtc in screenResources.crtcs {
                try crtc.getInfo().withReply { (crtcInfo) in
                    for output in crtcInfo.outputs {
                        try output.getInfo().withReply() { (outputInfo) in
                            if outputInfo.connected {
                                screens.append(XCBScreen(instance: screen, crtc: crtc.instance, output: output.instance, region: crtcInfo.region))
                            }
                        }
                    }
                }
            }
        }

        return screens
    }

    private func nextWindowHandle() -> WindowHandle {
        return WindowHandle(key: windows.count)
    }

    subscript (handle: WindowHandle) -> xcb_window_t {
        return windows[handle.index]!
    }

    public func createWindow(region: Region2<Int>, screen: Screen) -> WindowHandle {
        let nativeScreen = screen as! XCBScreen

        return createWindow(region: region, screen: nativeScreen.instance)
    }

    func createWindow(region: Region2<Int>, screen: xcb_screen_t) -> WindowHandle {
        let windowID = connection.generateID()
        let x = Int16(region.origin.x)
        let y = Int16(region.origin.y)
        let width = UInt16(region.size.width)
        precondition(width > 0)
        let height = UInt16(region.size.height)
        precondition(height > 0)
        let eventMask: XCBEventMask = [.keyRelease, .keyPress, .structureNotify, .pointerMotion, .buttonPress, .buttonRelease]
        do {
            try connection.createWindow(
                depth: screen.root_depth,
                window: windowID, 
                parent: screen.root,
                x: x,
                y: y,
                width: width,
                height: height,
                borderWidth: 0,
                windowClass: UInt16(XCB_WINDOW_CLASS_INPUT_OUTPUT.rawValue),
                visual: screen.root_visual,
                valueMask: [.backPixel, .eventMask],
                // Warning values with a lower bit must come before ones with a higher bit
                valueList: [screen.black_pixel, eventMask.rawValue]
            )
        }
        catch {
            fatalError("XCB: Unable to create window \(error)")
        }
        return addWindow(windowID)
    }

    private func addWindow(_ windowID: xcb_window_t) -> WindowHandle {
        let handle = nextWindowHandle()
        windows.insert(windowID, at: handle.index)
        return handle
    }

    public func borrowWindow(handle: WindowHandle) -> Window {
        return XCBWindow(handle: handle, connection: connection, windowID: self[handle])
    }

    public func destroyWindow(handle: WindowHandle) {
    }
}

public extension xcb_get_geometry_reply_t {
    public var region: Region2<Int> {
        let origin = Vector2<Int>(Int(x), Int(y))
        let size = Vector2<Int>(Int(width), Int(height))

        return Region2<Int>(origin: origin, size: size)
    }
}
