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

public final class BinaryTree<Split, Leaf> {
    private let node: [BinaryNode<Split>]
    private let leaf: [Leaf]
    
    public convenience init() {
        self.init(node: [], leaf: [])
    }
    
    public init(node: [BinaryNode<Split>], leaf: [Leaf]) {
        self.node = node
        self.leaf = leaf
    }

    public convenience init(leaf: [Leaf], @noescape splitBuilder: (leafPointers: [TreePointer], leaf: [Leaf]) -> Split, @noescape splitter: (split: Split, leafPointers: [TreePointer], leaf: [Leaf]) -> ([TreePointer], [TreePointer])) {
        if leaf.isEmpty {
            self.init()
            return
        }
        
        let leafPointers = (0..<leaf.count).map({ TreePointer(leaf: $0) })
        let rootSplit = splitBuilder(leafPointers: leafPointers, leaf: leaf)
        let rootNode = BinaryNode<Split>(split: rootSplit)
        var node = [rootNode]
        node.reserveCapacity(leaf.count - 1)
        BinaryTree.topDownBuild(&node, leaf: leaf, nodePointer: TreePointer(node: 0), leafPointers: leafPointers, splitBuilder: splitBuilder, splitter: splitter)
        let reorderedLeaf = BinaryTree.reoder(leaf, node: node)
        self.init(node: node, leaf: reorderedLeaf)
    }
    
    private static func topDownBuild(inout node: [BinaryNode<Split>], leaf: [Leaf], nodePointer: TreePointer, leafPointers: [TreePointer], @noescape splitBuilder: (leafPointers: [TreePointer], leaf: [Leaf]) -> Split, @noescape splitter: (split: Split, leafPointers: [TreePointer], leaf: [Leaf]) -> ([TreePointer], [TreePointer])) {
        let split = node[nodePointer].split
        let splitLeafPointers = splitter(split: split, leafPointers: leafPointers, leaf: leaf)
        let negativeLeafPointers = splitLeafPointers.0
        let positiveLeafPointers = splitLeafPointers.1
        
        if negativeLeafPointers.count == 1 {
            node[nodePointer].negative = negativeLeafPointers[0]
        }
        else if negativeLeafPointers.count > 0 {
            let negativeSplit = splitBuilder(leafPointers: negativeLeafPointers, leaf: leaf)
            let negativeNode = BinaryNode<Split>(split: negativeSplit)
            let negativePointer = TreePointer(node: node.count)
            node[nodePointer].negative = negativePointer
            node.append(negativeNode)
            topDownBuild(&node, leaf: leaf, nodePointer: negativePointer, leafPointers: negativeLeafPointers, splitBuilder: splitBuilder, splitter: splitter)
        }
        
        if positiveLeafPointers.count == 1 {
            node[nodePointer].positive = positiveLeafPointers[0]
        }
        else if positiveLeafPointers.count > 0 {
            let positiveSplit = splitBuilder(leafPointers: positiveLeafPointers, leaf: leaf)
            let positiveNode = BinaryNode<Split>(split: positiveSplit)
            let positivePointer = TreePointer(node: node.count)
            node[nodePointer].positive = positivePointer
            node.append(positiveNode)
            topDownBuild(&node, leaf: leaf, nodePointer: positivePointer, leafPointers: positiveLeafPointers, splitBuilder: splitBuilder, splitter: splitter)
        }
    }
    
    private static func reoder(leaf: [Leaf], node: [BinaryNode<Split>]) -> [Leaf] {
        var reordered = [Leaf]()
        reordered.reserveCapacity(leaf.count)
        
        for var currentNode in node {
            if currentNode.negative.isLeaf {
                currentNode.negative = TreePointer(leaf: reordered.count)
                reordered.append(leaf[currentNode.negative])
            }
            
            if currentNode.positive.isLeaf {
                currentNode.positive = TreePointer(leaf: reordered.count)
                reordered.append(leaf[currentNode.positive])
            }
        }
        
        return reordered
    }

    public func filter<Separator>(separator: Separator, @noescape testNode: (Separator, Split) -> Bool, @noescape testLeaf: (Separator, Leaf) -> Bool) -> [Leaf] {
        if node.isEmpty || leaf.isEmpty {
            return []
        }
        
        var filteredLeaf = [Leaf]()
        var stack = [BinaryNode<Split>]()
        stack.append(node[0])
        
        while !stack.isEmpty {
            let parentNode = stack.popLast()!
            
            if testNode(separator, parentNode.split) {
                if parentNode.negative.isLeaf {
                    let negativeLeaf = leaf[parentNode.negative]
                    if testLeaf(separator, negativeLeaf) {
                        filteredLeaf.append(negativeLeaf)
                    }
                }
                else if !parentNode.negative.isNull {
                    let negativeNode = node[parentNode.negative]
                    stack.append(negativeNode)
                }
                
                if parentNode.positive.isLeaf {
                    let positiveLeaf = leaf[parentNode.positive]
                    if testLeaf(separator, positiveLeaf) {
                        filteredLeaf.append(positiveLeaf)
                    }
                }
                else if !parentNode.positive.isNull {
                    let positiveNode = node[parentNode.positive]
                    stack.append(positiveNode)
                }
            }
        }
        
        return filteredLeaf
    }
}
