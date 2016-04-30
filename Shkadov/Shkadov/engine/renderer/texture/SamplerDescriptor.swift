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

public struct SamplerDescriptor {
    public let minFilter: SamplerMinMagFilter
    public let magFilter: SamplerMinMagFilter
    public let mipFilter: SamplerMipFilter
    public let maxAnisotropy: Int
    public let sAddressMode: SamplerAddressMode
    public let tAddressMode: SamplerAddressMode
    public let rAddressMode: SamplerAddressMode
    public let normalizedCoordinates: Bool
    public let lodMinClamp: Float
    public let lodMaxClamp: Float
    public let compareFunction: CompareFunction
    
    public init(minFilter: SamplerMinMagFilter, magFilter: SamplerMinMagFilter, mipFilter: SamplerMipFilter, maxAnisotropy: Int, sAddressMode: SamplerAddressMode, tAddressMode: SamplerAddressMode, rAddressMode: SamplerAddressMode, normalizedCoordinates: Bool, lodMinClamp: Float, lodMaxClamp: Float, compareFunction: CompareFunction) {
        self.minFilter = minFilter
        self.magFilter = magFilter
        self.mipFilter = mipFilter
        self.maxAnisotropy = maxAnisotropy
        self.sAddressMode = sAddressMode
        self.tAddressMode = tAddressMode
        self.rAddressMode = rAddressMode
        self.normalizedCoordinates = normalizedCoordinates
        self.lodMinClamp = lodMinClamp
        self.lodMaxClamp = lodMaxClamp
        self.compareFunction = compareFunction
    }
}
