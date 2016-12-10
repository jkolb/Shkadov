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
    private let samplerOwner: MetalSamplerOwner
    private let renderPipelineStateOwner: MetalRenderPipelineStateOwner
    private let rasterizerStateOwner: MetalRasterizerStateOwner
    private let depthStencilStateOwner: MetalDepthStencilStateOwner
    private let renderPassOwner: MetalRenderPassOwner
    private let swapChain: MetalSwapChain
    
    public init(view: MetalView, config: RendererConfig, logger: Logger) {
        self.device = view.device!
        self.view = view
        self.config = config
        self.logger = logger
        self.semaphore = DispatchSemaphore(value: 3)
        self.bufferOwner = MetalGPUBufferOwner(device: device)
        self.moduleOwner = MetalModuleOwner(device: device)
        self.textureOwner = MetalTextureOwner(device: device, view: view)
        self.samplerOwner = MetalSamplerOwner(device: device)
        self.renderPipelineStateOwner = MetalRenderPipelineStateOwner(device: device, moduleOwner: moduleOwner)
        self.rasterizerStateOwner = MetalRasterizerStateOwner()
        self.depthStencilStateOwner = MetalDepthStencilStateOwner(device: device)
        self.renderPassOwner = MetalRenderPassOwner(textureOwner: textureOwner, bufferOwner: bufferOwner)
        self.swapChain = MetalSwapChain(view: view, textureOwner: textureOwner)
        
        view.drawableSize = CGSize(width: config.width, height: config.height)
    }
    
    public static func isSupported() -> Bool {
        if let _ = MTLCreateSystemDefaultDevice() {
            return true
        }
        
        return false
    }

    public func makeCommandQueue() -> CommandQueue {
        return MetalCommandQueue(instance: device.makeCommandQueue(), bufferOwner: bufferOwner, textureOwner: textureOwner, samplerOwner: samplerOwner, renderPipelineStateOwner: renderPipelineStateOwner, rasterizerStateOwner: rasterizerStateOwner, depthStencilStateOwner: depthStencilStateOwner, renderPassOwner: renderPassOwner)
    }
    
    public func acquireNextRenderTarget() -> RenderTargetHandle {
        return swapChain.acquireNextRenderTarget()
    }
    
    public func textureForRenderTarget(handle: RenderTargetHandle) -> TextureHandle {
        return swapChain.textureForRenderTarget(handle: handle)
    }
    
    public func releaseRenderTarget(handle: RenderTargetHandle) {
        return swapChain.releaseRenderTarget(handle: handle)
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
    
    public func createSampler(descriptor: SamplerDescriptor) -> SamplerHandle {
        return samplerOwner.createSampler(descriptor: descriptor)
    }
    
    public func destroySampler(handle: SamplerHandle) {
        samplerOwner.destroySampler(handle: handle)
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
    
    public func createRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineStateHandle {
        return try renderPipelineStateOwner.createRenderPipelineState(descriptor: descriptor)
    }
    
    public func destroyRenderPipelineState(handle: RenderPipelineStateHandle) {
        renderPipelineStateOwner.destroyRenderPipelineState(handle: handle)
    }
    
    public func createRasterizerState(descriptor: RasterizerStateDescriptor) -> RasterizerStateHandle {
        return rasterizerStateOwner.createRasterizerState(descriptor: descriptor)
    }
    
    public func destroyRasterizerState(handle: RasterizerStateHandle) {
        rasterizerStateOwner.destroyRasterizerState(handle: handle)
    }

    public func createRenderPass(descriptor: RenderPassDescriptor) -> RenderPassHandle {
        return renderPassOwner.createRenderPass(descriptor: descriptor)
    }
    
    public func destroyRenderPass(handle: RenderPassHandle) {
        renderPassOwner.destroyRenderPass(handle: handle)
    }

    public func createDepthStencilState(descriptor: DepthStencilDescriptor) -> DepthStencilStateHandle {
        return depthStencilStateOwner.createDepthStencilState(descriptor: descriptor)
    }
    
    public func destroyDepthStencilState(handle: DepthStencilStateHandle) {
        depthStencilStateOwner.destroyDepthStencilState(handle: handle)
    }

    public func waitForGPUIfNeeded() {
        semaphore.wait()
    }

    public func present(commandBuffer: CommandBuffer, renderTarget: RenderTargetHandle) {
        let metalCommandBuffer = commandBuffer as! MetalCommandBuffer
        let semaphore = self.semaphore

        metalCommandBuffer.instance.addCompletedHandler { (commandBuffer) in
            semaphore.signal()
        }

        if renderTarget.isValid {
            metalCommandBuffer.instance.present(swapChain[renderTarget])
        }
        
        swapChain.releaseRenderTarget(handle: renderTarget)
    }
}
