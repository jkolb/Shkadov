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

public enum VertexFormat {
    case Invalid
    
    case UInt8_2
    case UInt8_3
    case UInt8_4

    case Int8_2
    case Int8_3
    case Int8_4

    case UInt8_Normalized_2
    case UInt8_Normalized_3
    case UInt8_Normalized_4
    
    case Int8_Normalized_2
    case Int8_Normalized_3
    case Int8_Normalized_4

    case UInt16_2
    case UInt16_3
    case UInt16_4
    
    case Int16_2
    case Int16_3
    case Int16_4
    
    case UInt16_Normalized_2
    case UInt16_Normalized_3
    case UInt16_Normalized_4
    
    case Int16_Normalized_2
    case Int16_Normalized_3
    case Int16_Normalized_4

    case UInt32
    case UInt32_2
    case UInt32_3
    case UInt32_4

    case Int32
    case Int32_2
    case Int32_3
    case Int32_4

    case Float16_2
    case Float16_3
    case Float16_4
    
    case Float32
    case Float32_2
    case Float32_3
    case Float32_4
    
    case UInt_10_10_10_2_Normalized
    case Int_10_10_10_2_Normalized
}
