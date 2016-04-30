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

public class MetalRenderStateBuilder : RenderStateBuilder {
    private let metalDevice: MTLDevice
    private let metalView: MTKView

    public init(metalDevice: MTLDevice, metalView: MTKView) {
        self.metalDevice = metalDevice
        self.metalView = metalView
    }
    
    public func renderPipelineForDescriptor(desciptor: RenderPipelineDescriptor) -> RenderPipeline {
        let renderPipelineDescriptor = map(desciptor)
        let renderPipelineState = try! metalDevice.newRenderPipelineStateWithDescriptor(renderPipelineDescriptor)
        return MetalRenderPipeline(renderPipelineState: renderPipelineState)
    }
    
    private func map(desciptor: RenderPipelineDescriptor) -> MTLRenderPipelineDescriptor {
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        
        if let vertexDescriptor = desciptor.vertexDescriptor {
            renderPipelineDescriptor.vertexDescriptor = MetalVertexDescriptorMapper.map(vertexDescriptor)
        }
        
        renderPipelineDescriptor.sampleCount = metalView.sampleCount
        renderPipelineDescriptor.vertexFunction = desciptor.vertexShader.downCast(MTLFunction)
        renderPipelineDescriptor.fragmentFunction = desciptor.fragmentShader.downCast(MTLFunction)
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = metalView.depthStencilPixelFormat
        renderPipelineDescriptor.stencilAttachmentPixelFormat = .Invalid //metalView.depthStencilPixelFormat
        return renderPipelineDescriptor
    }
    
    public func rasterizationStateForDescriptor(descriptor: RasterizationStateDescriptor) -> RasterizationState {
        return MetalRasterizationState(rasterizationStateDescriptor: descriptor)
    }
    
    public func samplerForDescriptor(descriptor: SamplerDescriptor) -> Sampler {
        let metalSamplerDescriptor = MTLSamplerDescriptor()
        metalSamplerDescriptor.minFilter = MetalSamplerMinMagFilterMapper.map(descriptor.minFilter)
        metalSamplerDescriptor.magFilter = MetalSamplerMinMagFilterMapper.map(descriptor.magFilter)
        metalSamplerDescriptor.mipFilter = MetalSamplerMipFilterMapper.map(descriptor.mipFilter)
        metalSamplerDescriptor.maxAnisotropy = descriptor.maxAnisotropy
        metalSamplerDescriptor.sAddressMode = MetalSamplerAddressModeMapper.map(descriptor.sAddressMode)
        metalSamplerDescriptor.tAddressMode = MetalSamplerAddressModeMapper.map(descriptor.tAddressMode)
        metalSamplerDescriptor.rAddressMode = MetalSamplerAddressModeMapper.map(descriptor.rAddressMode)
        metalSamplerDescriptor.normalizedCoordinates = descriptor.normalizedCoordinates
        metalSamplerDescriptor.lodMinClamp = descriptor.lodMinClamp
        metalSamplerDescriptor.lodMaxClamp = descriptor.lodMaxClamp
        metalSamplerDescriptor.compareFunction = MetalCompareFunctionMapper.map(descriptor.compareFunction)
        let metalSamplerState = metalDevice.newSamplerStateWithDescriptor(metalSamplerDescriptor)
        return MetalSampler(samplerState: metalSamplerState)
    }
}
