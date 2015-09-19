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

import CoreGraphics

public extension Point2D {
    public var nativePoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

public extension CGPoint {
    public var point2D: Point2D {
        return Point2D(GeometryType(x), GeometryType(y))
    }
    
    public var rect: CGRect {
        return CGRect(origin: self, size: CGSize.zero)
    }
}

public extension CGSize {
    public var size2D: Size2D {
        return Size2D(GeometryType(width), GeometryType(height))
    }
}

public extension CGRect {
    public var rectagle2D: Rectangle2D {
        return Rectangle2D(origin: origin.point2D, size: size.size2D)
    }
    
    public var center2D: Point2D {
        return CGPoint(x: midX, y: midY).point2D
    }
}
