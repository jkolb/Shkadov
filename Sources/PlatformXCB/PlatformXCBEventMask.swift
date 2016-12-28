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

public struct PlatformXCBEventMask : OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let noEvent = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_NO_EVENT.rawValue)
    public static let keyPress = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_KEY_PRESS.rawValue)
    public static let keyRelease = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_KEY_RELEASE.rawValue)
    public static let buttonPress = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_PRESS.rawValue)
    public static let buttonRelease = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_RELEASE.rawValue)
    public static let enterWindow = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_ENTER_WINDOW.rawValue)
    public static let leaveWindow = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_LEAVE_WINDOW.rawValue)
    public static let pointerMotion = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_POINTER_MOTION.rawValue)
    public static let pointerMotionHint = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_POINTER_MOTION_HINT.rawValue)
    public static let button1Motion = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_1_MOTION.rawValue)
    public static let button2Motion = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_3_MOTION.rawValue)
    public static let button4Motion = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_4_MOTION.rawValue)
    public static let button5Motion = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_5_MOTION.rawValue)
    public static let buttonMotion = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_MOTION.rawValue)
    public static let keymapState = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_KEYMAP_STATE.rawValue)
    public static let exposure = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_EXPOSURE.rawValue)
    public static let visibilityChange = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_VISIBILITY_CHANGE.rawValue)
    public static let structureNotify = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_STRUCTURE_NOTIFY.rawValue)
    public static let resizeRedirect = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_RESIZE_REDIRECT.rawValue)
    public static let substructureNotify = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY.rawValue)
    public static let substructureRedirect = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT.rawValue)
    public static let focusChange = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_FOCUS_CHANGE.rawValue)
    public static let propertyChange = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_PROPERTY_CHANGE.rawValue)
    public static let colorMapChange = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_COLOR_MAP_CHANGE.rawValue)
    public static let ownerGrabButton = PlatformXCBEventMask(rawValue: XCB_EVENT_MASK_OWNER_GRAB_BUTTON.rawValue)
}
