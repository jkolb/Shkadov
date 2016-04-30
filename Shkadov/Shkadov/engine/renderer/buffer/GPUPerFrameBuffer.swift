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

public final class GPUPerFrameBuffer : GPUBuffer {
    private var index: Int
    private let buffers: [GPUBuffer]
    
    public init(buffers: [GPUBuffer]) {
        self.index = -1
        self.buffers = buffers
    }

    private func nextIndex() -> Int {
        let next = index + 1
        
        if next >= buffers.count {
            return 0
        }
        else {
            return next
        }
    }
    
    public func nextBuffer() -> GPUBuffer {
        index = nextIndex()
        return buffers[index]
    }
    
    public func sharedBuffer() -> Buffer {
        return buffers[index].sharedBuffer()
    }
    
    public func didModifyRange(range: Range<Int>) {
        return buffers[index].didModifyRange(range)
    }
    
    public var storageMode: GPUStorageMode {
        return buffers[index].storageMode
    }
    
    public var size: Int {
        return buffers[index].size
    }
    
    public func downCast<T>(castType: T.Type) -> T {
        return buffers[index].downCast(castType)
    }
}
