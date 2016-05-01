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

public final class BoxGeometryBuilder {
    private let gpuMemory: GPUMemory
    
    public init(gpuMemory: GPUMemory) {
        self.gpuMemory = gpuMemory
    }
    
    public func outlineUnitBox() -> Geometry {
        return outlineBox(width: 1.0, height: 1.0, depth: 1.0)
    }
    
    public func outlineBox(width width: Float, height: Float, depth: Float) -> Geometry {
        precondition(width > 0.0)
        precondition(height > 0.0)
        precondition(depth > 0.0)
        let w = width * 0.5
        let h = height * 0.5
        let d = depth * 0.5
        
        /*
        Right handed & Counter-clockwise
        
          Y+
          |
          |
          o------X+
         /
        Z+
        
          7------4
         /|     /|         +X            -X            +Y            -Y            +Z            -Z
        0------3 |      3------4      7------0      7------4      5------6      0------3      4------7
        | 6----|-5      |      |      |      |      |      |      |      |      |      |      |      |
        |/     |/       |      |      |      |      |      |      |      |      |      |      |      |
        1------2        2------5      6------1      0------3      2------1      1------2      5------6
        
        */
        
        let vertices = [
            Vector3D(-w, +h, +d),
            Vector3D(-w, -h, +d),
            Vector3D(+w, -h, +d),
            Vector3D(+w, +h, +d),
            Vector3D(+w, +h, -d),
            Vector3D(+w, -h, -d),
            Vector3D(-w, -h, -d),
            Vector3D(-w, +h, -d),
            ]
        let indices: [UInt16] = [
            3, 2,   2, 5,   5, 4,   4, 3,
            7, 6,   6, 1,   1, 0,   0, 7,
            7, 0,   0, 3,   3, 4,   4, 7,
            5, 2,   2, 1,   1, 6,   6, 5,
            0, 1,   1, 2,   2, 3,   3, 0,
            4, 5,   5, 6,   6, 7,   7, 4,
            ]
        let attributes = [
            VertexAttribute(
                semantic: .Position,
                semanticIndex: 0,
                format: .Float32_3,
                offset: 0,
                bufferIndex: 0
            ),
            ]
        let layout = VertexBufferLayout(stepFunction: .PerVertex, stepRate: 1, stride: strideof(Vector3D))
        let descriptor = VertexDescriptor(attributes: attributes, layouts: [layout])
        let vertexData = gpuMemory.bufferWithBytes(vertices, size: vertices.count * strideof(Vector3D), storageMode: .Shared)
        let vertexBuffer = VertexBuffer(descriptor: descriptor, count: vertices.count, data: vertexData)
        let indexDescriptor = IndexDescriptor(primitiveType: .Line, indexType: .UInt16)
        let indexData = gpuMemory.bufferWithBytes(indices, size: indices.count * strideof(UInt16), storageMode: .Shared)
        let indexBuffer = IndexBuffer(descriptor: indexDescriptor, count: indices.count, data: indexData)
        let bounds = AABB(center: Vector3D.zero, radius: Vector3D(w, h, d))
        
        return Geometry(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, bounds: bounds)
    }
    
    public func unitFilledBox() -> Geometry {
        return filledBox(width: 1.0, height: 1.0, depth: 1.0)
    }
    
    public func filledBox(width width: Float, height: Float, depth: Float) -> Geometry {
        precondition(width > 0.0)
        precondition(height > 0.0)
        precondition(depth > 0.0)
        let w = width * 0.5
        let h = height * 0.5
        let d = depth * 0.5
        
        /*
         Right handed & Counter-clockwise
         
           Y+
           |
           |
           o------X+
          /
         Z+
         
           7------4
          /|     /|         +X            -X            +Y            -Y            +Z            -Z
         0------3 |      3------4      7------0      7------4      5------6      0------3      4------7
         | 6----|-5      |      |      |      |      |      |      |      |      |      |      |      |
         |/     |/       |      |      |      |      |      |      |      |      |      |      |      |
         1------2        2------5      6------1      0------3      2------1      1------2      5------6
         
         */
        
        let vertices = [
            Vector3D(-w, +h, +d),
            Vector3D(-w, -h, +d),
            Vector3D(+w, -h, +d),
            Vector3D(+w, +h, +d),
            Vector3D(+w, +h, -d),
            Vector3D(+w, -h, -d),
            Vector3D(-w, -h, -d),
            Vector3D(-w, +h, -d),
            ]
        //  a, b, d,   d, b, c  |  a, b, c, d
        let indices: [UInt16] = [
            3, 2, 4,   4, 2, 5, // 3, 2, 5, 4
            7, 6, 0,   0, 6, 1, // 7, 6, 1, 0
            7, 0, 4,   4, 0, 3, // 7, 0, 3, 4
            5, 2, 6,   6, 2, 1, // 5, 2, 1, 6
            0, 1, 3,   3, 1, 2, // 0, 1, 2, 3
            4, 5, 7,   7, 5, 6, // 4, 5, 6, 7
        ]
        let attributes = [
            VertexAttribute(
                semantic: .Position,
                semanticIndex: 0,
                format: .Float32_3,
                offset: 0,
                bufferIndex: 0
            ),
            ]
        let layout = VertexBufferLayout(stepFunction: .PerVertex, stepRate: 1, stride: strideof(Vector3D))
        let descriptor = VertexDescriptor(attributes: attributes, layouts: [layout])
        let vertexData = gpuMemory.bufferWithBytes(vertices, size: vertices.count * strideof(Vector3D), storageMode: .Shared)
        let vertexBuffer = VertexBuffer(descriptor: descriptor, count: vertices.count, data: vertexData)
        let indexDescriptor = IndexDescriptor(primitiveType: .Triangle, indexType: .UInt16)
        let indexData = gpuMemory.bufferWithBytes(indices, size: indices.count * strideof(UInt16), storageMode: .Shared)
        let indexBuffer = IndexBuffer(descriptor: indexDescriptor, count: indices.count, data: indexData)
        let bounds = AABB(center: Vector3D.zero, radius: Vector3D(w, h, d))
        
        return Geometry(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, bounds: bounds)
    }
}
