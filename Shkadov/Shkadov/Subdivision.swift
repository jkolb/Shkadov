/*
The MIT License (MIT)

Copyright (c) 2015 Justin Kolb

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

import Foundation

public struct Edge : Hashable {
    public let a: Int
    public let b: Int
    
    public init(_ a: Int, _ b: Int) {
        self.a = min(a, b)
        self.b = max(a, b)
    }
    
    public var hashValue: Int {
        return a.hashValue ^ b.hashValue
    }
}

public func ==(lhs: Edge, rhs: Edge) -> Bool {
    return lhs.a == rhs.a && rhs.b == lhs.b
}

public struct Triangle {
    public let a: Int
    public let b: Int
    public let c: Int
    
    public init(_ a: Int, _ b: Int, _ c: Int) {
        self.a = a
        self.b = b
        self.c = c
    }
}

public final class Surface {
    private var vertices: [Vector3D]
    private var faces: [Triangle]
    
    public init(reserveCapacity: Int) {
        self.vertices = [float3]()
        self.faces = [Triangle]()
        self.vertices.reserveCapacity(reserveCapacity)
        self.faces.reserveCapacity(reserveCapacity)
    }
    
    public func allVertices() -> [Vector3D] {
        return vertices
    }
    
    public func allFaces() -> [Triangle] {
        return faces
    }
    
    public func addVertex(vertex: Vector3D) -> Int {
        let index = vertices.count
        vertices.append(vertex)
        return index
    }
    
    public func addFace(a: Int, _ b: Int, _ c: Int) {
        faces.append(Triangle(a, b, c))
    }
    
    public func triangles() -> [Triangle3D] {
        var triangles = [Triangle3D]()
        
        for face in faces {
            let triangle = Triangle3D(vertices[face.a].point, vertices[face.b].point, vertices[face.c].point)
            triangles.append(triangle)
        }
        
        return triangles
    }
    
    public func subdivide(count: Int) -> Surface {
        if count == 0 {
            return self
        }
        else {
            return subdivide().subdivide(count - 1)
        }
    }
    
    public func subdivide() -> Surface {
        NSLog("START: \(faces.count)")
        let subdividedSurface = Surface(reserveCapacity: faces.count * 4)
        var edgeMidpoint = [Edge:Vector3D](minimumCapacity: faces.count * 4 * 3 / 2)

        for face in faces {
            let a = vertices[face.a]
            let b = vertices[face.b]
            let c = vertices[face.c]

            let AB = Edge(face.a, face.b)
            let BC = Edge(face.b, face.c)
            let CA = Edge(face.c, face.a)
            
            let ab = edgeMidpoint[AB] ?? (a + b) * 0.5
            let bc = edgeMidpoint[BC] ?? (b + c) * 0.5
            let ca = edgeMidpoint[CA] ?? (c + a) * 0.5

            edgeMidpoint[AB] = ab
            edgeMidpoint[BC] = bc
            edgeMidpoint[CA] = ca
            
            let i0 = subdividedSurface.addVertex(a)
            let i1 = subdividedSurface.addVertex(ab)
            let i2 = subdividedSurface.addVertex(ca)
            let i3 = subdividedSurface.addVertex(b)
            let i4 = subdividedSurface.addVertex(bc)
            let i5 = subdividedSurface.addVertex(c)
            
            subdividedSurface.addFace(i0, i1, i2)
            subdividedSurface.addFace(i1, i3, i4)
            subdividedSurface.addFace(i1, i4, i2)
            subdividedSurface.addFace(i2, i4, i5)
        }
        
        NSLog("END: \(faces.count)")

        return subdividedSurface
    }
    
    public func subdivideBy(divisions: Int) -> Surface {
        let subdividedSurface = Surface(reserveCapacity: faces.count * (divisions * divisions))
        let edgeVertexCount = divisions + 1
        let delta = 1.0 / Float(divisions)

        var pAB = [Vector3D]()
        var pAC = [Vector3D]()
        var rows = [[Int]]()
        
        pAB.reserveCapacity(edgeVertexCount)
        pAC.reserveCapacity(edgeVertexCount)
        rows.reserveCapacity(edgeVertexCount)
        
        for face in faces {
            let a = vertices[face.a]
            let b = vertices[face.b]
            let c = vertices[face.c]
            
            let deltaAB = (b - a) * delta
            let deltaAC = (c - a) * delta
            
            var nextAB = a
            var nextAC = a

            for _ in 0..<divisions {
                pAB.append(nextAB)
                pAC.append(nextAC)
                
                nextAB += deltaAB
                nextAC += deltaAC
            }
            
            pAB.append(b)
            pAC.append(c)

            for row in 0..<edgeVertexCount {
                var rowIndices = [Int]()
                rowIndices.reserveCapacity(row + 1)
                
                let rb = pAB[row]
                let rc = pAC[row]
                let rowDelta = 1.0 / Float(row)
                let deltaBC = (rc - rb) * rowDelta
                var nextBC = rb
                
                for _ in 0..<row {
                    let index = subdividedSurface.addVertex(nextBC)
                    rowIndices.append(index)
                    nextBC += deltaBC
                }

                let lastIndex = subdividedSurface.addVertex(rc)
                rowIndices.append(lastIndex)
                rows.append(rowIndices)
            }
            
            for rowIndex in 0..<divisions {
                let U = rows[rowIndex]
                let L = rows[rowIndex + 1]
                let lastIndex = U.count - 1
                
                for colIndex in 0..<lastIndex {
                    subdividedSurface.addFace(U[colIndex], L[colIndex], L[colIndex + 1])
                    subdividedSurface.addFace(U[colIndex], L[colIndex + 1], U[colIndex + 1])
                }
                
                subdividedSurface.addFace(U[lastIndex], L[lastIndex], L[lastIndex + 1])
            }
            
            pAB.removeAll(keepCapacity: true)
            pAC.removeAll(keepCapacity: true)
            rows.removeAll(keepCapacity: true)
        }

        return subdividedSurface
    }
    
    public static func icosahedron(size: Float) -> Surface {
        let goldenRatio = (1.0 + sqrtf(5.0)) / 2.0
        let g = Vector3D(0.0, 1.0, goldenRatio) * size
        
        let s = g.y * 0.5
        let l = g.z * 0.5
        
        /*
        Right handed & Counter-clockwise
        
          Y+
          |
          |
          o------X+
         /
        Z+
        
        X = 0            Y = 0         Z = 0
        0-----------3    2-----------1    1-----0
        |           |    |           |    |     |
        |           |    |           |    |     |
        1-----------2    3-----------0    |     |
                                          2-----3
        */
        
        let surface = Surface(reserveCapacity: 20)

        // X = 0
        let z0 = surface.addVertex(Vector3D(0.0, +s, +l))
        let z1 = surface.addVertex(Vector3D(0.0, -s, +l))
        let z2 = surface.addVertex(Vector3D(0.0, -s, -l))
        let z3 = surface.addVertex(Vector3D(0.0, +s, -l))
        
        // Y = 0
        let x0 = surface.addVertex(Vector3D(+l, 0.0, +s))
        let x1 = surface.addVertex(Vector3D(+l, 0.0, -s))
        let x2 = surface.addVertex(Vector3D(-l, 0.0, -s))
        let x3 = surface.addVertex(Vector3D(-l, 0.0, +s))
        
        // Z = 0
        let y0 = surface.addVertex(Vector3D(+s, +l, 0.0))
        let y1 = surface.addVertex(Vector3D(-s, +l, 0.0))
        let y2 = surface.addVertex(Vector3D(-s, -l, 0.0))
        let y3 = surface.addVertex(Vector3D(+s, -l, 0.0))
        
        /*
        △▽△ 1
        ▽△
         ▽△▽△▽△▽△▽△
                  ▽△
              20 ▽△▽
         */
        
        surface.addFace(y0, y1, z0)
        surface.addFace(z0, y1, x3)
        surface.addFace(x3, z1, z0)
        surface.addFace(z0, z1, x0)
        surface.addFace(x0, y0, z0)
        surface.addFace(x0, x1, y0)
        surface.addFace(y0, x1, z3)
        surface.addFace(y0, z3, y1)
        surface.addFace(y1, z3, x2)
        surface.addFace(y1, x2, x3)
        surface.addFace(x3, x2, y2)
        surface.addFace(x3, y2, z1)
        surface.addFace(z1, y2, y3)
        surface.addFace(z1, y3, x0)
        surface.addFace(x0, y3, x1)
        surface.addFace(x1, y3, z2)
        surface.addFace(x1, z2, z3)
        surface.addFace(z3, z2, x2)
        surface.addFace(x2, z2, y2)
        surface.addFace(y2, z2, y3)
        
        return surface
    }
}
