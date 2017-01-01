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

public final class XCBApplication {
	public weak var delegate: XCBApplicationDelegate?
	private unowned(unsafe) let connection: XCBConnection
	public private(set) var isRunning: Bool

	init(connection: XCBConnection) {
		self.connection = connection
		self.isRunning = false
	}

	public func run() {
		isRunning = true
		delegate?.applicationDidFinishLaunching(self)

		while isRunning {
			handleEvents()
		}
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
		delegate?.application(self, didReceiveKeyEvent: keyEvent)
	}

	private func handle(buttonEvent: XCBButtonEvent) {
		delegate?.application(self, didReceiveButtonEvent: buttonEvent)
	}

	private func handle(motionEvent: XCBMotionEvent) {
		delegate?.application(self, didReceiveMotionEvent: motionEvent)
	}
}
