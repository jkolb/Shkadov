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

import Metal
import MetalKit

public final class MetalRenderer : macOSRenderer {
    private let device: MTLDevice
    private let metalView: macOSMetalView
    public var view: ViewType {
        return metalView
    }
    private let config: RendererConfig
    public weak var rendererListener: RendererListener? {
        get {
            return metalView.rendererListener
        }
        set {
            metalView.rendererListener = newValue
        }
    }
    public weak var rawInputListener: RawInputListener? {
        get {
            return metalView.rawInputListener
        }
        set {
            metalView.rawInputListener = newValue
        }
    }
    
    public init(config: RendererConfig, logger: Logger) {
        self.device = MTLCreateSystemDefaultDevice()!
        let frame = CGRect(x: 0, y: 0, width: config.width, height: config.height)
        self.metalView = macOSMetalView(frame: frame, device: device, logger: logger)
        self.config = config
    }
    
    public static func isSupported() -> Bool {
        if let _ = MTLCreateSystemDefaultDevice() {
            return true
        }
        
        return false
    }
}