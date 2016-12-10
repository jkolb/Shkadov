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
    private unowned(unsafe) let depthStencilStateOwner: MetalDepthStencilStateOwner
    private unowned(unsafe) let renderPassOwner: MetalRenderPassOwner
    
    public init(instance: MTLCommandBuffer, bufferOwner: MetalGPUBufferOwner, textureOwner: MetalTextureOwner, samplerOwner: MetalSamplerOwner, renderPipelineStateOwner: MetalRenderPipelineStateOwner, rasterizerStateOwner: MetalRasterizerStateOwner, depthStencilStateOwner: MetalDepthStencilStateOwner, renderPassOwner: MetalRenderPassOwner) {
        self.instance = instance
        self.bufferOwner = bufferOwner
        self.textureOwner = textureOwner
        self.samplerOwner = samplerOwner
        self.renderPipelineStateOwner = renderPipelineStateOwner
        self.rasterizerStateOwner = rasterizerStateOwner
        self.depthStencilStateOwner = depthStencilStateOwner
        self.renderPassOwner = renderPassOwner
    }
    
    public func makeRenderCommandEncoder(handle: RenderPassHandle, framebuffer: Framebuffer) -> RenderCommandEncoder {
        let renderPass = renderPassOwner[handle]
        
        for (index, attachment) in framebuffer.colorAttachments.enumerated() {
            if attachment.render.isValid {
                renderPass.colorAttachments[index].texture = textureOwner[attachment.render]
            }
            
            if attachment.resolve.isValid {
                renderPass.colorAttachments[index].resolveTexture = textureOwner[attachment.resolve]
            }
        }

        if framebuffer.depthAttachment.render.isValid {
            renderPass.depthAttachment.texture = textureOwner[framebuffer.depthAttachment.render]
        }
        
        if framebuffer.depthAttachment.resolve.isValid {
            renderPass.depthAttachment.resolveTexture = textureOwner[framebuffer.depthAttachment.resolve]
        }
        
        if framebuffer.stencilAttachment.render.isValid {
            renderPass.stencilAttachment.texture = textureOwner[framebuffer.stencilAttachment.render]
        }
        
        if framebuffer.stencilAttachment.resolve.isValid {
            renderPass.stencilAttachment.resolveTexture = textureOwner[framebuffer.stencilAttachment.resolve]
        }
        
        if framebuffer.visibilityResultBuffer.isValid {
            renderPass.visibilityResultBuffer = bufferOwner[framebuffer.visibilityResultBuffer]
        }

        return MetalRenderCommandEncoder(instance: instance.makeRenderCommandEncoder(descriptor: renderPassOwner[handle]), bufferOwner: bufferOwner, textureOwner: textureOwner, samplerOwner: samplerOwner, renderPipelineStateOwner: renderPipelineStateOwner, rasterizerStateOwner: rasterizerStateOwner, depthStencilStateOwner: depthStencilStateOwner)
    }
    
    public func addCompletedHandler(_ block: @escaping (CommandBuffer) -> Void) {
        instance.addCompletedHandler { (metalCommandBuffer) in
            block(self)
        }
    }
    
    public func enqueue() {
        instance.enqueue()
    }

    public func commit() {
        instance.commit()
    }
}
