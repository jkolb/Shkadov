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

import ShkadovXCB.RandR

public struct GetScreenResources {
	private let connection: OpaquePointer
	private let window: xcb_window_t

	init(connection: OpaquePointer, window: xcb_window_t) {
		self.connection = connection
		self.window = window
	}

	public func withReply<R>(_ body: (ScreenResources) throws -> R) throws -> R {
		let cookie = xcb_randr_get_screen_resources(connection, window)
		var errorPointer: UnsafeMutablePointer<xcb_generic_error_t>?

		if let replyPointer = xcb_randr_get_screen_resources_reply(connection, cookie, &errorPointer) {
			defer {
				free(replyPointer)
			}

			return try body(ScreenResources(connection: connection, reply: replyPointer))
		}
		else if let errorPointer = errorPointer {
			defer {
				free(errorPointer)
			}

			throw XCBError.generic(errorPointer.pointee)
		}
		else {
			throw XCBError.improbable
		}
	}
}
