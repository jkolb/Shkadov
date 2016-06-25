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

public struct IndexTrianglePNT1 : CollectionType {
    private let vertices: (IndexVertexPNT1, IndexVertexPNT1, IndexVertexPNT1)
    
    public init(_ a: IndexVertexPNT1, _ b: IndexVertexPNT1, _ c: IndexVertexPNT1) {
        self.vertices = (a, b, c)
    }
    
    public let startIndex = 0
    public let endIndex = 3
    
    public subscript (index: Int) -> IndexVertexPNT1 {
        switch index {
        case 0:
            return vertices.0
        case 1:
            return vertices.1
        case 2:
            return vertices.2
        default:
            fatalError("index out of range")
        }
    }
    
    public var positionIndices: [Int] {
        return [vertices.0.positionIndex, vertices.1.positionIndex, vertices.2.positionIndex]
    }
}
