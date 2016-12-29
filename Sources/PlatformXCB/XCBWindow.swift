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

public struct XCBWindow : Window, XCBDrawable {
	public let handle: WindowHandle
	private unowned(unsafe) let connection: XCBConnection
	let windowID: xcb_window_t

	public init(handle: WindowHandle, connection: XCBConnection, windowID: xcb_window_t) {
		self.handle = handle
		self.connection = connection
		self.windowID = windowID
	}

	var drawableID: xcb_drawable_t {
		return windowID
	}

	public var region: Region2<Int> {
		get {
			return try! connection.getGeometry(drawable: drawableID).reply().region
		}
		set {
			try! connection.configure(
				window: windowID,
				valueMask: [.x, .y, .width, .height],
				valueList: valueList(newValue)
			)
		}
	}

	public func show() {
		try! connection.mapWindow(window: windowID)
	}

	private func valueList(_ region: Region2<Int>) -> [UInt32] {
		return connection.valueList([
					region.origin.x,
					region.origin.y,
					region.size.width,
					region.size.height
				])
	}
}
