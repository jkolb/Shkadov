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

public protocol RenderCommandEncoder : CommandEncoder {
    func setRenderPipelineState(_ pipelineState: RenderPipelineState)

    func setViewport(_ viewport: Viewport)
    
    func setFrontFacing(_ frontFacingWinding: Winding)
    
    func setCullMode(_ cullMode: CullMode)
    
    func setDepthClipMode(_ depthClipMode: DepthClipMode)
    
    func setDepthBias(_ depthBias: Float, slopeScale: Float, clamp: Float)
    
    func setScissorRect(_ rect: ScissorRect)
    
    func setTriangleFillMode(_ fillMode: TriangleFillMode)

    func setVertexBytes(_ bytes: UnsafeRawPointer, length: Int, at index: Int)
    
    func setVertexBuffer(_ buffer: GraphicsBuffer?, offset: Int, at index: Int)
    
    func setVertexBufferOffset(_ offset: Int, at index: Int)
    
    func setVertexBuffers(_ buffers: [GraphicsBuffer?], offsets: [Int], with range: Range<Int>)
    
    func setVertexTexture(_ handle: TextureHandle, at index: Int)
    
    func setVertexTextures(_ handles: [TextureHandle], with range: Range<Int>)
    
    func setVertexSampler(_ sampler: Sampler?, at index: Int)
    
    func setVertexSamplers(_ samplers: [Sampler?], with range: Range<Int>)
    
    func setVertexSampler(_ sampler: Sampler?, lodMinClamp: Float, lodMaxClamp: Float, at index: Int)
    
    func setVertexSamplers(_ samplers: [Sampler?], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>)

    func setFragmentBytes(_ bytes: UnsafeRawPointer, length: Int, at index: Int)
    
    func setFragmentBuffer(_ buffer: GraphicsBuffer?, offset: Int, at index: Int)
    
    func setFragmentBufferOffset(_ offset: Int, at index: Int)
    
    func setFragmentBuffers(_ buffers: [GraphicsBuffer?], offsets: [Int], with range: Range<Int>)
    
    func setFragmentTexture(_ handle: TextureHandle, at index: Int)
    
    func setFragmentTextures(_ handles: [TextureHandle], with range: Range<Int>)
    
    func setFragmentSampler(_ sampler: Sampler?, at index: Int)
    
    func setFragmentSamplers(_ samplers: [Sampler?], with range: Range<Int>)
    
    func setFragmentSampler(_ sampler: Sampler?, lodMinClamp: Float, lodMaxClamp: Float, at index: Int)
    
    func setFragmentSamplers(_ samplers: [Sampler?], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>)

    func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int)
    
    func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int, instanceCount: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int)
    
    func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int, baseInstance: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int, instanceCount: Int, baseVertex: Int, baseInstance: Int)
    
    func drawPrimitives(type primitiveType: PrimitiveType, indirectBuffer: GraphicsBuffer, indirectBufferOffset: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexType: IndexType, indexBuffer: GraphicsBuffer, indexBufferOffset: Int, indirectBuffer: GraphicsBuffer, indirectBufferOffset: Int)
}
