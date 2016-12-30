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

import Swiftish
import Platform

#if os(macOS)
import PlatformAppKit
#elseif os(Linux)
import PlatformXCB
#endif

public final class Application : PlatformListener {
	let platform: Platform
	let displaySystem: DisplaySystem

	public init() {
		#if os(macOS)
		self.platform = PlatformAppKit()
		self.displaySystem = AppKitDisplaySystem()
		#elseif os(Linux)
		self.platform = XCB()
		self.displaySystem = XCBDisplaySystem(displayName: nil)
		#endif

		platform.listener = self
	}

	public func run() {
		platform.startup()
	}

	public func didStartup() {
		guard let primaryScreen = displaySystem.primaryScreen else {
			fatalError("No primary screen")
		}

		let origin = Vector2<Int>()
		let size = Vector2<Int>(320, 200)
		let region = Region2<Int>(origin: origin, size: size)
		let windowHandle = displaySystem.createWindow(region: region, screen: primaryScreen)
		let window = displaySystem.borrowWindow(handle: windowHandle)
		window.show()

		#if os(Linux)
		// Need an event loop
		for _ in 0..<5000000 { print("Waiting") }
		#endif
	}
}

Application().run()
