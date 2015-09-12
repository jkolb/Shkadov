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

public struct VertexAttributeFormat {
    // Formats supported by both OpenGL and Metal, can still create others using the initializers
    
    public static let Byte2 = VertexAttributeFormat(integerType: Int8.self, count: 2)
    public static let Byte3 = VertexAttributeFormat(integerType: Int8.self, count: 3)
    public static let Byte4 = VertexAttributeFormat(integerType: Int8.self, count: 4)
    
    public static let UByte2 = VertexAttributeFormat(integerType: UInt8.self, count: 2)
    public static let UByte3 = VertexAttributeFormat(integerType: UInt8.self, count: 3)
    public static let UByte4 = VertexAttributeFormat(integerType: UInt8.self, count: 4)
    
    public static let Byte2Normalized = VertexAttributeFormat(dataType: Int8.self, count: 2, isNormalized: true)
    public static let Byte3Normalized = VertexAttributeFormat(dataType: Int8.self, count: 3, isNormalized: true)
    public static let Byte4Normalized = VertexAttributeFormat(dataType: Int8.self, count: 4, isNormalized: true)
    
    public static let UByte2Normalized = VertexAttributeFormat(dataType: UInt8.self, count: 2, isNormalized: true)
    public static let UByte3Normalized = VertexAttributeFormat(dataType: UInt8.self, count: 3, isNormalized: true)
    public static let UByte4Normalized = VertexAttributeFormat(dataType: UInt8.self, count: 4, isNormalized: true)
    
    public static let Short2 = VertexAttributeFormat(integerType: Int16.self, count: 2)
    public static let Short3 = VertexAttributeFormat(integerType: Int16.self, count: 3)
    public static let Short4 = VertexAttributeFormat(integerType: Int16.self, count: 4)
    
    public static let UShort2 = VertexAttributeFormat(integerType: UInt16.self, count: 2)
    public static let UShort3 = VertexAttributeFormat(integerType: UInt16.self, count: 3)
    public static let UShort4 = VertexAttributeFormat(integerType: UInt16.self, count: 4)
    
    public static let Short2Normalized = VertexAttributeFormat(dataType: Int16.self, count: 2, isNormalized: true)
    public static let Short3Normalized = VertexAttributeFormat(dataType: Int16.self, count: 3, isNormalized: true)
    public static let Short4Normalized = VertexAttributeFormat(dataType: Int16.self, count: 4, isNormalized: true)
    
    public static let UShort2Normalized = VertexAttributeFormat(dataType: UInt16.self, count: 2, isNormalized: true)
    public static let UShort3Normalized = VertexAttributeFormat(dataType: UInt16.self, count: 3, isNormalized: true)
    public static let UShort4Normalized = VertexAttributeFormat(dataType: UInt16.self, count: 4, isNormalized: true)
    
    public static let Int1 = VertexAttributeFormat(integerType: Int32.self, count: 1)
    public static let Int2 = VertexAttributeFormat(integerType: Int32.self, count: 2)
    public static let Int3 = VertexAttributeFormat(integerType: Int32.self, count: 3)
    public static let Int4 = VertexAttributeFormat(integerType: Int32.self, count: 4)
    
    public static let UInt1 = VertexAttributeFormat(integerType: UInt32.self, count: 1)
    public static let UInt2 = VertexAttributeFormat(integerType: UInt32.self, count: 2)
    public static let UInt3 = VertexAttributeFormat(integerType: UInt32.self, count: 3)
    public static let UInt4 = VertexAttributeFormat(integerType: UInt32.self, count: 4)
    
    public static let Float1 = VertexAttributeFormat(dataType: Float.self, count: 1, isNormalized: false)
    public static let Float2 = VertexAttributeFormat(dataType: Float.self, count: 2, isNormalized: false)
    public static let Float3 = VertexAttributeFormat(dataType: Float.self, count: 3, isNormalized: false)
    public static let Float4 = VertexAttributeFormat(dataType: Float.self, count: 4, isNormalized: false)
    
    public static let Int1010102Normalized = VertexAttributeFormat(dataType: Int1010102.self, count: 1, isNormalized: true)
    public static let UInt1010102Normalized = VertexAttributeFormat(dataType: UInt1010102.self, count: 1, isNormalized: true)
    
    public let kind: Kind
    public let count: Int
    public let size: Int
    public let isFloatingPoint: Bool
    public let isNormalized: Bool
    
