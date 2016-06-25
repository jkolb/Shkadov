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

import Shkadov

public struct VertexPNT1 {
    public let position: Vector3D
    public let normal: Vector3D
    public let texcoord: Vector2D
    
    public init(position: Vector3D, normal: Vector3D, texcoord: Vector2D) {
        self.position = position
        self.normal = normal
        self.texcoord = texcoord
    }
    
    private static let attributes = [
        VertexAttribute(
            semantic: .Position,
            semanticIndex: 0,
            format: .Float32_3,
            offset: 0,
            bufferIndex: 0
        ),
        VertexAttribute(
            semantic: .Normal,
            semanticIndex: 0,
            format: .Float32_3,
            offset: strideof(Vector3D),
            bufferIndex: 0
        ),
        VertexAttribute(
            semantic: .Texcoord,
            semanticIndex: 0,
            format: .Float32_2,
            offset: strideof(Vector3D) + strideof(Vector3D),
            bufferIndex: 0
        ),
    ]
    private static let layout = VertexBufferLayout(stepFunction: .PerVertex, stepRate: 1, stride: strideof(VertexPNT1))
    public static let descriptor = VertexDescriptor(attributes: VertexPNT1.attributes, layouts: [VertexPNT1.layout])
}
