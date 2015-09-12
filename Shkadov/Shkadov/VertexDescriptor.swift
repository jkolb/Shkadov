/*
The MIT License (MIT)

Copyright (c) 2015 Justin Kolb

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

public struct VertexDescriptor {
    public private(set) var attributes: [VertexAttribute]
    private var attributeFormats: [VertexAttribute : VertexAttributeFormat]
    private var attributeOffsets: [VertexAttribute : Int]
    public private(set) var size: Int
    
    public init() {
        self.attributes = [VertexAttribute]()
        self.attributeFormats = [VertexAttribute : VertexAttributeFormat]()
        self.attributeOffsets = [VertexAttribute : Int]()
        self.size = 0
    }
    
    public func hasAttribute(attribute: VertexAttribute) -> Bool {
        return attributeFormats[attribute] != nil
    }
    
    public func formatForAttribute(attribute: VertexAttribute) -> VertexAttributeFormat {
        return attributeFormats[attribute]!
    }
    
    public func offsetForAttribute(attribute: VertexAttribute) -> Int {
        return attributeOffsets[attribute]!
    }
    
    public mutating func addAttribute(attribute: VertexAttribute, format: VertexAttributeFormat) {
        precondition(!hasAttribute(attribute), "Duplicate attribute '\(attribute)'")
        attributes.append(attribute)
        attributeFormats[attribute] = format
        attributeOffsets[attribute] = size
        size += format.size
    }
}
