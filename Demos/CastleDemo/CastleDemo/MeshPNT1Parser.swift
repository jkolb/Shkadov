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

import Shkadov

public enum MeshPNT1ParserError : ErrorType {
    case InvalidFile
}

public final class MeshPNT1Parser {
    private let lineReader: LineReader
    private let gpuMemory: GPUMemory
    
    public init(lineReader: LineReader, gpuMemory: GPUMemory) {
        self.lineReader = lineReader
        self.gpuMemory = gpuMemory
    }
    
    public func parse() throws -> Geometry {
        let positions = try parseVertexPositionArray()
        let normals = try parseVertexNormalArray()
        let texcoords = try parseVertexTexcoordArray()
        let indexTriangles = try parseIndexTrianglePNT1Array()
        let maximumVertexCount = indexTriangles.count * 3
        var indexVertexIndex = [IndexVertexPNT1 : Int](minimumCapacity: maximumVertexCount)
        var vertices = [VertexPNT1]()
        vertices.reserveCapacity(maximumVertexCount)
        var indices = [UInt32]()
        indices.reserveCapacity(maximumVertexCount)
        
        for indexTriangle in indexTriangles {
            for indexVertex in indexTriangle {
                if let index = indexVertexIndex[indexVertex] {
                    indices.append(UInt32(index))
                }
                else {
                    let index = indexVertexIndex.count
                    indexVertexIndex[indexVertex] = index
                    indices.append(UInt32(index))
                    
                    let position = positions[indexVertex.positionIndex]
                    let normal = normals[indexVertex.normalIndex]
                    let texcoord = texcoords[indexVertex.texcoordIndex]
                    let vertex = VertexPNT1(position: position, normal: normal, texcoord: texcoord)
                    vertices.append(vertex)
                }
            }
        }
        
        let vertexData = gpuMemory.bufferWithBytes(vertices, size: vertices.count * strideof(VertexPNT1), storageMode: .Shared)
        let vertexBuffer = VertexBuffer(descriptor: VertexPNT1.descriptor, count: vertices.count, data: vertexData)
        let indexDescriptor = IndexDescriptor(primitiveType: .Triangle, indexType: .UInt32)
        let indexData = gpuMemory.bufferWithBytes(indices, size: indices.count * strideof(UInt32), storageMode: .Shared)
        let indexBuffer = IndexBuffer(descriptor: indexDescriptor, count: indices.count, data: indexData)
        let bounds = AABB(containingPoints: positions)
        let positionIndices = indexTriangles.flatMap({ $0.positionIndices })
        let mesh = Mesh(positions: positions, indices: positionIndices)
        let collisionMesh = CollisionMesh(mesh: mesh)
        return Geometry(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, bounds: bounds, collisionMesh: collisionMesh)
    }
    
    public func parseMultiple() throws -> [Geometry] {
        let positions = try parseVertexPositionArray()
        let normals = try parseVertexNormalArray()
        let texcoords = try parseVertexTexcoordArray()
        let triangleCounts = try parseTriangleCountArray()
        var geometries = [Geometry]()
        geometries.reserveCapacity(triangleCounts.count)
        
        for triangleCount in triangleCounts {
            let indexTriangles = try parseIndexTrianglePNT1ArrayCount(triangleCount)
            let maximumVertexCount = indexTriangles.count * 3
            var indexVertexIndex = [IndexVertexPNT1 : Int](minimumCapacity: maximumVertexCount)
            var vertices = [VertexPNT1]()
            vertices.reserveCapacity(maximumVertexCount)
            var indices = [UInt32]()
            indices.reserveCapacity(maximumVertexCount)
            var collisionPositions = [Vector3D]()
            collisionPositions.reserveCapacity(maximumVertexCount)
            var collisionIndices = [Int]()
            collisionIndices.reserveCapacity(maximumVertexCount)
            var collisionIndexMap = [Int : Int](minimumCapacity: maximumVertexCount)
            
            for indexTriangle in indexTriangles {
                for indexVertex in indexTriangle {
                    if let index = indexVertexIndex[indexVertex] {
                        indices.append(UInt32(index))
                        
                        let collisionIndex = collisionIndexMap[index]!
                        collisionIndices.append(collisionIndex)
                    }
                    else {
                        let index = indexVertexIndex.count
                        indexVertexIndex[indexVertex] = index
                        indices.append(UInt32(index))
                        
                        let position = positions[indexVertex.positionIndex]
                        let normal = normals[indexVertex.normalIndex]
                        let texcoord = texcoords[indexVertex.texcoordIndex]
                        let vertex = VertexPNT1(position: position, normal: normal, texcoord: texcoord)
                        vertices.append(vertex)
                        
                        let collisionIndex = collisionPositions.count
                        collisionIndexMap[index] = collisionIndex
                        collisionIndices.append(collisionIndex)
                        collisionPositions.append(position)
                    }
                }
            }
            
            let vertexData = gpuMemory.bufferWithBytes(vertices, size: vertices.count * strideof(VertexPNT1), storageMode: .Shared)
            let vertexBuffer = VertexBuffer(descriptor: VertexPNT1.descriptor, count: vertices.count, data: vertexData)
            let indexDescriptor = IndexDescriptor(primitiveType: .Triangle, indexType: .UInt32)
            let indexData = gpuMemory.bufferWithBytes(indices, size: indices.count * strideof(UInt32), storageMode: .Shared)
            let indexBuffer = IndexBuffer(descriptor: indexDescriptor, count: indices.count, data: indexData)
            let bounds = AABB(containingPoints: collisionPositions)
            let mesh = Mesh(positions: collisionPositions, indices: collisionIndices)
            let collisionMesh = CollisionMesh(mesh: mesh)
            let geometry = Geometry(vertexBuffer: vertexBuffer, indexBuffer: indexBuffer, bounds: bounds, collisionMesh: collisionMesh)
            geometries.append(geometry)
        }
        
        return geometries
    }
    
