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

public enum ConfigSection : String {
    case engine
    case renderer
    case window
}

extension RawConfig {
    public func getBool(section: ConfigSection, name: String) -> Bool? {
        return getBool(section: section.rawValue, name: name)
    }
    
    public func getDouble(section: ConfigSection, name: String) -> Double? {
        return getDouble(section: section.rawValue, name: name)
    }
    
    public func getFloat(section: ConfigSection, name: String) -> Float? {
        return getFloat(section: section.rawValue, name: name)
    }
    
    public func getInt(section: ConfigSection, name: String) -> Int? {
        return getInt(section: section.rawValue, name: name)
    }
    
    public func getString(section: ConfigSection, name: String) -> String? {
        return getString(section: section.rawValue, name: name)
    }
    
    public func putBool(value: Bool, section: ConfigSection, name: String) {
        putBool(value: value, section: section.rawValue, name: name)
    }
    
    public func putDouble(value: Double, section: ConfigSection, name: String) {
        putDouble(value: value, section: section.rawValue, name: name)
    }
    
    public func putFloat(value: Float, section: ConfigSection, name: String) {
        putFloat(value: value, section: section.rawValue, name: name)
    }
    
    public func putInt(value: Int, section: ConfigSection, name: String) {
        putInt(value: value, section: section.rawValue, name: name)
    }
    
    public func putString(value: String, section: ConfigSection, name: String) {
        putString(value: value, section: section.rawValue, name: name)
    }
    
    public func removeValue(section: ConfigSection, name: String) {
        removeValue(section: section.rawValue, name: name)
    }
}
