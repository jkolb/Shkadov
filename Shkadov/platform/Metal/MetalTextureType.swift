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

public final class MetalTextureType {
    public static func map(_ textureType: TextureType) -> MTLTextureType {
        switch textureType {
        case .type1D:
            return .type1D
        case .type2D:
            return .type2D
        case .type3D:
            return .type3D
        }
    }
    
    public static func map(_ textureType: MTLTextureType) -> TextureType {
        switch textureType {
        case .type1D:
            return .type1D
        case .type1DArray:
            return .type1D
        case .type2D:
            return .type2D
        case .type2DArray:
            return .type2D
        case .type2DMultisample:
            return .type2D
        case .typeCube:
            return .type2D
        case .typeCubeArray:
            return .type2D
        case .type3D:
            return .type3D
        }
    }
}
