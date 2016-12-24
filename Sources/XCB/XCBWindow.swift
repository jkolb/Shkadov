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

public struct XCBWindow : Window {
	public let handle: WindowHandle
	private let connection: OpaquePointer
	private let instance: xcb_window_t

	public init(handle: WindowHandle, connection: OpaquePointer, instance: xcb_window_t) {
		self.handle = handle
		self.connection = connection
		self.instance = instance
	}

	public var region: Region2<Int> {
		get {
			return try! getGeometryReply().region
		}
		set {
			try! configureWindow(
				valueMask: [.x, .y, .width, .height],
				valueList: valueList(newValue)
			)
		}
	}

	private func valueList(_ region: Region2<Int>) -> [UInt32] {
		return valueList([
					region.origin.x,
					region.origin.y,
					region.size.width,
					region.size.height
				])
	}

	private func valueList(_ values: [Int]) -> [UInt32] {
		return values.map({ UInt32(truncatingBitPattern: $0) })
	}

	private func configureWindow(valueMask: XCBConfigWindow, valueList: [UInt32]) throws {
		let cookie = xcb_configure_window_checked(connection, instance, valueMask.rawValue, valueList)

		if let errorPointer = xcb_request_check(connection, cookie) {
			throw XCBError.generic(unwrap(errorPointer))
		}
	}

	private func getGeometryReply() throws -> xcb_get_geometry_reply_t {
		let cookie = xcb_get_geometry(connection, instance)
		var errorPointer: UnsafeMutablePointer<xcb_generic_error_t>?

		if let replyPointer = xcb_get_geometry_reply(connection, cookie, &errorPointer) {
			return unwrap(replyPointer)
		}
		else if let errorPointer = errorPointer {
			throw XCBError.generic(unwrap(errorPointer))
		}
		else {
			throw XCBError.improbable
		}
	}

	private func unwrap<T>(_ pointer: UnsafeMutablePointer<T>) -> T {
		let pointee = pointer.pointee
		pointer.deinitialize(count: 1)
		pointer.deallocate(capacity: 1)

		return pointee
	}
}

public struct XCBConfigWindow : OptionSet {
	public let rawValue: UInt16

	public init(rawValue: UInt16) {
		self.rawValue = rawValue
	}

	public static var x = XCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_X.rawBits)
	public static var y = XCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_Y.rawBits)
	public static var width = XCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_WIDTH.rawBits)
	public static var height = XCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_HEIGHT.rawBits)
	public static var borderWidth = XCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_BORDER_WIDTH.rawBits)
	public static var sibling = XCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_SIBLING.rawBits)
	public static var stackMode = XCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_STACK_MODE.rawBits)
}

public extension xcb_get_geometry_reply_t {
	public var region: Region2<Int> {
		let origin = Vector2<Int>(Int(x), Int(y))
		let size = Vector2<Int>(Int(width), Int(height))

		return Region2<Int>(origin: origin, size: size)
	}
}

public extension xcb_config_window_t {
	public var rawBits: UInt16 {
		return UInt16(truncatingBitPattern: rawValue)
	}
}
