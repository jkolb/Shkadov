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

private enum StandardRendererConfigName : String {
    case type
}

open class StandardRendererConfig {
    private let rawConfig: RawConfig
    private let supportedRendererTypes: Set<RendererType>
    
    public init(rawConfig: RawConfig, supportedRendererTypes: Set<RendererType>) {
        self.rawConfig = rawConfig
        self.supportedRendererTypes = supportedRendererTypes
    }
    
    public var type: RendererType {
        get {
            if let rendererType = RendererType(rawValue: getString(name: .type) ?? "") {
                return rendererType
            }
            
            if supportedRendererTypes.count == 0 {
                fatalError("No supported renderers found")
            }
            
            let fallbackRendererType = supportedRendererTypes.first!
            self.type = fallbackRendererType
            
            return fallbackRendererType
        }
        set {
            putString(value: newValue.rawValue, name: .type)
        }
    }
    
    private func getString(name: StandardRendererConfigName) -> String? {
        return rawConfig.getString(section: StandardConfigSection.renderer.rawValue, name: name.rawValue)
    }
    
    private func putString(value: String, name: StandardRendererConfigName) {
        rawConfig.putString(value: value, section: StandardConfigSection.renderer.rawValue, name: name.rawValue)
    }
}
