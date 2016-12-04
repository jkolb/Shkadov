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
    private let device: MTLDevice
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
    
    private func map(_ samplerDescriptor: SamplerDescriptor) -> MTLSamplerDescriptor {
        let metalDescriptor = MTLSamplerDescriptor()
        
        return metalDescriptor
    }
}
