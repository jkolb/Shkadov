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

public final class MetalRenderPipelineStateOwner : RenderPipelineStateOwner {
    private unowned(unsafe) let device: MTLDevice
    private unowned(unsafe) let moduleOwner: MetalModuleOwner
    private var pipelineStates: [MTLRenderPipelineState?]
    
    public init(device: MTLDevice, moduleOwner: MetalModuleOwner) {
        self.device = device
        self.moduleOwner = moduleOwner
        self.pipelineStates = []
        
        pipelineStates.reserveCapacity(16)
    }
    
    public func createRenderPipelineState(descriptor: RenderPipelineDescriptor) throws -> RenderPipelineStateHandle {
        pipelineStates.append(try device.makeRenderPipelineState(descriptor: map(descriptor)))
        return RenderPipelineStateHandle(key: UInt8(pipelineStates.count))
    }
    
    public func destroyRenderPipelineState(handle: RenderPipelineStateHandle) {
        pipelineStates[handle.index] = nil
    }
    
    internal subscript (handle: RenderPipelineStateHandle) -> MTLRenderPipelineState {
        return pipelineStates[handle.index]!
    }
    
    private func map(_ descriptor: RenderPipelineDescriptor) -> MTLRenderPipelineDescriptor {
        let metalDescriptor = MTLRenderPipelineDescriptor()
        
        metalDescriptor.sampleCount = descriptor.sampleCount
        metalDescriptor.isRasterizationEnabled = descriptor.isRasterizationEnabled
        
        if descriptor.vertexShader.isValid {
            metalDescriptor.vertexFunction = moduleOwner[descriptor.vertexShader]
        }
        
        if descriptor.fragmentShader.isValid {
            metalDescriptor.fragmentFunction = moduleOwner[descriptor.fragmentShader]
        }
        
        for (index, colorAttachmentDescriptor) in descriptor.colorAttachments.enumerated() {
            map(colorAttachmentDescriptor, to: metalDescriptor.colorAttachments[index])
        }
        
        metalDescriptor.depthAttachmentPixelFormat = MetalDataTypes.map(descriptor.depthAttachmentPixelFormat)
        metalDescriptor.stencilAttachmentPixelFormat = MetalDataTypes.map(descriptor.stencilAttachmentPixelFormat)
        return metalDescriptor
    }
    
    private func map(_ descriptor: RenderPipelineColorAttachmentDescriptor, to metalDescriptor: MTLRenderPipelineColorAttachmentDescriptor) {
        metalDescriptor.pixelFormat = MetalDataTypes.map(descriptor.pixelFormat)
        metalDescriptor.isBlendingEnabled = descriptor.isBlendingEnabled
        metalDescriptor.sourceRGBBlendFactor = MetalDataTypes.map(descriptor.sourceRGBBlendFactor)
        metalDescriptor.destinationRGBBlendFactor = MetalDataTypes.map(descriptor.destinationRGBBlendFactor)
        metalDescriptor.rgbBlendOperation = MetalDataTypes.map(descriptor.rgbBlendOperation)
        metalDescriptor.sourceAlphaBlendFactor = MetalDataTypes.map(descriptor.sourceAlphaBlendFactor)
        metalDescriptor.destinationAlphaBlendFactor = MetalDataTypes.map(descriptor.destinationAlphaBlendFactor)
        metalDescriptor.alphaBlendOperation = MetalDataTypes.map(descriptor.alphaBlendOperation)
    }
}
