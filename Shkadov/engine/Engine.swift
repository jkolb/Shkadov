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
    public static let minimumWidth: Int = 640
    public static let minimumHeight: Int = 360
    public static let defaultFOVY: Float = 30.0
    public var listener: EngineListener?
    
    private let rawConfig: RawConfig
    public let config: EngineConfig
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
    
    public func pathForResource(named: String) -> String {
        return config.paths.resourcesPath + named
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
    
    public func createBuffer(count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        return renderer.createBuffer(count: count, storageMode: storageMode)
    }
    
    public func createBuffer(bytes: UnsafeRawPointer, count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        return renderer.createBuffer(bytes: bytes, count: count, storageMode: storageMode)
    }
    
    public func createBuffer(bytesNoCopy: UnsafeMutableRawPointer, count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        return renderer.createBuffer(bytesNoCopy: bytesNoCopy, count: count, storageMode: storageMode)
    }
    
    public func borrowBuffer(handle: GPUBufferHandle) -> GPUBuffer {
        return renderer.borrowBuffer(handle: handle)
    }
    
    public func destroyBuffer(handle: GPUBufferHandle) {
        return renderer.destroyBuffer(handle: handle)
    }
    
    public func createModule(filepath: String) throws -> ModuleHandle {
        return try renderer.createModule(filepath: filepath)
    }
    
    public func destroyModule(handle: ModuleHandle) {
        renderer.destroyModule(handle: handle)
    }
    
    public func createComputeFunction(module: ModuleHandle, named: String) -> ComputeFunctionHandle {
        return renderer.createComputeFunction(module: module, named: named)
    }
    
    public func destroyComputeFunction(handle: ComputeFunctionHandle) {
        renderer.destroyComputeFunction(handle: handle)
    }
    
    public func createFragmentFunction(module: ModuleHandle, named: String) -> FragmentFunctionHandle {
        return renderer.createFragmentFunction(module: module, named: named)
    }
    
    public func destroyFragmentFunction(handle: FragmentFunctionHandle) {
        renderer.destroyFragmentFunction(handle: handle)
    }
    
    public func createVertexFunction(module: ModuleHandle, named: String) -> VertexFunctionHandle {
        return renderer.createVertexFunction(module: module, named: named)
    }
    
    public func destroyVertexFunction(handle: VertexFunctionHandle) {
        renderer.destroyVertexFunction(handle: handle)
    }

    public func createTexture(descriptor: TextureDescriptor) -> TextureHandle {
        return renderer.createTexture(descriptor: descriptor)
    }
    
    public func borrowTexture(handle: TextureHandle) -> Texture {
        return renderer.borrowTexture(handle: handle)
    }
    
    public func generateMipmaps(handles: [TextureHandle]) {
        renderer.generateMipmaps(handles: handles)
    }
    
    public func destroyTexture(handle: TextureHandle) {
        renderer.destroyTexture(handle: handle)
    }
    
    public func createSampler(descriptor: SamplerDescriptor) -> SamplerHandle {
        return renderer.createSampler(descriptor: descriptor)
    }
    
    public func destroySampler(handle: SamplerHandle) {
        renderer.destroySampler(handle: handle)
    }
    
    public func createRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineStateHandle {
        return try renderer.createRenderPipelineState(descriptor: descriptor)
    }
    
    public func destroyRenderPipelineState(handle: RenderPipelineStateHandle) {
        renderer.destroyRenderPipelineState(handle: handle)
    }

    public func createRasterizerState(descriptor: RasterizerStateDescriptor) -> RasterizerStateHandle {
        return renderer.createRasterizerState(descriptor: descriptor)
    }
    
    public func destroyRasterizerState(handle: RasterizerStateHandle) {
        renderer.destroyRasterizerState(handle: handle)
    }

    public func createRenderPass(descriptor: RenderPassDescriptor) -> RenderPassHandle {
        return renderer.createRenderPass(descriptor: descriptor)
    }
    
    public func destoryRenderPass(handle: RenderPassHandle) {
        return renderer.destroyRenderPass(handle: handle)
    }
    
    public func createDepthStencilState(descriptor: DepthStencilDescriptor) -> DepthStencilStateHandle {
        return renderer.createDepthStencilState(descriptor: descriptor)
    }
    
    public func destroyDepthStencilState(handle: DepthStencilStateHandle) {
        renderer.destroyDepthStencilState(handle: handle)
    }

    public func waitForGPUIfNeeded() {
        renderer.waitForGPUIfNeeded()
    }
    
    public func present(commandBuffer: CommandBuffer) {
        renderer.present(commandBuffer: commandBuffer)
    }
}
