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

public final class MetalGPUBufferOwner : GPUBufferOwner {
    private let device: MTLDevice
    private var buffers: [MTLBuffer?]
    
    public init(device: MTLDevice) {
        self.device = device
        self.buffers = []
        buffers.reserveCapacity(128)
    }
    
    public func createBuffer(count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        buffers.append(device.makeBuffer(length: count, options: map(storageMode)))
        return GPUBufferHandle(key: UInt16(buffers.count))
    }
    
    public func createBuffer(bytes: UnsafeRawPointer, count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        buffers.append(device.makeBuffer(bytes: bytes, length: count, options: map(storageMode)))
        return GPUBufferHandle(key: UInt16(buffers.count))
    }
    
    public func createBuffer(bytesNoCopy: UnsafeMutableRawPointer, count: Int, storageMode: StorageMode) -> GPUBufferHandle {
        buffers.append(device.makeBuffer(bytesNoCopy: bytesNoCopy, length: count, options: map(storageMode), deallocator: nil))
        return GPUBufferHandle(key: UInt16(buffers.count))
    }
    
    public func borrowBuffer(handle: GPUBufferHandle) -> GPUBuffer {
        return MetalGPUBuffer(handle: handle, instance: self[handle])
    }
    
    public func destroyBuffer(handle: GPUBufferHandle) {
        buffers[Int(handle.key)] = nil
    }
    
    internal subscript (handle: GPUBufferHandle) -> MTLBuffer {
        return buffers[Int(handle.key)]!
    }
    
    private func map(_ storageMode: StorageMode) -> MTLResourceOptions {
        switch storageMode {
        case .sharedWithCPU:
            return .storageModeShared
        case .unsafeSharedWithCPU:
            return .storageModeManaged
        case .privateToGPU:
            return .storageModePrivate
        }
    }
}
