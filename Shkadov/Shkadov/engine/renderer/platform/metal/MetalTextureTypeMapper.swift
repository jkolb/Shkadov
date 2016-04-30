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

public final class MetalTextureTypeMapper {
    public static func map(textureType: TextureType) -> MTLTextureType {
        switch textureType {
        case .OneDimensional:
            return .Type1D
        case .TwoDimensional:
            return .Type2D
        case .ThreeDimensional:
            return .Type3D
        }
    }
    
    public static func map(textureType: MTLTextureType) -> TextureType {
        switch textureType {
        case .Type1D:
            return .OneDimensional
        case .Type1DArray:
            return .OneDimensional
        case .Type2D:
            return .TwoDimensional
        case .Type2DArray:
            return .TwoDimensional
        case .Type2DMultisample:
            return .TwoDimensional
        case .TypeCube:
            return .TwoDimensional
        case .TypeCubeArray:
            return .TwoDimensional
        case .Type3D:
            return .ThreeDimensional
        }
    }
}
