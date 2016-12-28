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
import Platform
import Swiftish

public final class PlatformAppKitDisplaySystem : DisplaySystem {
	private var windows: [NSWindow?]

	public init() {
		self.windows = []
	}

	public var primaryScreen: Screen? {
		guard let screens = NSScreen.screens() else {
			return nil
		}

		if screens.count == 0 {
			return nil
		}

		return PlatformAppKitScreen(displaySystem: self, instance: screens[0])
	}

	public func withScreens<R>(_ body: ([Screen]) throws -> R) rethrows -> R {
		guard let screens = NSScreen.screens() else {
			return try body([])
		}

		return try body(screens.map({ PlatformAppKitScreen(displaySystem: self, instance: $0) }))
	}

	private func nextWindowHandle() -> WindowHandle {
		return WindowHandle(key: windows.count)
	}

    subscript (handle: WindowHandle) -> NSWindow {
        return windows[handle.index]!
    }

    public func createWindow(region: Region2<Int>) -> WindowHandle {
    	return createWindow(region: region, screen: NSScreen.screens()?.first)
    }

    func createWindow(region: Region2<Int>, screen: NSScreen?) -> WindowHandle {
    	let window = NSWindow(
			contentRect: CGRect.makeRect(region),
			styleMask: [.titled, .closable, .miniaturizable, .resizable],
			backing: .buffered,
			defer: false,
			screen: screen
    	)
        window.collectionBehavior = .fullScreenPrimary
        window.backgroundColor = NSColor.black
    	return addWindow(window)
    }

    private func addWindow(_ window: NSWindow) -> WindowHandle {
    	let handle = nextWindowHandle()
    	windows.insert(window, at: handle.index)
    	return handle
    }

    public func borrowWindow(handle: WindowHandle) -> Window {
    	return PlatformAppKitWindow(handle: handle, instance: self[handle])
    }

    public func destroyWindow(handle: WindowHandle) {
    }
}

extension CGPoint {
	public static func makePoint(_ vector: Vector2<Int>) -> CGPoint {
		return CGPoint(x: vector.x, y: vector.y)
	}

	public var vector: Vector2<Int> {
		return Vector2<Int>(Int(x), Int(y))
	}
}

extension CGRect {
	public static func makeRect(_ region: Region2<Int>) -> CGRect {
		return CGRect(origin: CGPoint.makePoint(region.origin), size: CGSize.makeSize(region.size))
	}

	public var region: Region2<Int> {
		return Region2<Int>(origin: origin.vector, size: size.vector)
	}
}

extension CGSize {
	public static func makeSize(_ vector: Vector2<Int>) -> CGSize {
		return CGSize(width: vector.width, height: vector.height)
	}

	public var vector: Vector2<Int> {
		return Vector2<Int>(Int(width), Int(height))
	}
}
