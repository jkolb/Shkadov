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

import FieryCrucible

public class macOSGameFactory : DependencyFactory, GameFactory {
    private let rawConfig: RawConfig
    private let supportedRendererTypes: Set<RendererType>
    
    public init(rawConfig: RawConfig, supportedRendererTypes: Set<RendererType>) {
        self.rawConfig = rawConfig
        self.supportedRendererTypes = supportedRendererTypes
    }
    
    public func game() -> Game {
        return shared(
            Game(
                platform: platform(),
                rendererFactory: macOSRendererFactory(supportedRendererTypes: supportedRendererTypes),
                paths: FoundationFilePaths(applicationName: FoundationApplicationNameProvider().applicationName),
                rawConfig: rawConfig,
                configWriter: FoundationRawConfigWriter(),
                logger: makeLogger(level: .debug)
            )
        )
    }
    
    private func engine() -> Engine {
        return scoped(
            Engine(
                timeSource: MachOTimeSource(),
                logger: makeLogger(level: .debug)
            )
        )
    }
    
    private func platform() -> macOSPlatform {
        return shared(
            macOSPlatform(
                logger: makeLogger(level: .debug)
            ),
            configure: { (instance) in
                instance.delegate = self.game()
            }
        )
    }
    
    private func makeLogger(level: LogLevel) -> Logger {
        let logger = Logger(
            applicationNameProvider: FoundationApplicationNameProvider(),
            threadIDProvider: POSIXThreadIDProvider(),
            formattedTimestampProvider: FoundationFormattedTimestampProvider(),
            pathSeparator: "/"
        )
        logger.level = level
        return logger
    }
}
