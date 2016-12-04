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

public final class MetalRenderPipelineDescriptor {
    public static func map(_ descriptor: RenderPipelineDescriptor) -> MTLRenderPipelineDescriptor {
        let metalDescriptor = MTLRenderPipelineDescriptor()
        
        metalDescriptor.sampleCount = descriptor.sampleCount
        metalDescriptor.isRasterizationEnabled = descriptor.isRasterizationEnabled
        
        if let metalShaderFunction = descriptor.vertexShader as? MetalShaderFunction {
            metalDescriptor.vertexFunction = metalShaderFunction.metalFunction
        }
        
        if let metalShaderFunction = descriptor.fragmentShader as? MetalShaderFunction {
            metalDescriptor.fragmentFunction = metalShaderFunction.metalFunction
        }
        
        for (index, colorAttachmentDescriptor) in descriptor.colorAttachments.enumerated() {
            MetalRenderPipelineColorAttachmentDescriptor.map(colorAttachmentDescriptor, to: metalDescriptor.colorAttachments[index])
        }

        metalDescriptor.depthAttachmentPixelFormat = MetalPixelFormat.map(descriptor.depthAttachmentPixelFormat)
        metalDescriptor.stencilAttachmentPixelFormat = MetalPixelFormat.map(descriptor.stencilAttachmentPixelFormat)
        return metalDescriptor
    }
}