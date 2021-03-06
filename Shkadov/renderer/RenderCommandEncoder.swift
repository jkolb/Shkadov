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
    func setRenderPipelineState(_ handle: RenderPipelineStateHandle)

    func setRasterizerState(_ handle: RasterizerStateHandle)

    // Dynamic state
    func setViewport(_ viewport: Viewport)
    
    func setDepthStencilState(_ handle: DepthStencilStateHandle)
    
    func setVertexBytes(_ bytes: UnsafeRawPointer, length: Int, at index: Int)
    
    func setVertexBuffer(_ handle: GPUBufferHandle, offset: Int, at index: Int)
    
    func setVertexBufferOffset(_ offset: Int, at index: Int)
    
    func setVertexBuffers(_ handles: [GPUBufferHandle], offsets: [Int], with range: Range<Int>)
    
    func setVertexTexture(_ handle: TextureHandle, at index: Int)
    
    func setVertexTextures(_ handles: [TextureHandle], with range: Range<Int>)
    
    func setVertexSampler(_ handle: SamplerHandle, at index: Int)
    
    func setVertexSamplers(_ handles: [SamplerHandle], with range: Range<Int>)
    
    func setVertexSampler(_ handle: SamplerHandle, lodMinClamp: Float, lodMaxClamp: Float, at index: Int)
    
    func setVertexSamplers(_ handles: [SamplerHandle], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>)

    func setFragmentBytes(_ bytes: UnsafeRawPointer, length: Int, at index: Int)
    
    func setFragmentBuffer(_ handle: GPUBufferHandle, offset: Int, at index: Int)
    
    func setFragmentBufferOffset(_ offset: Int, at index: Int)
    
    func setFragmentBuffers(_ handles: [GPUBufferHandle], offsets: [Int], with range: Range<Int>)
    
    func setFragmentTexture(_ handle: TextureHandle, at index: Int)
    
    func setFragmentTextures(_ handles: [TextureHandle], with range: Range<Int>)
    
    func setFragmentSampler(_ handle: SamplerHandle, at index: Int)
    
    func setFragmentSamplers(_ handles: [SamplerHandle], with range: Range<Int>)
    
    func setFragmentSampler(_ handle: SamplerHandle, lodMinClamp: Float, lodMaxClamp: Float, at index: Int)
    
    func setFragmentSamplers(_ handles: [SamplerHandle], lodMinClamps: [Float], lodMaxClamps: [Float], with range: Range<Int>)

    func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int)
    
    func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int, instanceCount: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int)
    
    func drawPrimitives(type primitiveType: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int, baseInstance: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexCount: Int, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int, instanceCount: Int, baseVertex: Int, baseInstance: Int)
    
    func drawPrimitives(type primitiveType: PrimitiveType, indirectBuffer: GPUBufferHandle, indirectBufferOffset: Int)
    
    func drawIndexedPrimitives(type primitiveType: PrimitiveType, indexType: IndexType, indexBuffer: GPUBufferHandle, indexBufferOffset: Int, indirectBuffer: GPUBufferHandle, indirectBufferOffset: Int)
}
