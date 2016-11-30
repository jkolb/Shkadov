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

public final class Engine {
    public weak var listener: EngineListener?
    
    private let rawConfig: RawConfig
    private let config: EngineConfig
    private let windowSystem: WindowSystem
    private let timeSource: TimeSource
    private let renderer: Renderer
    private let mouseCursorManager: MouseCursorManager
    private let logger: Logger
    
    public init(rawConfig: RawConfig, config: EngineConfig, windowSystem: WindowSystem, timeSource: TimeSource, renderer: Renderer, mouseCursorManager: MouseCursorManager, logger: Logger) {
        self.rawConfig = rawConfig
        self.config = config
        self.windowSystem = windowSystem
        self.timeSource = timeSource
        self.renderer = renderer
        self.mouseCursorManager = mouseCursorManager
        self.logger = logger
    }
    
    public func startup() {
        logger.trace("\(#function)")
        windowSystem.startup()
    }
    
    public func shutdown() {
        logger.trace("\(#function)")
        windowSystem.shutdown()
    }
    
    public func writeConfig() throws {
        logger.trace("\(#function)")
        
    }
    
    public var currentTime: Time {
        return timeSource.currentTime
    }
    
    public var mouseCursorHidden: Bool {
        get {
            return mouseCursorManager.hidden
        }
        set {
            mouseCursorManager.hidden = newValue
        }
    }
    
    public var followsMouseCursor: Bool {
        get {
            return mouseCursorManager.followsMouse
        }
        set {
            mouseCursorManager.followsMouse = newValue
        }
    }
    
    public func moveMouseCursor(to point: Vector2<Float>) {
        mouseCursorManager.move(to: point)
    }

}
