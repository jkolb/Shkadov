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

public final class MetalRenderCommandEncoder : RenderCommandEncoder {
    public let instance: MTLRenderCommandEncoder
    private unowned(unsafe) let bufferOwner: MetalGPUBufferOwner
    private unowned(unsafe) let textureOwner: MetalTextureOwner
    private unowned(unsafe) let samplerOwner: MetalSamplerOwner
    private unowned(unsafe) let renderPipelineStateOwner: MetalRenderPipelineStateOwner
    private unowned(unsafe) let rasterizerStateOwner: MetalRasterizerStateOwner
    private unowned(unsafe) let depthStencilStateOwner: MetalDepthStencilStateOwner
    private var lastRenderPipelineState: RenderPipelineStateHandle
    private var lastRasterizerState: RasterizerStateHandle
    private var lastDepthStencilState: DepthStencilStateHandle
    
    public init(instance: MTLRenderCommandEncoder, bufferOwner: MetalGPUBufferOwner, textureOwner: MetalTextureOwner, samplerOwner: MetalSamplerOwner, renderPipelineStateOwner: MetalRenderPipelineStateOwner, rasterizerStateOwner: MetalRasterizerStateOwner, depthStencilStateOwner: MetalDepthStencilStateOwner) {
        self.instance = instance
        self.bufferOwner = bufferOwner
        self.textureOwner = textureOwner
        self.samplerOwner = samplerOwner
        self.renderPipelineStateOwner = renderPipelineStateOwner
        self.rasterizerStateOwner = rasterizerStateOwner
        self.depthStencilStateOwner = depthStencilStateOwner
        self.lastRenderPipelineState = RenderPipelineStateHandle()
        self.lastRasterizerState = RasterizerStateHandle()
        self.lastDepthStencilState = DepthStencilStateHandle()
    }
    
    public func endEncoding() {
        instance.endEncoding()
    }
    
    public func setRenderPipelineState(_ handle: RenderPipelineStateHandle) {
        if handle == lastRenderPipelineState { return }
        
        lastRenderPipelineState = handle
        
        if !handle.isValid { return }
        
        instance.setRenderPipelineState(renderPipelineStateOwner[handle])
    }
    
    public func setRasterizerState(_ handle: RasterizerStateHandle) {
        if handle == lastRasterizerState { return }
        
        lastRasterizerState = handle
        
        if !handle.isValid { return }
        
        let descriptor = rasterizerStateOwner[handle]

        if let viewport = descriptor.viewport {
            instance.setViewport(MetalDataTypes.map(viewport))
        }
        
        if let scissorRect = descriptor.scissorRect {
            instance.setScissorRect(MetalDataTypes.map(scissorRect))
        }

        instance.setFrontFacing(MetalDataTypes.map(descriptor.frontFaceWinding))
        instance.setCullMode(MetalDataTypes.map(descriptor.cullMode))
        instance.setDepthClipMode(MetalDataTypes.map(descriptor.depthClipMode))
        instance.setTriangleFillMode(MetalDataTypes.map(descriptor.fillMode))
    }
    
    public func setDepthStencilState(_ handle: DepthStencilStateHandle) {
        if handle == lastDepthStencilState { return }
        
        lastDepthStencilState = handle
        
        if !handle.isValid { return }
        
        let state = depthStencilStateOwner[handle]
        
        instance.setDepthStencilState(state)
    }

    public func setVertexBytes(_ bytes: UnsafeRawPointer, length: Int, at index: Int) {
        instance.setVertexBytes(bytes, length: length, at: index)
    }
    
    public func setVertexBuffer(_ handle: GPUBufferHandle, offset: Int, at index: Int) {
        if handle.isValid {
            instance.setVertexBuffer(bufferOwner[handle], offset: offset, at: index)
        }
        else {
            instance.setVertexBuffer(nil, offset: offset, at: index)
        }
    }
    
    public func setVertexBufferOffset(_ offset: Int, at index: Int) {
        instance.setVertexBufferOffset(offset, at: index)
    }
    
