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

public struct PlatformXCBCreateWindow : OptionSet {
	public let rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	public static var backPixmap = PlatformXCBCreateWindow(rawValue: XCB_CW_BACK_PIXMAP.rawValue)
	public static var backPixel = PlatformXCBCreateWindow(rawValue: XCB_CW_BACK_PIXEL.rawValue)
	public static var borderPixmap = PlatformXCBCreateWindow(rawValue: XCB_CW_BORDER_PIXMAP.rawValue)
	public static var borderPixel = PlatformXCBCreateWindow(rawValue: XCB_CW_BORDER_PIXEL.rawValue)
	public static var bitGravity = PlatformXCBCreateWindow(rawValue: XCB_CW_BIT_GRAVITY.rawValue)
	public static var winGravity = PlatformXCBCreateWindow(rawValue: XCB_CW_WIN_GRAVITY.rawValue)
	public static var backingStore = PlatformXCBCreateWindow(rawValue: XCB_CW_BACKING_STORE.rawValue)
	public static var backingPlanes = PlatformXCBCreateWindow(rawValue: XCB_CW_BACKING_PLANES.rawValue)
	public static var backingPixel = PlatformXCBCreateWindow(rawValue: XCB_CW_BACKING_PIXEL.rawValue)
	public static var overrideRedirect = PlatformXCBCreateWindow(rawValue: XCB_CW_OVERRIDE_REDIRECT.rawValue)
	public static var saveUnder = PlatformXCBCreateWindow(rawValue: XCB_CW_SAVE_UNDER.rawValue)
	public static var eventMask = PlatformXCBCreateWindow(rawValue: XCB_CW_EVENT_MASK.rawValue)
	public static var dontPropagate = PlatformXCBCreateWindow(rawValue: XCB_CW_DONT_PROPAGATE.rawValue)
	public static var colormap = PlatformXCBCreateWindow(rawValue: XCB_CW_COLORMAP.rawValue)
	public static var cursor = PlatformXCBCreateWindow(rawValue: XCB_CW_CURSOR.rawValue)
}
