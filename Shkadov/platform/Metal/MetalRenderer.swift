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

import Metal
import MetalKit
import Dispatch

public final class MetalRenderer : Renderer {
    private let device: MTLDevice
    private let view: MetalView
    private let config: RendererConfig
    private let logger: Logger
    private let semaphore: DispatchSemaphore
    private let bufferOwner: MetalGPUBufferOwner
    private let moduleOwner: MetalModuleOwner
    private let textureOwner: MetalTextureOwner
    
    public init(view: MetalView, config: RendererConfig, logger: Logger) {
        self.device = view.device!
        self.view = view
        self.config = config
        self.logger = logger
        self.semaphore = DispatchSemaphore(value: 3)
        self.bufferOwner = MetalGPUBufferOwner(device: device)
        self.moduleOwner = MetalModuleOwner(device: device)
        self.textureOwner = MetalTextureOwner(device: device)
        
        view.drawableSize = CGSize(width: config.width, height: config.height)
    }
    
    public static func isSupported() -> Bool {
        if let _ = MTLCreateSystemDefaultDevice() {
            return true
        }
        
        return false
    }
    
    public func makeCommandQueue() -> CommandQueue {
        return MetalCommandQueue(instance: device.makeCommandQueue(), bufferOwner: bufferOwner, textureOwner: textureOwner)
    }
    
    public func createBuffer(count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        return bufferOwner.createBuffer(count: count, storageMode: storageMode)
    }
    
    public func createBuffer(bytes: UnsafeRawPointer, count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        return bufferOwner.createBuffer(bytes: bytes, count: count, storageMode: storageMode)
    }
    
    public func createBuffer(bytesNoCopy: UnsafeMutableRawPointer, count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        return bufferOwner.createBuffer(bytesNoCopy: bytesNoCopy, count: count, storageMode: storageMode)
    }
    
    public func borrowBuffer(handle: GPUBufferHandle) -> GPUBuffer {
        return bufferOwner.borrowBuffer(handle: handle)
    }
    
    public func destroyBuffer(handle: GPUBufferHandle) {
        bufferOwner.destroyBuffer(handle: handle)
    }
    
    public func createTexture(descriptor: TextureDescriptor) -> TextureHandle {
        return textureOwner.createTexture(descriptor: descriptor)
    }
    
    public func borrowTexture(handle: TextureHandle) -> Texture {
        return textureOwner.borrowTexture(handle: handle)
    }
    
    public func generateMipmaps(handles: [TextureHandle]) {
        return textureOwner.generateMipmaps(handles: handles)
    }
    
    public func destroyTexture(handle: TextureHandle) {
        return textureOwner.destroyTexture(handle: handle)
    }
    
    public func makeSampler(descriptor: SamplerDescriptor) -> Sampler {
        let metalDescriptor = MetalSamplerDescriptor.map(descriptor)
        let metalSampler = device.makeSamplerState(descriptor: metalDescriptor)
        return MetalSampler(instance: metalSampler)
    }
    
    public func createModule(filepath: String) throws -> ModuleHandle {
        return try moduleOwner.createModule(filepath: filepath)
    }
    
    public func destroyModule(handle: ModuleHandle) {
        moduleOwner.destroyModule(handle: handle)
    }
    
    public func createComputeFunction(module: ModuleHandle, named: String) -> ComputeFunctionHandle {
        return moduleOwner.createComputeFunction(module: module, named: named)
    }
    
    public func destroyComputeFunction(handle: ComputeFunctionHandle) {
        moduleOwner.destroyComputeFunction(handle: handle)
    }
    
    public func createFragmentFunction(module: ModuleHandle, named: String) -> FragmentFunctionHandle {
        return moduleOwner.createFragmentFunction(module: module, named: named)
    }
    
    public func destroyFragmentFunction(handle: FragmentFunctionHandle) {
        moduleOwner.destroyFragmentFunction(handle: handle)
    }
    
    public func createVertexFunction(module: ModuleHandle, named: String) -> VertexFunctionHandle {
        return moduleOwner.createVertexFunction(module: module, named: named)
    }
    
    public func destroyVertexFunction(handle: VertexFunctionHandle) {
        moduleOwner.destroyVertexFunction(handle: handle)
    }
    
    public func makeRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineState {
        let metalDescriptor = MetalRenderPipelineDescriptor.map(descriptor, moduleOwner: moduleOwner)
        let metalRenderPipelineState = try device.makeRenderPipelineState(descriptor: metalDescriptor)
        return MetalRenderPipelineState(instance: metalRenderPipelineState)
    }
    
    public func waitForGPUIfNeeded() {
        semaphore.wait()
    }

    public func present(commandBuffer: CommandBuffer) {
        guard let metalCommandBuffer = commandBuffer as? MetalCommandBuffer else { return }
        let semaphore = self.semaphore

        metalCommandBuffer.instance.addCompletedHandler { (commandBuffer) in
            semaphore.signal()
        }

        if let drawable = view.currentDrawable {
            metalCommandBuffer.instance.present(drawable)
        }
    }
}