    public func setVertexBuffers(_ handles: [GPUBufferHandle], offsets: [Int], with range: Range<Int>) {
        let metalBuffers = handles.map { (handle) -> MTLBuffer? in
            if handle.isValid {
                return bufferOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setVertexBuffers(metalBuffers, offsets: offsets, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setVertexTexture(_ handle: TextureHandle, at index: Int) {
        if handle.isValid {
            instance.setVertexTexture(textureOwner[handle], at: index)
        }
        else {
            instance.setVertexTexture(nil, at: index)
        }
    }
    
    public func setVertexTextures(_ handles: [TextureHandle], with range: Range<Int>) {
        let metalTextures = handles.map { (handle) -> MTLTexture? in
            if handle.isValid {
                return textureOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setVertexTextures(metalTextures, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setVertexSampler(_ handle: SamplerHandle, at index: Int) {
        if handle.isValid {
            instance.setVertexSamplerState(samplerOwner[handle], at: index)
        }
        else {
            instance.setVertexSamplerState(nil, at: index)
        }
    }
    
    public func setVertexSamplers(_ handles: [SamplerHandle], with range: Range<Int>) {
        let metalSamplers = handles.map { (handle) -> MTLSamplerState? in
            if handle.isValid {
                return samplerOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setVertexSamplerStates(metalSamplers, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setVertexSampler(_ handle: SamplerHandle, lodMinClamp: Float, lodMaxClamp: Float, at index: Int) {
        if handle.isValid {
            instance.setVertexSamplerState(samplerOwner[handle], lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
        else {
            instance.setVertexSamplerState(nil, lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
    }
    
    public func setVertexSamplers(_ handles: [SamplerHandle], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>) {
        let metalSamplers = handles.map { (handle) -> MTLSamplerState? in
            if handle.isValid {
                return samplerOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setVertexSamplerStates(metalSamplers, lodMinClamps: lodMinClamps, lodMaxClamps: lodMaxClamps, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setFragmentBytes(_ bytes: UnsafeRawPointer, length: Int, at index: Int) {
        instance.setFragmentBytes(bytes, length: length, at: index)
    }
    
    public func setFragmentBuffer(_ handle: GPUBufferHandle, offset: Int, at index: Int) {
        if handle.isValid {
            instance.setFragmentBuffer(bufferOwner[handle], offset: offset, at: index)
        }
        else {
            instance.setFragmentBuffer(nil, offset: offset, at: index)
        }
    }
    
    public func setFragmentBufferOffset(_ offset: Int, at index: Int) {
        instance.setFragmentBufferOffset(offset, at: index)
    }
    
    public func setFragmentBuffers(_ handles: [GPUBufferHandle], offsets: [Int], with range: Range<Int>) {
        let metalBuffers = handles.map { (handle) -> MTLBuffer? in
            if handle.isValid {
                return bufferOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setFragmentBuffers(metalBuffers, offsets: offsets, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setFragmentTexture(_ handle: TextureHandle, at index: Int) {
        if handle.isValid {
            instance.setFragmentTexture(textureOwner[handle], at: index)
        }
        else {
            instance.setFragmentTexture(nil, at: index)
        }
    }
    
    public func setFragmentTextures(_ handles: [TextureHandle], with range: Range<Int>) {
        let metalTextures = handles.map { (handle) -> MTLTexture? in
            if handle.isValid {
                return textureOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setFragmentTextures(metalTextures, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setFragmentSampler(_ handle: SamplerHandle, at index: Int) {
        if handle.isValid {
            instance.setFragmentSamplerState(samplerOwner[handle], at: index)
        }
        else {
            instance.setFragmentSamplerState(nil, at: index)
        }
    }
    
    public func setFragmentSamplers(_ handles: [SamplerHandle], with range: Range<Int>) {
        let metalSamplers = handles.map { (handle) -> MTLSamplerState? in
            if handle.isValid {
                return samplerOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setFragmentSamplerStates(metalSamplers, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setFragmentSampler(_ handle: SamplerHandle, lodMinClamp: Float, lodMaxClamp: Float, at index: Int) {
        if handle.isValid {
            instance.setFragmentSamplerState(samplerOwner[handle], lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
        else {
            instance.setFragmentSamplerState(nil, lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
    }
    
    public func setFragmentSamplers(_ handles: [SamplerHandle], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>) {
        let metalSamplers = handles.map { (handle) -> MTLSamplerState? in
            if handle.isValid {
                return samplerOwner[handle]
            }
            else {
                return nil
            }
        }
        instance.setFragmentSamplerStates(metalSamplers, lodMinClamps: lodMinClamps, lodMaxClamps: lodMaxClamps, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int) {
        instance.drawPrimitives(type: MetalDataTypes.map(primitiveType), vertexStart: vertexStart, vertexCount: vertexCount, instanceCount: instanceCount)
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int) {
        instance.drawPrimitives(type: MetalDataTypes.map(primitiveType), vertexStart: vertexStart, vertexCount: vertexCount)
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int, instanceCount: Int) {
        instance.drawIndexedPrimitives(type: MetalDataTypes.map(primitiveType), indexCount: indexCount, indexType: MetalDataTypes.map(indexType), indexBuffer: bufferOwner[indexBuffer], indexBufferOffset: indexBufferOffset, instanceCount: instanceCount)
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int) {
        instance.drawIndexedPrimitives(type: MetalDataTypes.map(primitiveType), indexCount: indexCount, indexType: MetalDataTypes.map(indexType), indexBuffer: bufferOwner[indexBuffer], indexBufferOffset: indexBufferOffset)
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int, baseInstance: Int) {
        instance.drawPrimitives(type: MetalDataTypes.map(primitiveType), vertexStart: vertexStart, vertexCount: vertexCount, instanceCount: instanceCount, baseInstance: baseInstance)
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int, instanceCount: Int, baseVertex: Int, baseInstance: Int) {
        instance.drawIndexedPrimitives(type: MetalDataTypes.map(primitiveType), indexCount: indexCount, indexType: MetalDataTypes.map(indexType), indexBuffer: bufferOwner[indexBuffer], indexBufferOffset: indexBufferOffset, instanceCount: instanceCount, baseVertex: baseVertex, baseInstance: baseInstance)
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, indirectBuffer: GPUBufferHandle, indirectBufferOffset: Int) {
        instance.drawPrimitives(type: MetalDataTypes.map(primitiveType), indirectBuffer: bufferOwner[indirectBuffer], indirectBufferOffset: indirectBufferOffset)
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int, indirectBuffer: GPUBufferHandle, indirectBufferOffset: Int) {
        instance.drawIndexedPrimitives(type: MetalDataTypes.map(primitiveType), indexType: MetalDataTypes.map(indexType), indexBuffer: bufferOwner[indexBuffer], indexBufferOffset: indexBufferOffset, indirectBuffer: bufferOwner[indirectBuffer], indirectBufferOffset: indirectBufferOffset)
    }
}
