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
        self.a = a
        self.b = b
    }
    
    public var hashValue: Int {
        return (a * 7).hashValue ^ b.hashValue
    }
    
    public func isReverseOf(other: Edge) -> Bool {
        return a == other.b && b == other.a
    }
    
    public func reverse() -> Edge {
        return Edge(b, a)
    }
}

public func ==(lhs: Edge, rhs: Edge) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b
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
    private static let numberOfBuckets: Int = 128
    private let weldEpsilon: Float = 0.5
    private let cellSize: Float = 10.0
    private var buckets: [Int]
    private var vertices: [Vector3D]
    private var nextVertex: [Int]
    private var faces: [Triangle]
    
    public init(reserveCapacity: Int) {
        self.buckets = [Int](count: Surface.numberOfBuckets, repeatedValue: -1)
        self.vertices = [Vector3D]()
        self.nextVertex = [Int]()
        self.faces = [Triangle]()
        self.vertices.reserveCapacity(reserveCapacity)
        self.nextVertex.reserveCapacity(reserveCapacity)
        self.faces.reserveCapacity(reserveCapacity)
    }
    
    public func allVertices() -> [Vector3D] {
        return vertices
    }
    
    public func allFaces() -> [Triangle] {
        return faces
    }
    
    public func addVertex(vertex: Vector3D, unique: Bool = true) -> Int {
        if unique {
            return insertVertex(vertex)
        }
        else {
            return weldVertex(vertex)
        }
    }
    
    public func addFace(a: Int, _ b: Int, _ c: Int) {
        faces.append(Triangle(a, b, c))
    }
    
    private func insertVertex(vertex: Vector3D) -> Int {
        let x = Int(vertex.x / cellSize)
        let y = Int(vertex.y / cellSize)
        let z = Int(vertex.z / cellSize)
        
        let bucket = gridCellBucket(x, y, z)
        let index = vertices.count
        vertices.append(vertex)
        nextVertex.append(buckets[bucket])
        buckets[bucket] = index
        
        return index
    }
    
    private func gridCellBucket(x: Int, _ y: Int, _ z: Int) -> Int {
        let magic1: UInt = 0x8da6b343
        let magic2: UInt = 0xd8163841
        let magic3: UInt = 0xcb1ab31f
        let index = (magic1 &* UInt(bitPattern: x)) &+ (magic2 &* UInt(bitPattern: y)) &+ (magic3 &* UInt(bitPattern: z))
        return Int(index % UInt(Surface.numberOfBuckets))
    }
    
    private func locateVertex(v: Vector3D, inBucket bucket: Int) -> Int? {
        for var index = buckets[bucket]; index >= 0; index = nextVertex[index] {
            if distance_squared(vertices[index], v) < weldEpsilon * weldEpsilon {
                return index
            }
        }
        
        return nil
    }
    
    private func weldVertex(vertex: Vector3D) -> Int {
        let left = Int((vertex.x - weldEpsilon) / cellSize)
        let right = Int((vertex.x + weldEpsilon) / cellSize)
        let top = Int((vertex.y - weldEpsilon) / cellSize)
        let bottom = Int((vertex.y + weldEpsilon) / cellSize)
        let forward = Int((vertex.z - weldEpsilon) / cellSize)
        let backward = Int((vertex.z + weldEpsilon) / cellSize)
        var previouslyVisitedBucket = Set<Int>(minimumCapacity: 8)
        
        for i in left...right {
            for j in top...bottom {
                for k in forward...backward {
                    let bucket = gridCellBucket(i, j, k)
                    
                    if previouslyVisitedBucket.contains(bucket) {
                        continue
                    }
                    
                    previouslyVisitedBucket.insert(bucket)
                    
                    if let index = locateVertex(vertex, inBucket: bucket) {
                        return index
                    }
                }
            }
        }
        
        return insertVertex(vertex)
    }
    
    public func triangles() -> [Triangle3D] {
        var triangles = [Triangle3D]()
        
        for face in faces {
            let triangle = Triangle3D(vertices[face.a].point, vertices[face.b].point, vertices[face.c].point)
            triangles.append(triangle)
        }
        
        return triangles
    }
    
    public func subdivideBy(divisions: Int) -> Surface {
        let subdividedSurface = Surface(reserveCapacity: faces.count * (divisions * divisions))
        let edgeVertexCount = divisions + 1
        let delta = 1.0 / Float(divisions)

        var pointsForEdge = [Edge:[Vector3D]]()
        var rows = [[Int]]()
        
        rows.reserveCapacity(edgeVertexCount)
        
        for face in faces {
            let AB = Edge(face.a, face.b)
            let AC = Edge(face.a, face.c)
            
            var pAB = pointsForEdge[AB] ?? [Vector3D]()
            var pAC = pointsForEdge[AC] ?? [Vector3D]()

            if pAB.count == 0 && pAC.count == 0 {
                pAB.reserveCapacity(edgeVertexCount)
                pAC.reserveCapacity(edgeVertexCount)
                
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
                
                pointsForEdge[AB] = pAB
                pointsForEdge[AB.reverse()] = pAB.reverse()
                pointsForEdge[AC] = pAC
                pointsForEdge[AC.reverse()] = pAC.reverse()
            }
            else if pAB.count == 0 {
                pAB.reserveCapacity(edgeVertexCount)
                
                let a = vertices[face.a]
                let b = vertices[face.b]
                
                let deltaAB = (b - a) * delta
                
                var nextAB = a
                
                for _ in 0..<divisions {
                    pAB.append(nextAB)
                    
                    nextAB += deltaAB
                }
                
                pAB.append(b)
                
                pointsForEdge[AB] = pAB
                pointsForEdge[AB.reverse()] = pAB.reverse()
            }
            else if pAC.count == 0 {
                pAC.reserveCapacity(edgeVertexCount)
                
                let a = vertices[face.a]
                let c = vertices[face.c]
                
                let deltaAC = (c - a) * delta
                
                var nextAC = a
                
                for _ in 0..<divisions {
                    pAC.append(nextAC)
                    
                    nextAC += deltaAC
                }
                
                pAC.append(c)
                
                pointsForEdge[AC] = pAC
                pointsForEdge[AC.reverse()] = pAC.reverse()
            }
            // else both have previously been calculated
            
            for row in 0..<edgeVertexCount {
                var rowIndices = [Int]()
                rowIndices.reserveCapacity(row + 1)
                
                let rb = pAB[row]
                let rc = pAC[row]
                let rowDelta = 1.0 / Float(row)
                let deltaBC = (rc - rb) * rowDelta
                var nextBC = rb
                
                for i in 0..<row {
                    let index = subdividedSurface.addVertex(nextBC, unique: (i > 0))
                    rowIndices.append(index)
                    nextBC += deltaBC
                }

                let lastIndex = subdividedSurface.addVertex(rc, unique: false)
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
