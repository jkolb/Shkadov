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

public final class Config {
    private var config: [String:[String:Any]]
    
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
        return getValue(section: section, name: name)
    }
    
    public func getFloat(section: String, name: String) -> Float? {
        return getValue(section: section, name: name)
    }
    
    public func getInt(section: String, name: String) -> Int? {
        return getValue(section: section, name: name)
    }
    
    public func getString(section: String, name: String) -> String? {
        return getValue(section: section, name: name)
    }
    
    public func getAny(section: String, name: String) -> Any? {
        return getValue(section: section, name: name)
    }
    
    public func putBool(value: Bool, section: String, name: String) {
        putValue(value: value, section: section, name: name)
    }
    
    public func putFloat(value: Float, section: String, name: String) {
        putValue(value: value, section: section, name: name)
    }
    
    public func putInt(value: Int, section: String, name: String) {
        putValue(value: value, section: section, name: name)
    }
    
    public func putString(value: String, section: String, name: String) {
        putValue(value: value, section: section, name: name)
    }
    
    public func removeValue(section: String, name: String) {
        let _ = config[section]?.removeValue(forKey: name)
    }
    
    private func getValue<T>(section: String, name: String) -> T? {
        guard let values = config[section] else { return nil }
        guard let value = values[name] else { return nil }
        
        switch value {
        case let typedValue as T:
            return typedValue
        default:
            return nil
        }
    }
    
    private func putValue<T>(value: T, section: String, name: String) {
        if config[section] == nil {
            config[section] = [:]
        }
        
        config[section]![name] = value
    }
}
