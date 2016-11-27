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

import Foundation

public final class FoundationConfigReader : ConfigReader {
    public func read(path: String) throws -> Config {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let configObject = try JSONSerialization.jsonObject(with: data, options: [])
        let config = Config()
        
        if let sections = configObject as? [String:Any] {
            for (section, sectionObject) in sections {
                if let values = sectionObject as? [String:Any] {
                    for (name, valueObject) in values {
                        switch valueObject {
                        case let value as Bool:
                            config.putBool(value: value, section: section, name: name)
                        case let value as Float:
                            config.putFloat(value: value, section: section, name: name)
                        case let value as Int:
                            config.putInt(value: value, section: section, name: name)
                        case let value as String:
                            config.putString(value: value, section: section, name: name)
                        default:
                            continue
                        }
                    }
                }
            }
        }
        
        return config
    }
}
