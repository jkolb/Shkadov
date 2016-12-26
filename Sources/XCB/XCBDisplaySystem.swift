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
import ShkadovXCB
import Swiftish

public final class XCBDisplaySystem : DisplaySystem {
	private let connection: XCBConnection
	private var windows: [xcb_window_t?]

	public init(displayName: String? = nil) {
		self.connection = XCBConnection(displayName: displayName)
		self.windows = []
	}

	public var primaryScreen: Screen? {
		do {
			if let instance = try connection.primaryScreen() {
				return XCBScreen(
					displaySystem: self, 
					connection: connection, 
					instance: instance
				)
			}
			else {
				return nil
			}
		}
		catch {
			return nil
		}
	}

	public func withScreens<R>(_ body: ([Screen]) throws -> R) rethrows -> R {
		let screens = connection.screens().map({ XCBScreen(displaySystem: self, connection: connection, instance: $0) })

		return try body(screens)
	}

	private func nextWindowHandle() -> WindowHandle {
		return WindowHandle(key: windows.count)
	}

    subscript (handle: WindowHandle) -> xcb_window_t {
        return windows[handle.index]!
    }

    public func createWindow(region: Region2<Int>) -> WindowHandle {
    	return createWindow(region: region, screen: try! connection.primaryScreen()!)
    }

    func createWindow(region: Region2<Int>, screen: xcb_screen_t) -> WindowHandle {
    	let windowID = connection.generateID()
		let x = Int16(region.origin.x)
		let y = Int16(region.origin.y)
		let width = UInt16(region.origin.width)
		let height = UInt16(region.origin.height)
    	try! connection.createWindow(
    		depth: screen.root_depth,
    		windowID: windowID, 
    		parent:  screen.root,
    		x: x,
    		y: y,
    		width: width,
    		height: height,
    		borderWidth: 0,
    		windowClass: UInt16(0),
    		visual: screen.root_visual,
    		valueMask: 0,
    		valueList: []
    	)
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