    private func parseVertexTexcoordArray() throws -> [Vector2D] {
        let count = try parseCount()
        let array = try parseVertexTexcoordCount(count)
        try consumeEmptyLine()
        return array
    }
    
    private func parseVertexPositionArray() throws -> [Vector3D] {
        let count = try parseCount()
        let array = try parseVertexPositionCount(count)
        try consumeEmptyLine()
        return array
    }
    
    private func parseVertexNormalArray() throws -> [Vector3D] {
        let count = try parseCount()
        let array = try parseVertexNormalCount(count)
        try consumeEmptyLine()
        return array
    }
    
    private func parseTriangleCountArray() throws -> [Int] {
        let count = try parseCount()
        var array = [Int]()
        array.reserveCapacity(count)
        
        for _ in 0..<count {
            let ints = try lineReader.readInts()
            array.append(ints[0])
        }
        
        try consumeEmptyLine()
        return array
    }
    
    private func parseIndexTrianglePNT1Array() throws -> [IndexTrianglePNT1] {
        let count = try parseCount()
        let array = try parseIndexTrianglePNT1Count(count)
        try consumeEmptyLine()
        return array
    }
    
    private func parseIndexTrianglePNT1ArrayCount(count: Int) throws -> [IndexTrianglePNT1] {
        let array = try parseIndexTrianglePNT1Count(count)
        try consumeEmptyLine()
        return array
    }
    
    private func parseCount() throws -> Int {
        let ints = try lineReader.readInts()
        guard ints.count == 1 else {
            throw MeshPNT1ParserError.InvalidFile
        }
        return ints[0]
    }
    
    private func parseVertexTexcoordCount(count: Int) throws -> [Vector2D] {
        var texcoords = [Vector2D]()
        texcoords.reserveCapacity(count)
        
        for _ in 0..<count {
            let texcoord = try parseVertexTexcoord()
            texcoords.append(texcoord)
        }
        
        return texcoords
    }
    
    private func parseVertexPositionCount(count: Int) throws -> [Vector3D] {
        var positions = [Vector3D]()
        positions.reserveCapacity(count)
        
        for _ in 0..<count {
            let position = try parseVertexPosition()
            positions.append(position)
        }
        
        return positions
    }
    
    private func parseVertexNormalCount(count: Int) throws -> [Vector3D] {
        var normals = [Vector3D]()
        normals.reserveCapacity(count)
        
        for _ in 0..<count {
            let normal = try parseVertexNormal()
            normals.append(normal)
        }
        
        return normals
    }
    
    private func parseIndexTrianglePNT1Count(count: Int) throws -> [IndexTrianglePNT1] {
        var triangles = [IndexTrianglePNT1]()
        triangles.reserveCapacity(count)
        
        for _ in 0..<count {
            let triangle = try parseIndexTrianglePNT1()
            triangles.append(triangle)
        }
        
        return triangles
    }
    
    private func parseVertexTexcoord() throws -> Vector2D {
        let floats = try lineReader.readFloats()
        guard floats.count == 2 else {
            throw MeshPNT1ParserError.InvalidFile
        }
        return Vector2D(floats[0], floats[1])
    }
    
    private func parseVertexPosition() throws -> Vector3D {
        let floats = try lineReader.readFloats()
        guard floats.count == 3 else {
            throw MeshPNT1ParserError.InvalidFile
        }
        return Vector3D(floats[0], floats[1], floats[2])
    }
    
    private func parseVertexNormal() throws -> Vector3D {
        let floats = try lineReader.readFloats()
        guard floats.count == 3 else {
            throw MeshPNT1ParserError.InvalidFile
        }
        return Vector3D(floats[0], floats[1], floats[2])
    }
    
    private func parseIndexTrianglePNT1() throws -> IndexTrianglePNT1 {
        let ints = try lineReader.readInts()
        let numberOfAttributes = 3 // PNT1
        let numberOfVertices = 3
        guard ints.count == numberOfAttributes * numberOfVertices else {
            throw MeshPNT1ParserError.InvalidFile
        }
        let a = IndexVertexPNT1(positionIndex: ints[0], normalIndex: ints[1], texcoordIndex: ints[2])
        let b = IndexVertexPNT1(positionIndex: ints[3], normalIndex: ints[4], texcoordIndex: ints[5])
        let c = IndexVertexPNT1(positionIndex: ints[6], normalIndex: ints[7], texcoordIndex: ints[8])
        return IndexTrianglePNT1(a, b, c)
    }
    
    private func consumeEmptyLine() throws {
        try lineReader.readEmptyLine()
    }
}
