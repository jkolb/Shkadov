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

public final class MetalSamplerOwner : SamplerOwner {
    private unowned(unsafe) let device: MTLDevice
    private var samplers: [MTLSamplerState?]
    
    public init(device: MTLDevice) {
        self.device = device
        self.samplers = []
        
        samplers.reserveCapacity(128)
    }
    
    public func createSampler(descriptor: SamplerDescriptor) -> SamplerHandle {
        samplers.append(device.makeSamplerState(descriptor: map(descriptor)))
        return SamplerHandle(key: UInt16(samplers.count))
    }
    
    public func destroySampler(handle: SamplerHandle) {
        samplers[handle.index] = nil
    }

    internal subscript (handle: SamplerHandle) -> MTLSamplerState {
        return samplers[handle.index]!
    }
    
    private func map(_ descriptor: SamplerDescriptor) -> MTLSamplerDescriptor {
        let metalDescriptor = MTLSamplerDescriptor()
        metalDescriptor.minFilter = map(descriptor.minFilter)
        metalDescriptor.magFilter = map(descriptor.magFilter)
        metalDescriptor.mipFilter = map(descriptor.mipFilter)
        metalDescriptor.maxAnisotropy = descriptor.maxAnisotropy
        metalDescriptor.sAddressMode = map(descriptor.sAddressMode)
        metalDescriptor.tAddressMode = map(descriptor.tAddressMode)
        metalDescriptor.rAddressMode = map(descriptor.rAddressMode)
        metalDescriptor.borderColor = map(descriptor.borderColor)
        metalDescriptor.normalizedCoordinates = descriptor.normalizedCoordinates
        metalDescriptor.lodMinClamp = descriptor.lodMinClamp
        metalDescriptor.lodMaxClamp = descriptor.lodMaxClamp
        metalDescriptor.compareFunction = MetalDataTypes.map(descriptor.compareFunction)
        return metalDescriptor
    }
    
    private func map(_ minMagFilter: SamplerMinMagFilter) -> MTLSamplerMinMagFilter {
        switch minMagFilter {
        case .nearest:
            return .nearest
        case .linear:
            return .linear
        }
    }
    
    private func map(_ mipFilter: SamplerMipFilter) -> MTLSamplerMipFilter {
        switch mipFilter {
        case .notMipmapped:
            return .notMipmapped
        case .nearest:
            return .nearest
        case .linear:
            return .linear
        }
    }
    
    private func map(_ addressMode: SamplerAddressMode) -> MTLSamplerAddressMode {
        switch addressMode {
        case .clampToEdge:
            return .clampToEdge
        case .mirrorClampToEdge:
            return .mirrorClampToEdge
        case .repeat:
            return .repeat
        case .mirrorRepeat:
            return .mirrorRepeat
        case .clampToZero:
            return .clampToZero
        case .clampToBorderColor:
            return .clampToBorderColor
        }
    }
    
    private func map(_ borderColor: SamplerBorderColor) -> MTLSamplerBorderColor {
        switch borderColor {
        case .transparentBlack:
            return .transparentBlack
        case .opaqueBlack:
            return .opaqueBlack
        case .opaqueWhite:
            return .opaqueWhite
        }
    }
}
