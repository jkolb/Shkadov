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

public enum PixelFormat {
    case invalid
    
    /* Normal 8 bit formats */
    case a8Unorm
    case r8Unorm
    case r8Snorm
    case r8Uint
    case r8Sint
    
    /* Normal 16 bit formats */
    case r16Unorm
    case r16Snorm
    case r16Uint
    case r16Sint
    case r16Float

    case rg8Unorm
    case rg8Snorm
    case rg8Uint
    case rg8Sint
    
    /* Normal 32 bit formats */
    case r32Uint
    case r32Sint
    case r32Float
    
    case rg16Unorm
    case rg16Snorm
    case rg16Uint
    case rg16Sint
    case rg16Float
    
    case rgba8Unorm
    case rgba8Unorm_srgb
    case rgba8Snorm
    case rgba8Uint
    case rgba8Sint
    
    case bgra8Unorm
    case bgra8Unorm_srgb
    
    /* Packed 32 bit formats */
    case rgb10a2Unorm
    case rgb10a2Uint
    
    case rg11b10Float
    case rgb9e5Float
    
    /* Normal 64 bit formats */
    case rg32Uint
    case rg32Sint
    case rg32Float
    
    case rgba16Unorm
    case rgba16Snorm
    case rgba16Uint
    case rgba16Sint
    case rgba16Float
    
    /* Normal 128 bit formats */
    case rgba32Uint
    case rgba32Sint
    case rgba32Float
    
    
    /* Compressed formats. */
    
    /* S3TC/DXT */
    case bc1_rgba
    case bc1_rgba_srgb
    case bc2_rgba
    case bc2_rgba_srgb
    case bc3_rgba
    case bc3_rgba_srgb
    
    /* RGTC */
    case bc4_rUnorm
    case bc4_rSnorm
    case bc5_rgUnorm
    case bc5_rgSnorm
    
    /* BPTC */
    case bc6H_rgbFloat
    case bc6H_rgbuFloat
    case bc7_rgbaUnorm
    case bc7_rgbaUnorm_srgb
    
    case gbgr422
    case bgrg422
    
    
    /* Depth */
    case depth16Unorm
    case depth32Float
    
    /* Stencil */
    case stencil8
    
    /* Depth Stencil */
    case depth24Unorm_stencil8
    case depth32Float_stencil8

    case x32_stencil8
    case x24_stencil8
}
