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

public final class MetalCommandQueue : CommandQueue {
    public let instance: MTLCommandQueue
    private unowned(unsafe) let bufferOwner: MetalGPUBufferOwner
    private unowned(unsafe) let textureOwner: MetalTextureOwner
    private unowned(unsafe) let samplerOwner: MetalSamplerOwner
    private unowned(unsafe) let renderPipelineStateOwner: MetalRenderPipelineStateOwner
    private unowned(unsafe) let rasterizerStateOwner: MetalRasterizerStateOwner
    private unowned(unsafe) let renderPassOwner: MetalRenderPassOwner
    
    public init(instance: MTLCommandQueue, bufferOwner: MetalGPUBufferOwner, textureOwner: MetalTextureOwner, samplerOwner: MetalSamplerOwner, renderPipelineStateOwner: MetalRenderPipelineStateOwner, rasterizerStateOwner: MetalRasterizerStateOwner, renderPassOwner: MetalRenderPassOwner) {
        self.instance = instance
        self.bufferOwner = bufferOwner
        self.textureOwner = textureOwner
        self.samplerOwner = samplerOwner
        self.renderPipelineStateOwner = renderPipelineStateOwner
        self.rasterizerStateOwner = rasterizerStateOwner
        self.renderPassOwner = renderPassOwner
    }
    
    public func makeCommandBuffer() -> CommandBuffer {
        return MetalCommandBuffer(instance: instance.makeCommandBuffer(), bufferOwner: bufferOwner, textureOwner: textureOwner, samplerOwner: samplerOwner, renderPipelineStateOwner: renderPipelineStateOwner, rasterizerStateOwner: rasterizerStateOwner, renderPassOwner: renderPassOwner)
    }
}
