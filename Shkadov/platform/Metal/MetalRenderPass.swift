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

public final class MetalRenderPassOwner: RenderPassOwner {
    private unowned(unsafe) let textureOwner: MetalTextureOwner
    private unowned(unsafe) let bufferOwner: MetalGPUBufferOwner
    private var renderPasses: [MTLRenderPassDescriptor?]
    
    public init(textureOwner: MetalTextureOwner, bufferOwner: MetalGPUBufferOwner) {
        self.textureOwner = textureOwner
        self.bufferOwner = bufferOwner
        self.renderPasses = []
        
        renderPasses.reserveCapacity(16)
    }
    
    public func createRenderPass(descriptor: RenderPassDescriptor) -> RenderPassHandle {
        renderPasses.append(map(descriptor))
        return RenderPassHandle(key: UInt8(renderPasses.count))
    }
    
    public func destroyRenderPass(handle: RenderPassHandle) {
        renderPasses[handle.index] = nil
    }
    
    internal subscript (handle: RenderPassHandle) -> MTLRenderPassDescriptor {
        return renderPasses[handle.index]!
    }
    
    private func map(_ descriptor: RenderPassDescriptor) -> MTLRenderPassDescriptor {
        let metalDescriptor = MTLRenderPassDescriptor()
        
        for (index, colorDescriptor) in descriptor.colorAttachments.enumerated() {
            map(colorDescriptor, metalDescriptor: metalDescriptor.colorAttachments[index], index: index)
        }
        
        map(descriptor.depthAttachment, metalDescriptor: metalDescriptor.depthAttachment)
        map(descriptor.stencilAttachment, metalDescriptor: metalDescriptor.stencilAttachment)
        metalDescriptor.renderTargetArrayLength = descriptor.renderTargetArrayLength
        
        return metalDescriptor
    }
    
    private func map(_ descriptor: RenderPassColorAttachmentDescriptor, metalDescriptor: MTLRenderPassColorAttachmentDescriptor, index: Int) {
        metalDescriptor.clearColor = map(descriptor.clearColor)
        metalDescriptor.level = descriptor.level
        metalDescriptor.slice = descriptor.slice
        metalDescriptor.depthPlane = descriptor.depthPlane
        metalDescriptor.resolveLevel = descriptor.resolveLevel
        metalDescriptor.resolveSlice = descriptor.resolveSlice
        metalDescriptor.resolveDepthPlane = descriptor.resolveDepthPlane
        metalDescriptor.loadAction = map(descriptor.loadAction)
        metalDescriptor.storeAction = map(descriptor.storeAction)
    }
    
    private func map(_ descriptor: RenderPassDepthAttachmentDescriptor, metalDescriptor: MTLRenderPassDepthAttachmentDescriptor) {
        metalDescriptor.clearDepth = Double(descriptor.clearDepth)
        metalDescriptor.level = descriptor.level
        metalDescriptor.slice = descriptor.slice
        metalDescriptor.depthPlane = descriptor.depthPlane
        metalDescriptor.resolveLevel = descriptor.resolveLevel
        metalDescriptor.resolveSlice = descriptor.resolveSlice
        metalDescriptor.resolveDepthPlane = descriptor.resolveDepthPlane
        metalDescriptor.loadAction = map(descriptor.loadAction)
        metalDescriptor.storeAction = map(descriptor.storeAction)
    }
    
    private func map(_ descriptor: RenderPassStencilAttachmentDescriptor, metalDescriptor: MTLRenderPassStencilAttachmentDescriptor) {
        metalDescriptor.clearStencil = descriptor.clearStencil
        metalDescriptor.level = descriptor.level
        metalDescriptor.slice = descriptor.slice
        metalDescriptor.depthPlane = descriptor.depthPlane
        metalDescriptor.resolveLevel = descriptor.resolveLevel
        metalDescriptor.resolveSlice = descriptor.resolveSlice
        metalDescriptor.resolveDepthPlane = descriptor.resolveDepthPlane
        metalDescriptor.loadAction = map(descriptor.loadAction)
        metalDescriptor.storeAction = map(descriptor.storeAction)
    }
    
    private func map(_ loadAction: LoadAction) -> MTLLoadAction {
        switch loadAction {
        case .dontCare:
            return .dontCare
        case .load:
            return .load
        case .clear:
            return .clear
        }
    }

    private func map(_ storeAction: StoreAction) -> MTLStoreAction {
        switch storeAction {
        case .dontCare:
            return .dontCare
        case .store:
            return .store
        case .multisampleResolve:
            return .multisampleResolve
        case .storeAndMultisampleResolve:
            return .storeAndMultisampleResolve
        case .unknown:
            return .unknown
        }
    }
    
    private func map(_ clearColor: ClearColor) -> MTLClearColor {
        return MTLClearColor(red: Double(clearColor.r), green: Double(clearColor.g), blue: Double(clearColor.b), alpha: Double(clearColor.a))
    }
}
