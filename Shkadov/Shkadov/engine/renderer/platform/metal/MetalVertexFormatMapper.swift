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

import Metal

public final class MetalVertexFormatMapper {
    public static func map(vertexFormat: VertexFormat) -> MTLVertexFormat {
        switch vertexFormat {
        case .Invalid:
            return .Invalid
            
        case .UInt8_2:
            return .UChar2
            
        case .UInt8_3:
            return .UChar3
            
        case .UInt8_4:
            return .UChar4
            
        case .Int8_2:
            return .Char2
            
        case .Int8_3:
            return .Char3
            
        case .Int8_4:
            return .Char4
            
        case .UInt8_Normalized_2:
            return .UChar2Normalized
            
        case .UInt8_Normalized_3:
            return .UChar3Normalized
            
        case .UInt8_Normalized_4:
            return .UChar4Normalized
            
        case .Int8_Normalized_2:
            return .Char2Normalized
            
        case .Int8_Normalized_3:
            return .Char3Normalized
            
        case .Int8_Normalized_4:
            return .Char4Normalized
            
        case .UInt16_2:
            return .UShort2
            
        case .UInt16_3:
            return .UShort3
            
        case .UInt16_4:
            return .UShort4
            
        case .Int16_2:
            return .Short2
            
        case .Int16_3:
            return .Short3
            
        case .Int16_4:
            return .Short4
            
        case .UInt16_Normalized_2:
            return .UShort2Normalized
            
        case .UInt16_Normalized_3:
            return .UShort3Normalized
            
        case .UInt16_Normalized_4:
            return .UShort4Normalized
            
        case .Int16_Normalized_2:
            return .Short2Normalized
            
        case .Int16_Normalized_3:
            return .Short3Normalized
            
        case .Int16_Normalized_4:
            return .Short4Normalized
            
        case .UInt32:
            return .UInt
            
        case .UInt32_2:
            return .UInt2
            
        case .UInt32_3:
            return .UInt3
            
        case .UInt32_4:
            return .UInt4
            
        case .Int32:
            return .Int
            
        case .Int32_2:
            return .Int2
            
        case .Int32_3:
            return .Int3
            
        case .Int32_4:
            return .Int4
            
        case .Float16_2:
            return .Half2
            
        case .Float16_3:
            return .Half3
            
        case .Float16_4:
            return .Half4
            
        case .Float32:
            return .Float
            
        case .Float32_2:
            return .Float2
            
        case .Float32_3:
            return .Float3
            
        case .Float32_4:
            return .Float4
            
        case .UInt_10_10_10_2_Normalized:
            return .UInt1010102Normalized
            
        case .Int_10_10_10_2_Normalized:
            return .Int1010102Normalized
        }
    }
    
    public static func map(vertexFormat: MTLVertexFormat) -> VertexFormat {
        fatalError("Not implemented")
    }
}
