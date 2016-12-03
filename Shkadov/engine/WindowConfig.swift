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

private enum WindowConfigName : String {
    case width
    case height
    case fullscreen
}

open class WindowConfig {
    private let rawConfig: RawConfig
    public let title: String
    
    public init(rawConfig: RawConfig, title: String) {
        self.rawConfig = rawConfig
        self.title = title
    }
    
    public var width: Int {
        get {
            if let value = getInt(name: .width) {
                return value
            }
            
            let fallback = 800
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
            
            let fallback = 600
            self.height = fallback
            
            return fallback
        }
        set {
            putInt(value: newValue, name: .height)
        }
    }
    
    public var fullscreen: Bool {
        get {
            if let value = getBool(name: .fullscreen) {
                return value
            }
            
            let fallback = false
            self.fullscreen = fallback
            
            return fallback
        }
        set {
            putBool(value: newValue, name: .fullscreen)
        }
    }
    
    private func getBool(name: WindowConfigName) -> Bool? {
        return rawConfig.getBool(section: .window, name: name.rawValue)
    }
    
    private func getFloat(name: WindowConfigName) -> Float? {
        return rawConfig.getFloat(section: .window, name: name.rawValue)
    }
    
    private func getInt(name: WindowConfigName) -> Int? {
        return rawConfig.getInt(section: .window, name: name.rawValue)
    }
    
    private func getString(name: WindowConfigName) -> String? {
        return rawConfig.getString(section: .window, name: name.rawValue)
    }
    
    private func putBool(value: Bool, name: WindowConfigName) {
        rawConfig.putBool(value: value, section: .window, name: name.rawValue)
    }
    
    private func putFloat(value: Float, name: WindowConfigName) {
        rawConfig.putFloat(value: value, section: .window, name: name.rawValue)
    }
    
    private func putInt(value: Int, name: WindowConfigName) {
        rawConfig.putInt(value: value, section: .window, name: name.rawValue)
    }
    
    private func putString(value: String, name: WindowConfigName) {
        rawConfig.putString(value: value, section: .window, name: name.rawValue)
    }
}
