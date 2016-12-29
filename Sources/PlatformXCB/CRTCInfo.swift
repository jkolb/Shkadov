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
import Swiftish

public struct CRTCInfo {
	private let connection: OpaquePointer
	private let reply: UnsafePointer<xcb_randr_get_crtc_info_reply_t>

	init(connection: OpaquePointer, reply: UnsafePointer<xcb_randr_get_crtc_info_reply_t>) {
		self.connection = connection
		self.reply = reply
	}

	public var region: Region2<Int> {
		let info = reply.pointee
		let origin = Vector2<Int>(Int(info.x), Int(info.y))
		let size = Vector2<Int>(Int(info.width), Int(info.height))
		return Region2<Int>(origin: origin, size: size)
	}

	public var outputs: [Output] {
		let count = Int(xcb_randr_get_crtc_info_outputs_length(reply))
		guard let pointer = xcb_randr_get_crtc_info_outputs(reply) else {
			return []
		}

		var values = [Output]()
		values.reserveCapacity(count)

		for index in 0..<count {
			values.append(Output(connection: connection, instance: pointer[index]))
		}

		return values
	}
}
