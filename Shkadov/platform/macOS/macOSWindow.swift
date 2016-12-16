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

import AppKit
import Swiftish

public struct macOSWindow : Window {
    public let handle: WindowHandle
    private unowned(unsafe) let instance: NSWindow
    
    internal init(handle: WindowHandle, instance: NSWindow) {
        self.handle = handle
        self.instance = instance
    }
    
    public var screen: Screen? {
        guard let screen = instance.screen else {
            return nil
        }
        
        return macOSScreen(instance: screen)
    }

    public var region: Region2<Int> {
        get {
            return instance.frame.toRegion()
        }
        set {
            instance.setFrame(CGRect.fromRegion(newValue), display: false)
        }
    }
    
    public var contentSize: Vector2<Int> {
        get {
            return instance.contentRect(forFrameRect: instance.frame).size.toVector()
        }
        set {
            var region = self.region
            region.size = instance.frameRect(forContentRect: CGSize.fromVector(newValue).toRect()).size.toVector()
            self.region = region
        }
    }
}

public final class macOSWindowOwner : WindowOwner {
    private var windows: [NSWindow?]
    private var reclaimedHandles: [WindowHandle]
    
    public init() {
        self.windows = []
        self.reclaimedHandles = []
        windows.reserveCapacity(2)
        reclaimedHandles.reserveCapacity(2)
    }
    
    public func createWindow(region: Region2<Int>) -> WindowHandle {
        let window = NSWindow(
            contentRect: CGRect.fromRegion(region),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false,
            screen: nil
        )
        windows.append(window)
        return nextHandle()
    }
    
    public func borrowWindow(handle: WindowHandle) -> Window {
        return macOSWindow(handle: handle, instance: self[handle])
    }
    
    public func destroyWindow(handle: WindowHandle) {
        reclaimedHandles.append(handle)
        windows[handle.index] = nil
    }
    
    private func nextHandle() -> WindowHandle {
        if reclaimedHandles.count > 0 {
            return reclaimedHandles.removeLast()
        }
        else {
            return WindowHandle(key: UInt8(windows.count))
        }
    }
    
    internal subscript (handle: WindowHandle) -> NSWindow {
        return windows[handle.index]!
    }
}
