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

import ShkadovXCB

public final class PlatformXCBConnection {
	private let connection: OpaquePointer
	private let primaryScreenNumber: Int32

	init(displayName: String?) {
		var screenNumber: Int32 = 0

		guard let connection = xcb_connect(displayName, &screenNumber) else {
			fatalError("Unable to create XCB connection to display name \(displayName)")
		}

		self.connection = connection
		self.primaryScreenNumber = screenNumber
	}

	deinit {
		xcb_disconnect(connection)
	}

	func valueList(_ values: [Int]) -> [UInt32] {
		return values.map({ UInt32(truncatingBitPattern: $0) })
	}

	func generateID() -> UInt32 {
		return xcb_generate_id(connection)
	}

	func primaryScreen() throws -> xcb_screen_t? {
		var iterator = xcb_setup_roots_iterator(xcb_get_setup(connection))

		if iterator.rem == 0 {
			return nil
		}

		if primaryScreenNumber >= iterator.rem {
			// Return first screen
			return iterator.data.pointee
		}

		for _ in 0..<primaryScreenNumber {
			xcb_screen_next(&iterator)
		}

		return iterator.data.pointee
	}

	func screens() -> [xcb_screen_t] {
		var iterator = xcb_setup_roots_iterator(xcb_get_setup(connection))
		var screens = [xcb_screen_t]()
		screens.reserveCapacity(Int(iterator.rem))

		while iterator.rem > 0 {
			screens.append(iterator.data.pointee)
			xcb_screen_next(&iterator)
		}

		return screens
	}

	func createWindow(depth: UInt8, window: xcb_window_t, parent: xcb_window_t, x: Int16, y: Int16, width: UInt16, height: UInt16, borderWidth: UInt16, windowClass: UInt16, visual: xcb_visualid_t, valueMask: PlatformXCBCreateWindow, valueList: [UInt32]) throws {
		let cookie = xcb_create_window_checked(connection, depth, window, parent, x, y, width, height, borderWidth, windowClass, visual, valueMask.rawValue, valueList)

		if let errorPointer = xcb_request_check(connection, cookie) {
			throw PlatformXCBError.generic(unwrap(errorPointer))
		}
	}

	func mapWindow(window: xcb_window_t) throws {
		let cookie = xcb_map_window_checked(connection, window)

		if let errorPointer = xcb_request_check(connection, cookie) {
			throw PlatformXCBError.generic(unwrap(errorPointer))
		}
	}

	func configure(window: xcb_window_t, valueMask: PlatformXCBConfigWindow, valueList: [UInt32]) throws {
		let cookie = xcb_configure_window_checked(connection, window, valueMask.rawValue, valueList)

		if let errorPointer = xcb_request_check(connection, cookie) {
			throw PlatformXCBError.generic(unwrap(errorPointer))
		}
	}

	func getGeometryReply(drawable: xcb_drawable_t) throws -> xcb_get_geometry_reply_t {
		let cookie = xcb_get_geometry(connection, drawable)
		var errorPointer: UnsafeMutablePointer<xcb_generic_error_t>?

		if let replyPointer = xcb_get_geometry_reply(connection, cookie, &errorPointer) {
			return unwrap(replyPointer)
		}
		else if let errorPointer = errorPointer {
			throw PlatformXCBError.generic(unwrap(errorPointer))
		}
		else {
			throw PlatformXCBError.improbable
		}
	}

	func unwrap<T>(_ pointer: UnsafeMutablePointer<T>) -> T {
		let pointee = pointer.pointee
		pointer.deinitialize(count: 1)
		pointer.deallocate(capacity: 1)

		return pointee
	}
}
