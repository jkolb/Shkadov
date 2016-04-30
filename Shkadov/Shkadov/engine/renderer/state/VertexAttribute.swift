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

public struct VertexAttribute : CustomStringConvertible, Equatable {
    public let semantic: VertexAttributeSemantic
    public let semanticIndex: Int
    public let format: VertexFormat
    public let offset: Int
    public let bufferIndex: Int
    
    public init(semantic: VertexAttributeSemantic, semanticIndex: Int, format: VertexFormat, offset: Int, bufferIndex: Int) {
        precondition(semanticIndex >= 0)
        precondition(format != .Invalid)
        precondition(offset >= 0)
        precondition(bufferIndex >= 0)
        self.semantic = semantic
        self.semanticIndex = semanticIndex
        self.format = format;
        self.offset = offset;
        self.bufferIndex = bufferIndex;
    }
    
    public var description: String {
        return "\(semantic)(\(semanticIndex)):\(format):\(offset):\(bufferIndex)"
    }
}

public func ==(lhs: VertexAttribute, rhs: VertexAttribute) -> Bool {
    return (lhs.semantic == rhs.semantic) && (lhs.semanticIndex == rhs.semanticIndex) && (lhs.format == rhs.format) && (lhs.offset == rhs.offset) && (lhs.bufferIndex == rhs.bufferIndex)
}