    private static let allowedFloatingPointKinds = Set<Kind>([
        Float.kind,
        Double.kind,
        Int8.kind,
        Int16.kind,
        Int32.kind,
        UInt8.kind,
        UInt16.kind,
        UInt32.kind,
        Int1010102.kind,
        UInt1010102.kind,
        ])
    
    private static let allowedIntegerKinds = Set<Kind>([
        Int8.kind,
        Int16.kind,
        Int32.kind,
        UInt8.kind,
        UInt16.kind,
        UInt32.kind,
        ])
    
    public init<T : RTTI>(dataType: T.Type, count: Int, isNormalized: Bool) {
        precondition(VertexAttributeFormat.allowedFloatingPointKinds.contains(dataType.kind))
        precondition(count >= 1 && count <= 4)
        self.kind = dataType.kind
        self.count = count
        self.size = sizeof(dataType) * count
        self.isFloatingPoint = true
        self.isNormalized = isNormalized
    }
    
    public init<T : RTTI>(integerType: T.Type, count: Int) {
        precondition(VertexAttributeFormat.allowedIntegerKinds.contains(integerType.kind))
        precondition(count >= 1 && count <= 4)
        self.kind = integerType.kind
        self.count = count
        self.size = sizeof(integerType) * count
        self.isFloatingPoint = false
        self.isNormalized = false
    }
}

extension Float : RTTI {
    public static var kind = Kind(dataType: Float.self)
}

extension Double : RTTI {
    public static var kind = Kind(dataType: Double.self)
}

extension Int8 : RTTI {
    public static var kind = Kind(dataType: Int8.self)
}

extension Int16 : RTTI {
    public static var kind = Kind(dataType: Int16.self)
}

extension Int32 : RTTI {
    public static var kind = Kind(dataType: Int32.self)
}

extension UInt8 : RTTI {
    public static var kind = Kind(dataType: UInt8.self)
}

extension UInt16 : RTTI {
    public static var kind = Kind(dataType: UInt16.self)
}

extension UInt32 : RTTI {
    public static var kind = Kind(dataType: UInt32.self)
}

public struct Int1010102 : Comparable, Equatable, Hashable, CustomStringConvertible, RTTI {
    public static var kind = Kind(dataType: Int1010102.self)
    public let bits: UInt32
    
    public init() {
        self.bits = UInt32()
    }
    
    public init(_ value: UInt32) {
        self.bits = UInt32(value)
    }
    
    public init(bigEndian value: UInt32) {
        self.bits = UInt32(bigEndian: value)
    }
    
    public init(littleEndian value: UInt32) {
        self.bits = UInt32(littleEndian: value)
    }
    
    public var bigEndian: UInt32 {
        return bits.bigEndian
    }
    
    public var littleEndian: UInt32 {
        return bits.littleEndian
    }
    
    public var byteSwapped: UInt32 {
        return bits.byteSwapped
    }
    
    public var hashValue: Int {
        return bits.hashValue
    }
    
    public var description: String {
        return bits.description
    }
}

public func ==(a: Int1010102, b: Int1010102) -> Bool {
    return a.bits == b.bits
}

public func <(a: Int1010102, b: Int1010102) -> Bool {
    return a.bits < b.bits
}

public struct UInt1010102 : Comparable, Equatable, Hashable, CustomStringConvertible, RTTI {
    public static var kind = Kind(dataType: UInt1010102.self)
    public let bits: UInt32
    
    public init() {
        self.bits = UInt32()
    }
    
    public init(_ value: UInt32) {
        self.bits = UInt32(value)
    }
    
    public init(bigEndian value: UInt32) {
        self.bits = UInt32(bigEndian: value)
    }
    
    public init(littleEndian value: UInt32) {
        self.bits = UInt32(littleEndian: value)
    }
    
    public var bigEndian: UInt32 {
        return bits.bigEndian
    }
    
    public var littleEndian: UInt32 {
        return bits.littleEndian
    }
    
    public var byteSwapped: UInt32 {
        return bits.byteSwapped
    }
    
    public var hashValue: Int {
        return bits.hashValue
    }
    
    public var description: String {
        return bits.description
    }
}

public func ==(a: UInt1010102, b: UInt1010102) -> Bool {
    return a.bits == b.bits
}

public func <(a: UInt1010102, b: UInt1010102) -> Bool {
    return a.bits < b.bits
}
