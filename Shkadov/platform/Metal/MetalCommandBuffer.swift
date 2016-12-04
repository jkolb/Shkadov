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

public final class MetalCommandBuffer : CommandBuffer {
    public let instance: MTLCommandBuffer
    private unowned(unsafe) let bufferOwner: MetalGPUBufferOwner
    private unowned(unsafe) let textureOwner: MetalTextureOwner
    private unowned(unsafe) let samplerOwner: MetalSamplerOwner
    private unowned(unsafe) let renderPipelineStateOwner: MetalRenderPipelineStateOwner
    private unowned(unsafe) let rasterizerStateOwner: MetalRasterizerStateOwner

    public init(instance: MTLCommandBuffer, bufferOwner: MetalGPUBufferOwner, textureOwner: MetalTextureOwner, samplerOwner: MetalSamplerOwner, renderPipelineStateOwner: MetalRenderPipelineStateOwner, rasterizerStateOwner: MetalRasterizerStateOwner) {
        self.instance = instance
        self.bufferOwner = bufferOwner
        self.textureOwner = textureOwner
        self.samplerOwner = samplerOwner
        self.renderPipelineStateOwner = renderPipelineStateOwner
        self.rasterizerStateOwner = rasterizerStateOwner
    }
    
    public func makeRenderCommandEncoder(descriptor renderPassDescriptor: RenderPassDescriptor) -> RenderCommandEncoder {
        if let metalDescriptor = renderPassDescriptor as? MetalRenderPassDescriptor {
            let metalRenderCommandEncoder = instance.makeRenderCommandEncoder(descriptor: metalDescriptor.metalRenderPassDescriptor)
            return MetalRenderCommandEncoder(instance: metalRenderCommandEncoder, bufferOwner: bufferOwner, textureOwner: textureOwner, samplerOwner: samplerOwner, renderPipelineStateOwner: renderPipelineStateOwner, rasterizerStateOwner: rasterizerStateOwner)
        }
        else {
            fatalError("Unexpected implementation: \(renderPassDescriptor)")
        }
    }
    
    public func addCompletedHandler(_ block: @escaping (CommandBuffer) -> Void) {
        instance.addCompletedHandler { (metalCommandBuffer) in
            block(self)
        }
    }
    
    public func commit() {
        instance.commit()
    }
}
