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

private enum EngineConfigName : String {
    case loglevel
}

open class EngineConfig {
    private let rawConfig: RawConfig
    public let paths: FilePaths
    public let renderer: RendererConfig
    public let window: WindowConfig
    
    public init(rawConfig: RawConfig, paths: FilePaths, renderer: RendererConfig, window: WindowConfig) {
        self.rawConfig = rawConfig
        self.paths = paths
        self.renderer = renderer
        self.window = window
    }
    
    public var loglevel: LogLevel {
        get {
            let rawValue: UInt8
            
            if let value = getInt(name: .loglevel) {
                if value < Int(LogLevel.none.rawValue) {
                    let fallback = LogLevel.none
                    self.loglevel = fallback
                    rawValue = fallback.rawValue
                }
                else if value > Int(LogLevel.trace.rawValue) {
                    let fallback = LogLevel.trace
                    self.loglevel = fallback
                    rawValue = fallback.rawValue
                }
                else {
                    rawValue = UInt8(value)
                }
            }
            else {
                let fallback = LogLevel.none
                self.loglevel = fallback
                rawValue = fallback.rawValue
            }
            
            return LogLevel(rawValue: rawValue) ?? .none
        }
        set {
            putInt(value: Int(newValue.rawValue), name: .loglevel)
        }
    }
    
    private func getBool(name: EngineConfigName) -> Bool? {
        return rawConfig.getBool(section: .engine, name: name.rawValue)
    }
    
    private func getFloat(name: EngineConfigName) -> Float? {
        return rawConfig.getFloat(section: .engine, name: name.rawValue)
    }
    
    private func getInt(name: EngineConfigName) -> Int? {
        return rawConfig.getInt(section: .engine, name: name.rawValue)
    }
    
    private func getString(name: EngineConfigName) -> String? {
        return rawConfig.getString(section: .engine, name: name.rawValue)
    }
    
    private func putBool(value: Bool, name: EngineConfigName) {
        rawConfig.putBool(value: value, section: .engine, name: name.rawValue)
    }
    
    private func putFloat(value: Float, name: EngineConfigName) {
        rawConfig.putFloat(value: value, section: .engine, name: name.rawValue)
    }
    
    private func putInt(value: Int, name: EngineConfigName) {
        rawConfig.putInt(value: value, section: .engine, name: name.rawValue)
    }
    
    private func putString(value: String, name: EngineConfigName) {
        rawConfig.putString(value: value, section: .engine, name: name.rawValue)
    }
}
