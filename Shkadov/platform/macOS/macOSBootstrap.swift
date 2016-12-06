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

public final class macOSBootstrap : DependencyFactory, Bootstrap {
    private let factory: (Engine, LoggerFactory) -> EngineListener
    
    public init(factory: @escaping (Engine, LoggerFactory) -> EngineListener) {
        self.factory = factory
    }
    
    public func makeEngine() -> Engine {
        return engine()
    }

    private func engine() -> Engine {
        return scoped(
            Engine(
                rawConfig: rawConfig(),
                config: config(),
                platform: platform(),
                timeSource: timeSource(),
                renderer: renderer(),
                mouseCursor: mouseCursor(),
                logger: makeLogger(),
                configWriter: rawConfigWriter()
            ),
            configure: { (instance) in
                instance.listener = self.engineListener()
            }
        )
    }
    
    private func engineListener() -> EngineListener {
        return scoped(
            factory: {
                factory(engine(), loggerFactory())
            }
        )
    }

    private func makeLogger() -> Logger {
        return loggerFactory().makeLogger()
    }
    
    private func loggerFactory() -> LoggerFactory {
        return scoped(
            LoggerFactory(
                applicationNameProvider: applicationNameProvider(),
                threadIDProvider: threadIDProvider(),
                formattedTimestampProvider: formattedTimestampProvider()
            )
        )
    }
    
    private func threadIDProvider() -> ThreadIDProvider {
        return scoped(POSIXThreadIDProvider())
    }
    
    private func formattedTimestampProvider() -> FormattedTimestampProvider {
        return scoped(FoundationFormattedTimestampProvider())
    }
    
    private func timeSource() -> TimeSource {
        return scoped(MachOTimeSource())
    }
    
    private func applicationNameProvider() -> ApplicationNameProvider {
        return scoped(FoundationApplicationNameProvider())
    }
    
    private func filePaths() -> FilePaths {
        return scoped(FoundationFilePaths(applicationNameProvider: applicationNameProvider(), resourceRootPath: "/Contents/Resources/"))
    }
    
    private func rawConfig() -> RawConfig {
        return scoped(
            factory: { () -> RawConfig in
                let configReader = FoundationRawConfigReader()
                
                do {
                    return try configReader.read(path: filePaths().configPath)
                }
                catch {
                    print("\(error)")
                    return RawConfig()
                }
            }
        )
    }
    
    private func config() -> EngineConfig {
        return scoped(EngineConfig(rawConfig: rawConfig(), paths: filePaths(), renderer: rendererConfig(), window: windowConfig()))
    }
    
    private func rendererConfig() -> RendererConfig {
        return scoped(RendererConfig(rawConfig: rawConfig(), availableRendererTypes: availableRendererTypes()))
    }
    
    private func windowConfig() -> WindowConfig {
        return scoped(WindowConfig(rawConfig: rawConfig(), title: applicationNameProvider().applicationName))
    }
    
    private func platform() -> Platform {
        return scoped(
            macOSPlatform(config: config().window, contentView: contentView(), logger: makeLogger()),
            configure: { (instance) in
                instance.listener = self.engineListener()
            }
        )
    }
    
    private func mouseCursor() -> MouseCursor {
        return scoped(
            macOSMouseCursor(),
            configure: { (instance) in
                instance.listener = self.contentView()
            }
        )
    }
    
    private func renderer() -> Renderer {
        return scoped(
            factory: { () -> Renderer in
                let config = rendererConfig()
                let rendererTypes = availableRendererTypes()
                
                if !rendererTypes.contains(config.type) {
                    fatalError("\(config.type) renderer not available")
                }
                
                switch config.type {
                case .metal:
                    return MetalRenderer(view: metalView(), config: config, logger: makeLogger())
                default:
                    fatalError("\(config.type) renderer not supported")
                }
            }
        )
    }
    
    private func metalView() -> MetalView {
        return scoped(
            MetalView.make(),
            configure: { (instance) in
                instance.listener = self.engineListener()
                
                let parentView = self.contentView()
                instance.frame = parentView.bounds
                parentView.addSubview(instance)
            }
        )
    }
    
    private func rawConfigWriter() -> RawConfigWriter {
        return scoped(FoundationRawConfigWriter())
    }
    
    private func contentView() -> macOSInputView {
        return scoped(
            macOSInputView(frame: CGRect.engineMinimum, logger: makeLogger()),
            configure: { (instance) in
                instance.listener = self.engineListener()
            }
        )
    }
    
    private func availableRendererTypes() -> Set<RendererType> {
        return scoped(
            factory: { () -> Set<RendererType> in
                var types = Set<RendererType>()
                
                if MetalRenderer.isSupported() {
                    types.insert(.metal)
                }
                
                return types
            }
        )
    }
}
