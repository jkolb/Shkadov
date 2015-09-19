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

public struct Triangle2D {
    public let a: Point2D
    public let b: Point2D
    public let c: Point2D
    
    public init(_ a: Point2D, _ b: Point2D, _ c: Point2D) {
        self.a = a
        self.b = b
        self.c = c
    }
    
    public func polygon() -> Polygon2D {
        return Polygon2D(points: [a, b, c])
    }
}

public struct Triangle3D {
    public let a: Point3D
    public let b: Point3D
    public let c: Point3D
    
    public init(_ a: Point3D, _ b: Point3D, _ c: Point3D) {
        self.a = a
        self.b = b
        self.c = c
    }

    public func polygon() -> Polygon3D {
        return Polygon3D(points: [a, b, c])
    }
}

public struct Quad2D {
    public let a: Point2D
    public let b: Point2D
    public let c: Point2D
    public let d: Point2D
    
    public init(_ a: Point2D, _ b: Point2D, _ c: Point2D, _ d: Point2D) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    
    public func polygon() -> Polygon2D {
        return Polygon2D(points: [a, b, c, d])
    }
}

public struct Quad3D {
    public let a: Point3D
    public let b: Point3D
    public let c: Point3D
    public let d: Point3D
    
    public init(_ a: Point3D, _ b: Point3D, _ c: Point3D, _ d: Point3D) {
        self.a = a
        self.b = b
        self.c = c
        self.d = d
    }
    
    public func polygon() -> Polygon3D {
        return Polygon3D(points: [a, b, c, d])
    }
}

public class Polygon2D : SequenceType {
    private var points: [Point2D]
    
    public init() {
        self.points = [Point2D]()
    }
    
    public init(points: [Point2D]) {
        self.points = points
    }
    
    public subscript (index: Int) -> Point2D {
        get {
            return points[index]
        }
        set {
            points[index] = newValue
        }
    }
    
    public var count: Int {
        return points.count
    }
    
    public func generate() -> AnyGenerator<Point2D> {
        var index = 0
        let count = self.count
        return anyGenerator {
            if index < count {
                return self.points[index++]
            }
            else {
                return nil
            }
        }
    }
}

public class Polygon3D : SequenceType {
    private var points: [Point3D]
    
    public init() {
        self.points = [Point3D]()
    }

    public init(points: [Point3D]) {
        self.points = points
    }
    
    public subscript (index: Int) -> Point3D {
        get {
            return points[index]
        }
        set {
            points[index] = newValue
        }
    }
    
    public var count: Int {
        return points.count
    }
    
    public func generate() -> AnyGenerator<Point3D> {
        var index = 0
        let count = self.count
        return anyGenerator {
            if index < count {
                return self.points[index++]
            }
            else {
                return nil
            }
        }
    }
}
