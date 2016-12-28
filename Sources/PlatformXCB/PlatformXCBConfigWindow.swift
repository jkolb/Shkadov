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

public struct PlatformXCBConfigWindow : OptionSet {
	public let rawValue: UInt16

	public init(rawValue: UInt16) {
		self.rawValue = rawValue
	}

	public static var x = PlatformXCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_X.rawBits)
	public static var y = PlatformXCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_Y.rawBits)
	public static var width = PlatformXCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_WIDTH.rawBits)
	public static var height = PlatformXCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_HEIGHT.rawBits)
	public static var borderWidth = PlatformXCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_BORDER_WIDTH.rawBits)
	public static var sibling = PlatformXCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_SIBLING.rawBits)
	public static var stackMode = PlatformXCBConfigWindow(rawValue: XCB_CONFIG_WINDOW_STACK_MODE.rawBits)
}

public extension xcb_config_window_t {
	public var rawBits: UInt16 {
		return UInt16(truncatingBitPattern: rawValue)
	}
}
