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

private enum RendererConfigName : String {
    case fovy
    case height
    case type
    case width
}

open class RendererConfig {
    private let rawConfig: RawConfig
    public let availableRendererTypes: Set<RendererType>
    
    public init(rawConfig: RawConfig, availableRendererTypes: Set<RendererType>) {
        self.rawConfig = rawConfig
        self.availableRendererTypes = availableRendererTypes
    }
    
    public var type: RendererType {
        get {
            if let value = RendererType(rawValue: getString(name: .type) ?? "") {
                return value
            }
            
            if availableRendererTypes.count == 0 {
                fatalError("No available renderers found")
            }
            
            let fallback = availableRendererTypes.first!
            self.type = fallback
            
            return fallback
        }
        set {
            putString(value: newValue.rawValue, name: .type)
        }
    }
    
    public var fovy: Angle<Float> {
        get {
            if let value = getFloat(name: .fovy) {
                return Angle<Float>(degrees: value)
            }
            
            let fallback = Angle<Float>(degrees: Engine.defaultFOVY)
            self.fovy = fallback
            
            return fallback
        }
        set {
            putFloat(value: newValue.degrees, name: .fovy)
        }
    }
    
    public var width: Int {
        get {
            if let value = getInt(name: .width) {
                return value
            }
            
            let fallback = Engine.minimumWidth
            self.width = fallback
            
            return fallback
        }
        set {
            putInt(value: newValue, name: .width)
        }
    }
    
    public var height: Int {
        get {
            if let value = getInt(name: .height) {
                return value
            }
            
            let fallback = Engine.minimumHeight
            self.height = fallback
            
            return fallback
        }
        set {
            putInt(value: newValue, name: .height)
        }
    }
    
    private func getBool(name: RendererConfigName) -> Bool? {
        return rawConfig.getBool(section: .renderer, name: name.rawValue)
    }
    
    private func getFloat(name: RendererConfigName) -> Float? {
        return rawConfig.getFloat(section: .renderer, name: name.rawValue)
    }
    
    private func getInt(name: RendererConfigName) -> Int? {
        return rawConfig.getInt(section: .renderer, name: name.rawValue)
    }
    
    private func getString(name: RendererConfigName) -> String? {
        return rawConfig.getString(section: .renderer, name: name.rawValue)
    }
    
    private func putBool(value: Bool, name: RendererConfigName) {
        rawConfig.putBool(value: value, section: .renderer, name: name.rawValue)
    }
    
    private func putFloat(value: Float, name: RendererConfigName) {
        rawConfig.putFloat(value: value, section: .renderer, name: name.rawValue)
    }
    
    private func putInt(value: Int, name: RendererConfigName) {
        rawConfig.putInt(value: value, section: .renderer, name: name.rawValue)
    }
    
    private func putString(value: String, name: RendererConfigName) {
        rawConfig.putString(value: value, section: .renderer, name: name.rawValue)
    }
}
