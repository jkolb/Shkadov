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

public enum VertexAttribute : UInt {
    case Position
    case Normal
    case Color
    case TexCoord0
    case TexCoord1
}

public enum VertexDataType {
    case Float
    
    public var size: Int {
        switch self {
        case Float:
            return sizeof(Swift.Float.self)
        }
    }
}

public struct VertexAttributeDescriptor {
    public let attribute: VertexAttribute
    public let dataType: VertexDataType
    public let componentCount: Int
    
    public init(attribute: VertexAttribute, dataType: VertexDataType, componentCount: Int) {
        self.attribute = attribute
        self.dataType = dataType
        self.componentCount = componentCount
    }
    
    public var size: Int {
        return dataType.size * componentCount
    }
}

public struct VertexDescriptor {
    private var orderedAttributes: [VertexAttribute]
    private var attributeDescriptors: [VertexAttribute : VertexAttributeDescriptor]
    private var attributeOffsets: [VertexAttribute : Int]
    private var stride: Int
    
    public init() {
        self.orderedAttributes = [VertexAttribute]()
        self.attributeDescriptors = [VertexAttribute : VertexAttributeDescriptor]()
        self.attributeOffsets = [VertexAttribute : Int]()
        self.stride = 0
    }
    
    public func hasAttribute(attribute: VertexAttribute) -> Bool {
        return attributeDescriptors[attribute] != nil
    }
    
    public func descriptorForAttribute(attribute: VertexAttribute) -> VertexAttributeDescriptor {
        return attributeDescriptors[attribute]!
    }
    
    public func offsetForAttribute(attribute: VertexAttribute) -> Int {
        return attributeOffsets[attribute]!
    }
    
    public mutating func addAttribute(attribute: VertexAttribute, dataType: VertexDataType, componentCount: Int) {
        addAttributeDescriptor(VertexAttributeDescriptor(attribute: attribute, dataType: dataType, componentCount: componentCount))
    }
    
    public mutating func addAttributeDescriptor(attributeDescriptor: VertexAttributeDescriptor) {
        let attribute = attributeDescriptor.attribute
        precondition(!hasAttribute(attribute), "Duplicate attribute '\(attribute)'")
        orderedAttributes.append(attribute)
        attributeDescriptors[attribute] = attributeDescriptor
        attributeOffsets[attribute] = stride
        stride += attributeDescriptor.size
    }

    public var size: Int {
        return stride
    }
    
    public var attributes: [VertexAttribute] {
        return orderedAttributes
    }
}
