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

import simd

class RenderableObject
{
    let mesh : GPUBufferHandle
    let indexBuffer : GPUBufferHandle
    let texture : TextureHandle
    
    var count : Int
    
    var scale : vector_float3 = float3(1.0)
    var position : vector_float4
    var rotation : vector_float3
    var rotationRate : vector_float3
    
    var objectData : ObjectData
    
    init()
    {
        self.mesh = GPUBufferHandle()
        self.indexBuffer = GPUBufferHandle()
        self.texture = TextureHandle()
        self.count = 0
        self.objectData = ObjectData()
        self.objectData.LocalToWorld = matrix_identity_float4x4
        self.position = vector_float4(0.0, 0.0, 0.0, 1.0)
        self.rotation = float3(0.0, 0.0, 0.0)
        self.rotationRate = float3(0.0, 0.0, 0.0)
    }
    
    init(m : GPUBufferHandle, idx : GPUBufferHandle, count : Int, tex : TextureHandle)
    {
        self.mesh = m
        self.indexBuffer = idx
        self.texture = tex
        self.count = count
        self.objectData = ObjectData()
        self.objectData.LocalToWorld = matrix_identity_float4x4
        self.objectData.color = float4(0.0, 0.0, 0.0, 0.0)
        self.objectData.pad1 = matrix_identity_float4x4
        self.objectData.pad2 = matrix_identity_float4x4
        
        self.position = vector_float4(0.0, 0.0, 0.0, 1.0)
        self.rotation = float3(0.0, 0.0, 0.0)
        self.rotationRate = float3(0.0, 0.0, 0.0)
    }
    
    func SetRotationRate(_ rot : vector_float3)
    {
        rotationRate = rot
    }
    
    func UpdateData(_ dest : UnsafeMutablePointer<ObjectData>, deltaTime : Float) -> UnsafeMutablePointer<ObjectData>
    {
        rotation += rotationRate * deltaTime
        
        objectData.LocalToWorld = getScaleMatrix(scale.x, y: scale.y, z: scale.z)
        
        objectData.LocalToWorld = matrix_multiply(getRotationAroundX(rotation.x), objectData.LocalToWorld)
        objectData.LocalToWorld = matrix_multiply(getRotationAroundY(rotation.y), objectData.LocalToWorld)
        objectData.LocalToWorld = matrix_multiply(getRotationAroundZ(rotation.z), objectData.LocalToWorld)
        objectData.LocalToWorld = matrix_multiply(getTranslationMatrix(position), objectData.LocalToWorld)
        
        dest.pointee = objectData
        return dest.advanced(by: 1)
    }
    
    func DrawZPass(_ enc :RenderCommandEncoder, offset : Int)
    {
        enc.setVertexBufferOffset(offset, at: 1)
        
        if(indexBuffer.isValid)
        {
            enc.drawIndexedPrimitives(type: .triangle, indexCount: count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        }
        else
        {
            enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
        }
    }
    
    func Draw(_ enc : RenderCommandEncoder, offset : Int)
    {
        enc.setVertexBufferOffset(offset, at: 1)
        enc.setFragmentBufferOffset(offset, at: 1)
        
        if(indexBuffer.isValid)
        {
            enc.drawIndexedPrimitives(type: .triangle, indexCount: count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        }
        else
        {
            enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
        }
        
    }
}

class StaticRenderableObject : RenderableObject
{
    override func UpdateData(_ dest: UnsafeMutablePointer<ObjectData>, deltaTime: Float) -> UnsafeMutablePointer<ObjectData>
    {
        return dest
    }
    
    override func Draw(_ enc: RenderCommandEncoder, offset: Int)
    {
        enc.setVertexBuffer(mesh, offset: 0, at: 0)
        enc.setVertexBytes(&objectData, length: MemoryLayout<ObjectData>.size, at: 1)
        enc.setFragmentBytes(&objectData, length: MemoryLayout<ObjectData>.size, at: 1)
        
        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
    }
}
