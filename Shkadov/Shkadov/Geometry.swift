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

public typealias GeometryType = Float

public struct Point2D {
    public static let zero = Point2D(x: 0.0, y: 0.0)
    
    public let x: GeometryType
    public let y: GeometryType
    
    public init(x: GeometryType, y: GeometryType) {
        self.x = x
        self.y = y
    }
}

public struct Vector2D {
    public static let zero = Vector2D(dx: 0.0, dy: 0.0)
    
    public let dx: GeometryType
    public let dy: GeometryType
    
    public init(dx: GeometryType, dy: GeometryType) {
        self.dx = dx
        self.dy = dy
    }
}

public struct Size2D {
    public static let zero = Size2D(width: 0.0, height: 0.0)
    
    public let width: GeometryType
    public let height: GeometryType
    
    public init(width: GeometryType, height: GeometryType) {
        precondition(width >= 0.0)
        precondition(height >= 0.0)
        
        self.width = width
        self.height = height
    }
    
    public var aspectRatio: GeometryType {
        return width / height
    }
    
    public var inverseAspectRatio: GeometryType {
        return height / width
    }
}

public struct Rectangle2D {
    public static let zero = Rectangle2D(origin: Point2D.zero, size: Size2D.zero)
    
    public let origin: Point2D
    public let size: Size2D
    
    public init(origin: Point2D, size: Size2D) {
        self.origin = origin
        self.size = size
    }
    
    public var x: GeometryType {
        return origin.x
    }
    
    public var y: GeometryType {
        return origin.y
    }
    
    public var width: GeometryType {
        return size.width
    }
    
    public var height: GeometryType {
        return size.height
    }

    public var centerX: GeometryType {
        return x + width * 0.5
    }
    
    public var centerY: GeometryType {
        return y + height * 0.5
    }
    
    public var center: Point2D {
        return Point2D(x: centerX, y: centerY)
    }
    
    public var aspectRatio: GeometryType {
        return size.aspectRatio
    }
    
    public var inverseAspectRatio: GeometryType {
        return size.inverseAspectRatio
    }
}
