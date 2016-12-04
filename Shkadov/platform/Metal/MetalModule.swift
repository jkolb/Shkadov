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

public final class MetalModuleOwner : ModuleOwner {
    private let device: MTLDevice
    private var modules: [MTLLibrary?]
    private var computeFunctions: [MTLFunction?]
    private var fragmentFunctions: [MTLFunction?]
    private var vertexFunctions: [MTLFunction?]
    
    public init(device: MTLDevice) {
        self.device = device
        self.modules = []
        self.computeFunctions = []
        self.fragmentFunctions = []
        self.vertexFunctions = []
        
        modules.reserveCapacity(8)
        computeFunctions.reserveCapacity(32)
        fragmentFunctions.reserveCapacity(32)
        vertexFunctions.reserveCapacity(32)
    }
    
    public func createModule(filepath: String) throws -> ModuleHandle {
        modules.append(try device.makeLibrary(filepath: filepath))
        return ModuleHandle(key: UInt8(modules.count))
    }
    
    public func destroyModule(handle: ModuleHandle) {
        modules[handle.index] = nil
    }
    
    internal subscript (handle: ModuleHandle) -> MTLLibrary {
        return modules[handle.index]!
    }
    
    public func createComputeFunction(module: ModuleHandle, named: String) -> ComputeFunctionHandle {
        computeFunctions.append(self[module].makeFunction(name: named)!)
        return ComputeFunctionHandle(key: UInt8(computeFunctions.count))
    }
    
    public func destroyComputeFunction(handle: ComputeFunctionHandle) {
        computeFunctions[handle.index] = nil
    }
    
    internal subscript (handle: ComputeFunctionHandle) -> MTLFunction {
        return computeFunctions[handle.index]!
    }
    
    public func createFragmentFunction(module: ModuleHandle, named: String) -> FragmentFunctionHandle {
        fragmentFunctions.append(self[module].makeFunction(name: named)!)
        return FragmentFunctionHandle(key: UInt8(fragmentFunctions.count))
    }
    
    public func destroyFragmentFunction(handle: FragmentFunctionHandle) {
        fragmentFunctions[handle.index] = nil
    }
    
    internal subscript (handle: FragmentFunctionHandle) -> MTLFunction {
        return fragmentFunctions[handle.index]!
    }
    
    public func createVertexFunction(module: ModuleHandle, named: String) -> VertexFunctionHandle {
        vertexFunctions.append(self[module].makeFunction(name: named)!)
        return VertexFunctionHandle(key: UInt8(vertexFunctions.count))
    }
    
    public func destroyVertexFunction(handle: VertexFunctionHandle) {
        vertexFunctions[handle.index] = nil
    }
    
    internal subscript (handle: VertexFunctionHandle) -> MTLFunction {
        return vertexFunctions[handle.index]!
    }
}
