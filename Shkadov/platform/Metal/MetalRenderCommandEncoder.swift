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
    private unowned(unsafe) let textureOwner: MetalTextureOwner
    
    public init(instance: MTLRenderCommandEncoder, textureOwner: MetalTextureOwner) {
        self.instance = instance
        self.textureOwner = textureOwner
    }
    
    public func endEncoding() {
        instance.endEncoding()
    }
    
    public func setRenderPipelineState(_ pipelineState: RenderPipelineState) {
        if let metalPipelineState = pipelineState as? MetalRenderPipelineState {
            instance.setRenderPipelineState(metalPipelineState.instance)
        }
    }
    
    public func setViewport(_ viewport: Viewport) {
        instance.setViewport(MetalViewport.map(viewport))
    }
    
    public func setFrontFacing(_ frontFacingWinding: Winding) {
        instance.setFrontFacing(MetalWinding.map(frontFacingWinding))
    }
    
    public func setCullMode(_ cullMode: CullMode) {
        instance.setCullMode(MetalCullMode.map(cullMode))
    }
    
    public func setDepthClipMode(_ depthClipMode: DepthClipMode) {
        instance.setDepthClipMode(MetalDepthClipMode.map(depthClipMode))
    }
    
    public func setDepthBias(_ depthBias: Float, slopeScale: Float, clamp: Float) {
        instance.setDepthBias(depthBias, slopeScale: slopeScale, clamp: clamp)
    }
    
    public func setScissorRect(_ rect: ScissorRect) {
        instance.setScissorRect(MetalScissorRect.map(rect))
    }
    
    public func setTriangleFillMode(_ fillMode: TriangleFillMode) {
        instance.setTriangleFillMode(MetalTriangleFillMode.map(fillMode))
    }
    
    public func setVertexBytes(_ bytes: UnsafeRawPointer, length: Int, at index: Int) {
        instance.setVertexBytes(bytes, length: length, at: index)
    }
    
    public func setVertexBuffer(_ buffer: GraphicsBuffer?, offset: Int, at index: Int) {
        if let metalBuffer = buffer as? MetalGraphicsBuffer {
            instance.setVertexBuffer(metalBuffer.instance, offset: offset, at: index)
        }
        else {
            instance.setVertexBuffer(nil, offset: offset, at: index)
        }
    }
    
    public func setVertexBufferOffset(_ offset: Int, at index: Int) {
        instance.setVertexBufferOffset(offset, at: index)
    }
    
    public func setVertexBuffers(_ buffers: [GraphicsBuffer?], offsets: [Int], with range: Range<Int>) {
        let metalBuffers = buffers.map { (buffer) -> MTLBuffer? in
            if let metalBuffer = buffer as? MetalGraphicsBuffer {
                return metalBuffer.instance
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
    
    public func setVertexSampler(_ sampler: Sampler?, at index: Int) {
        if let metalSampler = sampler as? MetalSampler {
            instance.setVertexSamplerState(metalSampler.instance, at: index)
        }
        else {
            instance.setVertexSamplerState(nil, at: index)
        }
    }
    
    public func setVertexSamplers(_ samplers: [Sampler?], with range: Range<Int>) {
        let metalSamplers = samplers.map { (sampler) -> MTLSamplerState? in
            if let metalSampler = sampler as? MetalSampler {
                return metalSampler.instance
            }
            else {
                return nil
            }
        }
        instance.setVertexSamplerStates(metalSamplers, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setVertexSampler(_ sampler: Sampler?, lodMinClamp: Float, lodMaxClamp: Float, at index: Int) {
        if let metalSampler = sampler as? MetalSampler {
            instance.setVertexSamplerState(metalSampler.instance, lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
        else {
            instance.setVertexSamplerState(nil, lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
    }
    
    public func setVertexSamplers(_ samplers: [Sampler?], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>) {
        let metalSamplers = samplers.map { (sampler) -> MTLSamplerState? in
            if let metalSampler = sampler as? MetalSampler {
                return metalSampler.instance
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
    
    public func setFragmentBuffer(_ buffer: GraphicsBuffer?, offset: Int, at index: Int) {
        if let metalBufer = buffer as? MetalGraphicsBuffer {
            instance.setFragmentBuffer(metalBufer.instance, offset: offset, at: index)
        }
        else {
            instance.setFragmentBuffer(nil, offset: offset, at: index)
        }
    }
    
    public func setFragmentBufferOffset(_ offset: Int, at index: Int) {
        instance.setFragmentBufferOffset(offset, at: index)
    }
    
    public func setFragmentBuffers(_ buffers: [GraphicsBuffer?], offsets: [Int], with range: Range<Int>) {
        let metalBuffers = buffers.map { (buffer) -> MTLBuffer? in
            if let metalBuffer = buffer as? MetalGraphicsBuffer {
                return metalBuffer.instance
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
    
    public func setFragmentSampler(_ sampler: Sampler?, at index: Int) {
        if let metalSampler = sampler as? MetalSampler {
            instance.setFragmentSamplerState(metalSampler.instance, at: index)
        }
        else {
            instance.setFragmentSamplerState(nil, at: index)
        }
    }
    
    public func setFragmentSamplers(_ samplers: [Sampler?], with range: Range<Int>) {
        let metalSamplers = samplers.map { (sampler) -> MTLSamplerState? in
            if let metalSampler = sampler as? MetalSampler {
                return metalSampler.instance
            }
            else {
                return nil
            }
        }
        instance.setFragmentSamplerStates(metalSamplers, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func setFragmentSampler(_ sampler: Sampler?, lodMinClamp: Float, lodMaxClamp: Float, at index: Int) {
        if let metalSampler = sampler as? MetalSampler {
            instance.setFragmentSamplerState(metalSampler.instance, lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
        else {
            instance.setFragmentSamplerState(nil, lodMinClamp: lodMinClamp, lodMaxClamp: lodMaxClamp, at: index)
        }
    }
    
    public func setFragmentSamplers(_ samplers: [Sampler?], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>) {
        let metalSamplers = samplers.map { (sampler) -> MTLSamplerState? in
            if let metalSampler = sampler as? MetalSampler {
                return metalSampler.instance
            }
            else {
                return nil
            }
        }
        instance.setFragmentSamplerStates(metalSamplers, lodMinClamps: lodMinClamps, lodMaxClamps: lodMaxClamps, with: NSMakeRange(range.lowerBound, range.count))
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int) {
        instance.drawPrimitives(type: MetalPrimitiveType.map(primitiveType), vertexStart: vertexStart, vertexCount: vertexCount, instanceCount: instanceCount)
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int) {
        instance.drawPrimitives(type: MetalPrimitiveType.map(primitiveType), vertexStart: vertexStart, vertexCount: vertexCount)
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int, instanceCount: Int) {
        if let metalBuffer = indexBuffer as? MetalGraphicsBuffer {
            instance.drawIndexedPrimitives(type: MetalPrimitiveType.map(primitiveType), indexCount: indexCount, indexType: MetalIndexType.map(indexType), indexBuffer: metalBuffer.instance, indexBufferOffset: indexBufferOffset, instanceCount: instanceCount)
        }
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int) {
        if let metalBuffer = indexBuffer as? MetalGraphicsBuffer {
            instance.drawIndexedPrimitives(type: MetalPrimitiveType.map(primitiveType), indexCount: indexCount, indexType: MetalIndexType.map(indexType), indexBuffer: metalBuffer.instance, indexBufferOffset: indexBufferOffset)
        }
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int, baseInstance: Int) {
        instance.drawPrimitives(type: MetalPrimitiveType.map(primitiveType), vertexStart: vertexStart, vertexCount: vertexCount, instanceCount: instanceCount, baseInstance: baseInstance)
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int, instanceCount: Int, baseVertex: Int, baseInstance: Int) {
        if let metalBuffer = indexBuffer as? MetalGraphicsBuffer {
            instance.drawIndexedPrimitives(type: MetalPrimitiveType.map(primitiveType), indexCount: indexCount, indexType: MetalIndexType.map(indexType), indexBuffer: metalBuffer.instance, indexBufferOffset: indexBufferOffset, instanceCount: instanceCount, baseVertex: baseVertex, baseInstance: baseInstance)
        }
    }
    
    public func drawPrimitives(type primitiveType: PrimitiveType, indirectBuffer: GraphicsBuffer, indirectBufferOffset: Int) {
        if let metalBuffer = indirectBuffer as? MetalGraphicsBuffer {
            instance.drawPrimitives(type: MetalPrimitiveType.map(primitiveType), indirectBuffer: metalBuffer.instance, indirectBufferOffset: indirectBufferOffset)
        }
    }
    
    public func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int, indirectBuffer: GraphicsBuffer, indirectBufferOffset: Int) {
        if let metalIndexBuffer = indexBuffer as? MetalGraphicsBuffer, let metalIndirectBuffer = indirectBuffer as? MetalGraphicsBuffer  {
            instance.drawIndexedPrimitives(type: MetalPrimitiveType.map(primitiveType), indexType: MetalIndexType.map(indexType), indexBuffer: metalIndexBuffer.instance, indexBufferOffset: indexBufferOffset, indirectBuffer: metalIndirectBuffer.instance, indirectBufferOffset: indirectBufferOffset)
        }
    }
}
