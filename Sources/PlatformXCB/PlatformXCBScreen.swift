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

public struct PlatformXCBScreen : Screen {
	unowned(unsafe) let displaySystem: PlatformXCBDisplaySystem
	unowned(unsafe) let connection: PlatformXCBConnection
	let instance: xcb_screen_t

	public init(displaySystem: PlatformXCBDisplaySystem, connection: PlatformXCBConnection, instance: xcb_screen_t) {
		self.displaySystem = displaySystem
		self.connection = connection
		self.instance = instance
	}

	public var region: Region2<Int> {
		return try! connection.getGeometryReply(drawable: instance.root).region
	}

    public func createWindow(region: Region2<Int>) -> WindowHandle {
    	return displaySystem.createWindow(region: region, screen: instance)
    }
}
