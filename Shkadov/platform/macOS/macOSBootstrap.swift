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
                
                let inputView = self.inputView()
                let rendererView = self.renderer().rendererView
                rendererView.frame = inputView.bounds
                inputView.addSubview(rendererView)
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
        return scoped(FoundationFilePaths(applicationNameProvider: applicationNameProvider()))
    }
    
    private func rawConfig() -> RawConfig {
        return scoped(
            factory : { () -> RawConfig in
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
        return scoped(RendererConfig(rawConfig: rawConfig(), supportedRendererTypes: macOSRendererFactory.determineSupportedRendererTypes()))
    }
    
    private func windowConfig() -> WindowConfig {
        return scoped(WindowConfig(rawConfig: rawConfig(), title: applicationNameProvider().applicationName))
    }
    
    private func platform() -> Platform {
        return scoped(
            macOSPlatform(config: config().window, inputView: inputView(), logger: makeLogger()),
            configure: { (instance) in
                instance.listener = self.engineListener()
            }
        )
    }
    
    private func mouseCursor() -> MouseCursor {
        return scoped(
            macOSMouseCursor(),
            configure: { (instance) in
                instance.listener = self.inputView()
            }
        )
    }
    
    private func renderer() -> macOSRenderer {
        return scoped(
            macOSRendererFactory().makeRenderer(config: config().renderer, logger: makeLogger()),
            configure: { (instance) in
                instance.listener = self.engineListener()
            }
        )
    }
    
    private func rawConfigWriter() -> RawConfigWriter {
        return scoped(FoundationRawConfigWriter())
    }
    
    private func inputView() -> macOSInputView {
        return scoped(
            macOSInputView(frame: CGRect(x: 0, y: 0, width: Engine.minimumWidth, height: Engine.minimumHeight), logger: makeLogger()),
            configure: { (instance) in
                instance.listener = self.engineListener()
            }
        )
    }
}
