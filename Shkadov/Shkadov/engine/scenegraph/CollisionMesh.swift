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

public final class CollisionMesh {
    private let mesh: Mesh
    private var tree: AABBTree<Triangle3D>
    
    public convenience init() {
        self.init(mesh: Mesh())
    }
    
    public init(mesh: Mesh) {
        self.mesh = mesh
        self.tree = mesh.aabbTree
    }
    
    public func transform(transform: Transform3D) {
        tree = mesh.transform(transform).aabbTree
    }
    
    public func filter(ray: Ray3D) -> [Triangle3D] {
        return tree.filter(
            ray,
            testNode: {
                intersectTest($0, $1) || insideTest($0.origin, $1)
            },
            testLeaf: {
                intersectTest($0, $1)
            }
        )
    }
}
