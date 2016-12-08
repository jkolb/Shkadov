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

import Swiftish

public func rotation(angle: Vector3<Float>) -> Quaternion<Float> {
    let halfAngle: Vector3<Float> = angle / 2.0
    let c = cos(halfAngle)
    let s = sin(halfAngle)
    let w: Float = c.x * c.y * c.z + s.x * s.y * s.z
    let x: Float = s.x * c.y * c.z - c.x * s.y * s.z
    let y: Float = c.x * s.y * c.z + s.x * c.y * s.z
    let z: Float = c.x * c.y * s.z - s.x * s.y * c.z
    
    return Quaternion<Float>(w, x, y, z)
}

class RenderableObject {
    let mesh: GPUBufferHandle
    let indexBuffer: GPUBufferHandle
    let texture: TextureHandle
    var count: Int
    var transform: Transform3<Float>
    var rotationRate: Vector3<Float>
    var objectData: ObjectData
    
    init() {
        self.mesh = GPUBufferHandle()
        self.indexBuffer = GPUBufferHandle()
        self.texture = TextureHandle()
        self.count = 0
        self.objectData = ObjectData()
        self.transform = Transform3<Float>()
        self.rotationRate = Vector3<Float>(0.0, 0.0, 0.0)
    }
    
    init(m: GPUBufferHandle, idx: GPUBufferHandle, count: Int, tex: TextureHandle)
    {
        self.mesh = m
        self.indexBuffer = idx
        self.texture = tex
        self.count = count
        self.objectData = ObjectData()
        self.transform = Transform3<Float>()
        self.rotationRate = Vector3<Float>(0.0, 0.0, 0.0)
    }
    
    func UpdateData(_ dest : UnsafeMutablePointer<ObjectData>, deltaTime : Duration) -> UnsafeMutablePointer<ObjectData>
    {
        
        transform.r = transform.r + rotation(angle: rotationRate * Float(deltaTime.seconds))
        
        objectData.localToWorld = transform.matrix
        
        dest.pointee = objectData
        return dest.advanced(by: 1)
    }
    
    func DrawZPass(_ enc: RenderCommandEncoder, offset: Int) {
        enc.setVertexBufferOffset(offset, at: 1)
        
        if (indexBuffer.isValid) {
            enc.drawIndexedPrimitives(type: .triangle, indexCount: count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        }
        else {
            enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
        }
    }
    
    func Draw(_ enc: RenderCommandEncoder, offset: Int) {
        enc.setVertexBufferOffset(offset, at: 1)
        enc.setFragmentBufferOffset(offset, at: 1)
        
        if (indexBuffer.isValid) {
            enc.drawIndexedPrimitives(type: .triangle, indexCount: count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        }
        else {
            enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
        }
        
    }
}

class StaticRenderableObject : RenderableObject {
    override func UpdateData(_ dest: UnsafeMutablePointer<ObjectData>, deltaTime: Duration) -> UnsafeMutablePointer<ObjectData> {
        return dest
    }
    
    override func Draw(_ enc: RenderCommandEncoder, offset: Int) {
        enc.setVertexBuffer(mesh, offset: 0, at: 0)
        enc.setVertexBytes(&objectData, length: 256, at: 1)
        enc.setFragmentBytes(&objectData, length: 256, at: 1)
        
        enc.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: count)
    }
}
