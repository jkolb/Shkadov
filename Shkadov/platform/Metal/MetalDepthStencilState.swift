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

public final class MetalDepthStencilStateOwner : DepthStencilStateOwner {
    private unowned(unsafe) let device: MTLDevice
    private var depthStencilStates: [MTLDepthStencilState?]
    
    public init(device: MTLDevice) {
        self.device = device
        self.depthStencilStates = []
        
        depthStencilStates.reserveCapacity(16)
    }
    
    public func createDepthStencilState(descriptor: DepthStencilDescriptor) -> DepthStencilStateHandle {
        depthStencilStates.append(device.makeDepthStencilState(descriptor: map(descriptor)))
        return DepthStencilStateHandle(key: UInt8(depthStencilStates.count))
    }
    
    public func destroyDepthStencilState(handle: DepthStencilStateHandle) {
        depthStencilStates[handle.index] = nil
    }
    
    internal subscript (handle: DepthStencilStateHandle) -> MTLDepthStencilState {
        return depthStencilStates[handle.index]!
    }
    
    private func map(_ descriptor: DepthStencilDescriptor) -> MTLDepthStencilDescriptor {
        let metalDescriptor = MTLDepthStencilDescriptor()
        metalDescriptor.depthCompareFunction = MetalDataTypes.map(descriptor.depthCompareFunction)
        metalDescriptor.isDepthWriteEnabled = descriptor.isDepthWriteEnabled
        metalDescriptor.frontFaceStencil = map(descriptor.frontFaceStencil)
        metalDescriptor.backFaceStencil = map(descriptor.backFaceStencil)
        return metalDescriptor
    }
    
    private func map(_ descriptor: StencilDescriptor) -> MTLStencilDescriptor {
        let metalDescriptor = MTLStencilDescriptor()
        metalDescriptor.stencilCompareFunction = MetalDataTypes.map(descriptor.stencilCompareFunction)
        metalDescriptor.stencilFailureOperation = map(descriptor.stencilFailureOperation)
        metalDescriptor.depthFailureOperation = map(descriptor.depthFailureOperation)
        metalDescriptor.depthStencilPassOperation = map(descriptor.depthStencilPassOperation)
        metalDescriptor.readMask = descriptor.readMask
        metalDescriptor.writeMask = descriptor.writeMask
        return metalDescriptor
    }
    
    private func map(_ stencilOperation: StencilOperation) -> MTLStencilOperation {
        switch stencilOperation {
        case .keep:
            return .keep
        case .zero:
            return .zero
        case .replace:
            return .replace
        case .incrementClamp:
            return .incrementClamp
        case .decrementClamp:
            return .decrementClamp
        case .invert:
            return .invert
        case .incrementWrap:
            return .incrementWrap
        case .decrementWrap:
            return .decrementWrap
        }
    }
}
