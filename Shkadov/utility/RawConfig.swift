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

public enum RawConfigValue {
    case double(Double)
    case string(String)
}

public final class RawConfig {
    private var config: [String:[String:RawConfigValue]]
    
    public init() {
        self.config = [:]
    }
    
    public var sections: [String] {
        return [String](config.keys)
    }
    
    public func names(section: String) -> [String] {
        if let names = config[section]?.keys {
            return [String](names)
        }
        
        return []
    }
    
    public func getBool(section: String, name: String) -> Bool? {
        return getDouble(section: section, name: name) != 0.0
    }
    
    public func getInt(section: String, name: String) -> Int? {
        if let doubleValue = getDouble(section: section, name: name) {
            return Int(doubleValue)
        }
        else {
            return nil
        }
        
    }
    
    public func getFloat(section: String, name: String) -> Float? {
        if let doubleValue = getDouble(section: section, name: name) {
            return Float(doubleValue)
        }
        else {
            return nil
        }
        
    }
    
    public func getDouble(section: String, name: String) -> Double? {
        guard let values = config[section] else { return nil }
        guard let value = values[name] else { return nil }
        
        switch value {
        case .double(let doubleValue):
            return doubleValue
        default:
            return nil
        }
    }
    
    public func getString(section: String, name: String) -> String? {
        guard let values = config[section] else { return nil }
        guard let value = values[name] else { return nil }
        
        switch value {
        case .string(let stringValue):
            return stringValue
        default:
            return nil
        }
    }
    
    public func getRawValue(section: String, name: String) -> RawConfigValue? {
        return config[section]?[name]
    }
    
    public func putBool(value: Bool, section: String, name: String) {
        putDouble(value: value ? 1.0 : 0.0, section: section, name: name)
    }
    
    public func putInt(value: Int, section: String, name: String) {
        putDouble(value: Double(value), section: section, name: name)
    }
    
    public func putFloat(value: Float, section: String, name: String) {
        putDouble(value: Double(value), section: section, name: name)
    }
    
    public func putDouble(value: Double, section: String, name: String) {
        if config[section] == nil {
            config[section] = [:]
        }
        
        config[section]![name] = .double(value)
    }
    
    public func putString(value: String, section: String, name: String) {
        if config[section] == nil {
            config[section] = [:]
        }
        
        config[section]![name] = .string(value)
    }
    
    public func removeValue(section: String, name: String) {
        let _ = config[section]?.removeValue(forKey: name)
    }
}
