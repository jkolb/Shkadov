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

public struct XCBEventMask : OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let noEvent = XCBEventMask(rawValue: XCB_EVENT_MASK_NO_EVENT.rawValue)
    public static let keyPress = XCBEventMask(rawValue: XCB_EVENT_MASK_KEY_PRESS.rawValue)
    public static let keyRelease = XCBEventMask(rawValue: XCB_EVENT_MASK_KEY_RELEASE.rawValue)
    public static let buttonPress = XCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_PRESS.rawValue)
    public static let buttonRelease = XCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_RELEASE.rawValue)
    public static let enterWindow = XCBEventMask(rawValue: XCB_EVENT_MASK_ENTER_WINDOW.rawValue)
    public static let leaveWindow = XCBEventMask(rawValue: XCB_EVENT_MASK_LEAVE_WINDOW.rawValue)
    public static let pointerMotion = XCBEventMask(rawValue: XCB_EVENT_MASK_POINTER_MOTION.rawValue)
    public static let pointerMotionHint = XCBEventMask(rawValue: XCB_EVENT_MASK_POINTER_MOTION_HINT.rawValue)
    public static let button1Motion = XCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_1_MOTION.rawValue)
    public static let button2Motion = XCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_3_MOTION.rawValue)
    public static let button4Motion = XCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_4_MOTION.rawValue)
    public static let button5Motion = XCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_5_MOTION.rawValue)
    public static let buttonMotion = XCBEventMask(rawValue: XCB_EVENT_MASK_BUTTON_MOTION.rawValue)
    public static let keymapState = XCBEventMask(rawValue: XCB_EVENT_MASK_KEYMAP_STATE.rawValue)
    public static let exposure = XCBEventMask(rawValue: XCB_EVENT_MASK_EXPOSURE.rawValue)
    public static let visibilityChange = XCBEventMask(rawValue: XCB_EVENT_MASK_VISIBILITY_CHANGE.rawValue)
    public static let structureNotify = XCBEventMask(rawValue: XCB_EVENT_MASK_STRUCTURE_NOTIFY.rawValue)
    public static let resizeRedirect = XCBEventMask(rawValue: XCB_EVENT_MASK_RESIZE_REDIRECT.rawValue)
    public static let substructureNotify = XCBEventMask(rawValue: XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY.rawValue)
    public static let substructureRedirect = XCBEventMask(rawValue: XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT.rawValue)
    public static let focusChange = XCBEventMask(rawValue: XCB_EVENT_MASK_FOCUS_CHANGE.rawValue)
    public static let propertyChange = XCBEventMask(rawValue: XCB_EVENT_MASK_PROPERTY_CHANGE.rawValue)
    public static let colorMapChange = XCBEventMask(rawValue: XCB_EVENT_MASK_COLOR_MAP_CHANGE.rawValue)
    public static let ownerGrabButton = XCBEventMask(rawValue: XCB_EVENT_MASK_OWNER_GRAB_BUTTON.rawValue)
}
