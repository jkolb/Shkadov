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

public final class XCBGenericEvent {
	private let pointer: UnsafeMutablePointer<xcb_generic_event_t>

	init(pointer: UnsafeMutablePointer<xcb_generic_event_t>) {
		self.pointer = pointer
	}

	deinit {
		free(pointer)
	}

	public var isKeyEvent: Bool {
		return matchesReponseType(XCB_KEY_PRESS) || matchesReponseType(XCB_KEY_RELEASE)
	}

	public func asKeyEvent() -> XCBKeyEvent {
		return pointer.withMemoryRebound(to: xcb_key_press_event_t.self, capacity: 1) { (specificPointer) in
			XCBKeyEvent(instance: specificPointer.pointee, pressed: matchesReponseType(XCB_KEY_PRESS))
		}
	}

	public var isButtonEvent: Bool {
		return matchesReponseType(XCB_BUTTON_PRESS) || matchesReponseType(XCB_BUTTON_RELEASE)
	}

	public func asButtonEvent() -> XCBButtonEvent {
		return pointer.withMemoryRebound(to: xcb_button_press_event_t.self, capacity: 1) { (specificPointer) in
			XCBButtonEvent(instance: specificPointer.pointee, pressed: matchesReponseType(XCB_BUTTON_PRESS))
		}
	}

	public var isMotionEvent: Bool {
		return matchesReponseType(XCB_MOTION_NOTIFY)
	}

	public func asMotionEvent() -> XCBMotionEvent {
		return pointer.withMemoryRebound(to: xcb_motion_notify_event_t.self, capacity: 1) { (specificPointer) in
			XCBMotionEvent(instance: specificPointer.pointee)
		}
	}

	private func matchesReponseType(_ responseType: Int32) -> Bool {
		return pointer.pointee.response_type & 0x7F == UInt8(responseType)
	}
}
