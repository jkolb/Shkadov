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
import MetalKit

public class MetalSwapChain : SwapChain {
    private unowned(unsafe) let view: MTKView
    private unowned(unsafe) let textureOwner: MetalTextureOwner
    private var drawables: [CAMetalDrawable?]
    private var reclaimedHandles: [RenderTargetHandle]
    private var renderTargetTexture: [RenderTargetHandle:TextureHandle]
    
    public init(view: MTKView, textureOwner: MetalTextureOwner) {
        self.view = view
        self.textureOwner = textureOwner
        self.drawables = []
        self.reclaimedHandles = []
        self.renderTargetTexture = [RenderTargetHandle:TextureHandle](minimumCapacity: 2)
        
        drawables.reserveCapacity(4)
        reclaimedHandles.reserveCapacity(2)
    }
    
    public func acquireNextRenderTarget() -> RenderTargetHandle {
        if let drawable = view.currentDrawable {
            if reclaimedHandles.count > 0 {
                let handle = reclaimedHandles.removeLast()
                drawables[handle.index] = drawable
                return handle
            }
            else {
                drawables.append(drawable)
                return RenderTargetHandle(key: UInt8(drawables.count))
            }
        }
        else {
            return RenderTargetHandle()
        }
    }
    
    public func textureForRenderTarget(handle: RenderTargetHandle) -> TextureHandle {
        if !handle.isValid {
            return TextureHandle()
        }
        
        if let texture = renderTargetTexture[handle] {
            return texture
        }
        else {
            let texture = textureOwner.storeTexture(self[handle].texture)
            renderTargetTexture[handle] = texture
            return texture
        }
    }
    
    public func releaseRenderTarget(handle: RenderTargetHandle) {
        if !handle.isValid {
            return
        }
        
        if let texture = renderTargetTexture.removeValue(forKey: handle) {
            textureOwner.destroyTexture(handle: texture)
        }
        
        reclaimedHandles.append(handle)
        drawables[handle.index] = nil
    }
    
    internal subscript (handle: RenderTargetHandle) -> CAMetalDrawable {
        return drawables[handle.index]!
    }
}
