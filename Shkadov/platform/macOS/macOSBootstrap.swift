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

import AppKit
import FieryCrucible

public final class macOSBootstrap<T : EngineListener> : DependencyFactory, Bootstrap {
    public typealias EngineListenerType = T
    private let logger = macOSLoggerFactory().makeLogger(name: "BOOTSTRAP")
    
    public func makeEngine() -> Engine {
        let loggerFactory = macOSLoggerFactory()
        let timeSource = MachOTimeSource()
        let applicationNameProvider = FoundationApplicationNameProvider()
        let paths = FoundationFilePaths(applicationNameProvider: applicationNameProvider)
        let rawConfig = readConfig(path: paths.configPath)
        let rendererConfig = RendererConfig(rawConfig: rawConfig, supportedRendererTypes: determineSupportedRendererTypes())
        let windowConfig = WindowConfig(rawConfig: rawConfig, title: FoundationApplicationNameProvider().applicationName)
        let config = EngineConfig(rawConfig: rawConfig, paths: paths, renderer: rendererConfig, window: windowConfig)
        logger.level = config.loglevel
        let windowSystem = macOSWindowSystem(config: windowConfig, logger: loggerFactory.makeLogger(name: "WINDOW"))
        let renderer = macOSRendererFactory().makeRenderer(windowSystem: windowSystem, config: rendererConfig, logger: loggerFactory.makeLogger(name: "RENDERER"))
        windowSystem.showWindow()
        let engine = Engine(rawConfig: rawConfig, config: config, windowSystem: windowSystem, timeSource: timeSource, renderer: renderer, mouseCursorManager: macOSMouseCursorManager(), logger: loggerFactory.makeLogger(name: "WINDOW"))
        
        return engine
    }
    
    public func makeLogger() -> Logger {
        return macOSLoggerFactory().makeLogger(name: "")
    }
    
    private func readConfig(path: String) -> RawConfig {
        let configReader = FoundationRawConfigReader()
        
        do {
            return try configReader.read(path: path)
        }
        catch {
            logger.error("\(error)")
            return RawConfig()
        }
    }
    
    private func determineSupportedRendererTypes() -> Set<RendererType> {
        var types = Set<RendererType>()
        
        if MetalRenderer.isSupported() {
            types.insert(.metal)
        }
        
        return types
    }
}
