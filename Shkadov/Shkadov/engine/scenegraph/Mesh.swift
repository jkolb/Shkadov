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

public final class Mesh {
    private let positions: [Vector3D]
    private let indices: [Int]
    
    public convenience init() {
        self.init(positions: [], indices: [])
    }
    
    public init(positions: [Vector3D], indices: [Int]) {
        precondition(indices.count % 3 == 0)
        self.positions = positions
        self.indices = indices
    }
    
    public func transform(transform: Transform3D) -> Mesh {
        if transform.isIdentity {
            return self
        }
        
        let transformed = positions.map({ transform.applyTo($0) })
        
        return Mesh(positions: transformed, indices: indices)
    }
    
    public var triangles: [Triangle3D] {
        if positions.isEmpty || indices.isEmpty {
            return []
        }
        
        var trianglePoints = [Vector3D]()
        trianglePoints.reserveCapacity(3)
        var triangles = [Triangle3D]()
        
        for index in indices {
            trianglePoints.append(positions[index])
            
            if trianglePoints.count == 3 {
                let triangle = Triangle3D(trianglePoints[0], trianglePoints[1], trianglePoints[2])
                triangles.append(triangle)
                trianglePoints.removeAll(keepCapacity: true)
            }
        }
        
        return triangles
    }
    
    public var aabbTree: AABBTree<Triangle3D> {
        let bounds = triangles.map({ $0.bounds })
        
        return AABBTree<Triangle3D>(
            leaf: triangles,
            bounds: bounds,
            unionBounds: { (leafPointers, leaf) -> AABB in
                AABB(containingPoints: leafPointers.flatMap({ leaf[$0].points }))
            }
        )
    }
}
