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

public struct IndexVertexPNT1 : Hashable {
    public let positionIndex: Int
    public let normalIndex: Int
    public let texcoordIndex: Int
    
    public init(positionIndex: Int, normalIndex: Int, texcoordIndex: Int) {
        self.positionIndex = positionIndex
        self.normalIndex = normalIndex
        self.texcoordIndex = texcoordIndex
    }
    
    public var hashValue: Int {
        let totalNumberOfBits = sizeof(Int) * 8
        let bitsPerItem = totalNumberOfBits / 3 // PNT1
        let positionShift = bitsPerItem * 2
        let normalShift = bitsPerItem * 1
        let texcoordShift = bitsPerItem * 0
        return (positionIndex << positionShift) ^ (normalIndex << normalShift) ^ (texcoordIndex << texcoordShift)
    }
}

public func ==(lhs: IndexVertexPNT1, rhs: IndexVertexPNT1) -> Bool {
    return (lhs.positionIndex == rhs.positionIndex) && (lhs.normalIndex == rhs.normalIndex) && (lhs.texcoordIndex == rhs.texcoordIndex)
}
