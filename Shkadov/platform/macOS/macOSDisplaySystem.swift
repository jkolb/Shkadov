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

public struct macOSScreen : Screen {
    private let instance: NSScreen
    
    public init(instance: NSScreen) {
        self.instance = instance
    }

    public var region: Region2<Int> {
        return instance.frame.toRegion()
    }
    
    public var size: Vector2<Int> {
        return region.size
    }
    
    public var scale: Float {
        return Float(instance.backingScaleFactor)
    }
}

public protocol DisplaySystemListener : class {
    func screensChanged()
}

public final class macOSDisplaySystem : DisplaySystem {
    public weak var listener: DisplaySystemListener?
    
    public init() {
        NotificationCenter.default.addObserver(forName: .NSApplicationDidChangeScreenParameters, object: self, queue: OperationQueue.main) { [unowned self] (notification) in
            self.listener?.screensChanged()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func queryAvailableScreens() -> [Screen] {
        var screens = [Screen]()
        
        for screen in NSScreen.screens() ?? [] {
            screens.append(macOSScreen(instance: screen))
        }
        
        return screens
    }
}
