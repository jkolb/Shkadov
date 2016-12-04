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

import Swiftish

public final class Engine {
    public static let minimumWidth = 640
    public static let minimumHeight = 360
    public var listener: EngineListener?
    
    private let rawConfig: RawConfig
    private let config: EngineConfig
    private let platform: Platform
    private let timeSource: TimeSource
    private let renderer: Renderer
    private let mouseCursor: MouseCursor
    private let logger: Logger
    private let configWriter: RawConfigWriter
    
    public init(rawConfig: RawConfig, config: EngineConfig, platform: Platform, timeSource: TimeSource, renderer: Renderer, mouseCursor: MouseCursor, logger: Logger, configWriter: RawConfigWriter) {
        self.rawConfig = rawConfig
        self.config = config
        self.platform = platform
        self.timeSource = timeSource
        self.renderer = renderer
        self.mouseCursor = mouseCursor
        self.logger = logger
        self.configWriter = configWriter
    }
    
    public var screensSize: Vector2<Int> {
        return platform.screensSize
    }

    public var isFullScreen: Bool {
        return platform.isFullScreen
    }
    
    public func toggleFullScreen() {
        platform.toggleFullScreen()
    }
    
    public func enterFullScreen() {
        platform.enterFullScreen()
    }
    
    public func exitFullScreen() {
        platform.exitFullScreen()
    }
    
    public func startup() {
        logger.debug("\(#function)")
        platform.startup()
    }
    
    public func shutdown() {
        logger.debug("\(#function)")
        platform.shutdown()
    }
    
    public func writeConfig() throws {
        logger.debug("\(#function)")
        try configWriter.write(config: rawConfig, path: config.paths.configPath)
    }
    
    public var currentTime: Time {
        return timeSource.currentTime
    }
    
    public var mouseCursorHidden: Bool {
        get {
            return mouseCursor.hidden
        }
        set {
            mouseCursor.hidden = newValue
        }
    }
    
    public var mouseCursorFollowsMouse: Bool {
        get {
            return mouseCursor.followsMouse
        }
        set {
            mouseCursor.followsMouse = newValue
        }
    }
    
    public func moveMouseCursor(to point: Vector2<Float>) {
        mouseCursor.move(to: point)
    }

    public func makeCommandQueue() -> CommandQueue {
        return renderer.makeCommandQueue()
    }
    
    public func makeBuffer(length: Int, options: ResourceOptions) -> GraphicsBuffer {
        return renderer.makeBuffer(length: length, options: options)
    }
    
    public func makeTexture(descriptor: TextureDescriptor) -> Texture {
        return renderer.makeTexture(descriptor: descriptor)
    }
    
    public func makeSampler(descriptor: SamplerDescriptor) -> Sampler {
        return renderer.makeSampler(descriptor: descriptor)
    }
    
    public func newDefaultLibrary() -> ShaderLibrary? {
        return renderer.newDefaultLibrary()
    }
    
    public func makeLibrary(filepath: String) throws -> ShaderLibrary {
        return try renderer.makeLibrary(filepath: filepath)
    }
    
    public func makeRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineState {
        return try renderer.makeRenderPipelineState(descriptor: descriptor)
    }
    
    public func waitForGPUIfNeeded() {
        renderer.waitForGPUIfNeeded()
    }
    
    public func present(commandBuffer: CommandBuffer) {
        renderer.present(commandBuffer: commandBuffer)
    }
}
