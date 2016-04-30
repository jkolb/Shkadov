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

public struct TreePointer : Equatable, CustomStringConvertible {
    private var value: Int32
    
    public init() {
        self.value = 0
    }
    
    public init(node: Int) {
        precondition(node >= 0)
        precondition(node < Int(Int32.max))
        self.value = +Int32(node) + 1
    }
    
    public init(leaf: Int) {
        precondition(leaf >= 0)
        precondition(leaf < Int(Int32.max))
        self.value = -Int32(leaf) - 1
    }
    
    public var index: Int {
        if value < 0 {
            return -Int(value + 1)
        }
        else {
            return +Int(value - 1)
        }
    }
    
    public var isLeaf: Bool {
        return value < 0
    }
    
    public var isNull: Bool {
        return value == 0
    }
    
    public var description: String {
        return isLeaf ? "leaf(\(index))" : "node(\(index))"
    }
}

extension Array {
    public subscript (treePointer: TreePointer) -> Element {
        get {
            return self[treePointer.index]
        }
        set {
            self[treePointer.index] = newValue
        }
    }
}

public func ==(lhs: TreePointer, rhs: TreePointer) -> Bool {
    return lhs.value == rhs.value
}
