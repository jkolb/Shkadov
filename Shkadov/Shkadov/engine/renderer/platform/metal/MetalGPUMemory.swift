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

public final class MetalGPUMemory : GPUMemory {
    private let device: MTLDevice
    private let perFrameCount: Int
    
    public init(device: MTLDevice, perFrameCount: Int) {
        self.device = device
        self.perFrameCount = perFrameCount
    }
    
    public func bufferWithSize(size: Int, storageMode: GPUStorageMode) -> GPUBuffer {
        let options = metalResourceOptionsForStorageMode(storageMode)
        let alignedSize = ByteSize(size).align(16)
        let metalBuffer = device.newBufferWithLength(alignedSize.numberOfBytes, options: options)
        return MetalGPUBuffer(buffer: metalBuffer)
    }
    
    public func bufferWithBytes(bytes: UnsafePointer<Void>, size: Int, storageMode: GPUStorageMode) -> GPUBuffer {
        let options = metalResourceOptionsForStorageMode(storageMode)
        let metalBuffer = device.newBufferWithBytes(bytes, length: size, options: options)
        return MetalGPUBuffer(buffer: metalBuffer)
    }
    
    public func bufferWithBytesNoCopy(mutableBytes: UnsafeMutablePointer<Void>, size: Int, storageMode: GPUStorageMode, deallocator: ((UnsafeMutablePointer<Void>, Int) -> Void)?) -> GPUBuffer {
        let options = metalResourceOptionsForStorageMode(storageMode)
        let metalBuffer = device.newBufferWithBytesNoCopy(mutableBytes, length: size, options: options, deallocator: deallocator)
        return MetalGPUBuffer(buffer: metalBuffer)
    }

    public func perFrameBufferWithSize(size: Int, storageMode: GPUStorageMode) -> GPUPerFrameBuffer {
        var buffers = [GPUBuffer]()
        buffers.reserveCapacity(perFrameCount)
        
        for _ in 0..<perFrameCount {
            let buffer = bufferWithSize(size, storageMode: storageMode)
            buffers.append(buffer)
        }
        
        return GPUPerFrameBuffer(buffers: buffers)
    }
    
    public func textureWithDescriptor(textureDescriptor: TextureDescriptor) -> Texture {
        let metalTextureDescriptor = MetalTextureDescriptorMapper.map(textureDescriptor)
        let metalTexture = device.newTextureWithDescriptor(metalTextureDescriptor)
        return MetalTexture(texture: metalTexture)
    }
    
    private func metalResourceOptionsForStorageMode(storageMode: GPUStorageMode) -> MTLResourceOptions {
        switch storageMode {
        case .Shared:
            return .StorageModeShared
        case .Managed:
            return .StorageModeManaged
        case .Private:
            return .StorageModePrivate
        }
    }
}
