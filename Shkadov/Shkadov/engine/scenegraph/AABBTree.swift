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

public final class AABBTree<Leaf> {
    private let tree: BinaryTree<AABB, Leaf>
    
    public init() {
        self.tree = BinaryTree<AABB, Leaf>()
    }
    
    public init(leaf: [Leaf], bounds: [AABB], @noescape unionBounds: (leafPointers: [TreePointer], leaf: [Leaf]) -> AABB) {
        self.tree = BinaryTree<AABB, Leaf>(
            leaf: leaf,
            splitBuilder: unionBounds,
            splitter: { (split, leafPointers, leaf) -> ([TreePointer], [TreePointer]) in
                let maxAxis = split.radius.maximum
                let negativeLeafPointers: [TreePointer]
                let positiveLeafPointers: [TreePointer]
                
                if split.radius.x == maxAxis {
                    let midpoint = split.center.x
                    let sortedLeafPointers = leafPointers.sort({ bounds[$0.0].center.x < bounds[$0.1].center.x })
                    
                    if let splitIndex = sortedLeafPointers.indexOf({ bounds[$0].center.x > midpoint }) {
                        negativeLeafPointers = Array(sortedLeafPointers[0..<splitIndex])
                        positiveLeafPointers = Array(sortedLeafPointers[splitIndex..<sortedLeafPointers.count])
                    }
                    else {
                        let medianSplit = sortedLeafPointers.count / 2
                        negativeLeafPointers = Array(sortedLeafPointers[0..<medianSplit])
                        positiveLeafPointers = Array(sortedLeafPointers[medianSplit..<sortedLeafPointers.count])
                    }
                }
                else if split.radius.y == maxAxis {
                    let midpoint = split.center.y
                    let sortedLeafPointers = leafPointers.sort({ bounds[$0.0].center.y < bounds[$0.1].center.y })
                    
                    if let splitIndex = sortedLeafPointers.indexOf({ bounds[$0].center.y > midpoint }) {
                        negativeLeafPointers = Array(sortedLeafPointers[0..<splitIndex])
                        positiveLeafPointers = Array(sortedLeafPointers[splitIndex..<sortedLeafPointers.count])
                    }
                    else {
                        let medianSplit = sortedLeafPointers.count / 2
                        negativeLeafPointers = Array(sortedLeafPointers[0..<medianSplit])
                        positiveLeafPointers = Array(sortedLeafPointers[medianSplit..<sortedLeafPointers.count])
                    }
                }
                else {
                    let midpoint = split.center.z
                    let sortedLeafPointers = leafPointers.sort({ bounds[$0.0].center.z < bounds[$0.1].center.z })
                    
                    if let splitIndex = sortedLeafPointers.indexOf({ bounds[$0].center.z > midpoint }) {
                        negativeLeafPointers = Array(sortedLeafPointers[0..<splitIndex])
                        positiveLeafPointers = Array(sortedLeafPointers[splitIndex..<sortedLeafPointers.count])
                    }
                    else {
                        let medianSplit = sortedLeafPointers.count / 2
                        negativeLeafPointers = Array(sortedLeafPointers[0..<medianSplit])
                        positiveLeafPointers = Array(sortedLeafPointers[medianSplit..<sortedLeafPointers.count])
                    }
                }
                
                return (negativeLeafPointers, positiveLeafPointers)
            }
        )
    }
    
    public func filter<Separator>(separator: Separator, @noescape testNode: (Separator, AABB) -> Bool, @noescape testLeaf: (Separator, Leaf) -> Bool) -> [Leaf] {
        return tree.filter(separator, testNode: testNode, testLeaf: testLeaf)
    }
}
