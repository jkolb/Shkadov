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

public protocol ModuleOwner {
    func createModule(filepath: String) throws -> ModuleHandle
    func destroyModule(handle: ModuleHandle)

    func createComputeFunction(module: ModuleHandle, named: String) -> ComputeFunctionHandle
    func destroyComputeFunction(handle: ComputeFunctionHandle)
    
    func createFragmentFunction(module: ModuleHandle, named: String) -> FragmentFunctionHandle
    func destroyFragmentFunction(handle: FragmentFunctionHandle)
    
    func createVertexFunction(module: ModuleHandle, named: String) -> VertexFunctionHandle
    func destroyVertexFunction(handle: VertexFunctionHandle)
}

public struct ModuleHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}

public struct ComputeFunctionHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}

public struct FragmentFunctionHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}

public struct VertexFunctionHandle : Handle {
    public let key: UInt8
    
    public init() { self.init(key: 0) }
    
    public init(key: UInt8) {
        self.key = key
    }
}
