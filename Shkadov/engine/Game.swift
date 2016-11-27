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

open class Game : PlatformDelegate, RawInputListener {
    private let platform: Platform
    private let rendererFactory: RendererFactory
    private let paths: FilePaths
    private let config: RawConfig
    private let configWriter: RawConfigWriter
    private let logger: Logger
    
    public init(platform: Platform, rendererFactory: RendererFactory, paths: FilePaths, config: RawConfig, configWriter: RawConfigWriter, logger: Logger) {
        self.platform = platform
        self.rendererFactory = rendererFactory
        self.paths = paths
        self.config = config
        self.configWriter = configWriter
        self.logger = logger
    }
    
    public func start() {
        platform.start()
    }
    
    public func platformWillTerminate(platform: Platform) {
        do {
            try configWriter.write(config: config, path: paths.configPath)
        }
        catch {
            logger.error("\(error)")
        }
    }

    public func receivedRawInput(_ rawInput: RawInput) {
        logger.trace("\(rawInput)")
    }
}
