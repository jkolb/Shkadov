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

public struct Frustum : Equatable, CustomStringConvertible {
    public let top: Plane
    public let bottom: Plane
    public let right: Plane
    public let left: Plane
    public let near: Plane
    public let far: Plane
    
    public init(top: Plane, bottom: Plane, right: Plane, left: Plane, near: Plane, far: Plane) {
        self.top = top
        self.bottom = bottom
        self.right = right
        self.left = left
        self.near = near
        self.far = far
    }
    
    public func containsVolume(bounds: AABB) -> Bool {
        if  bounds.isNull {
            return false
        }

        // In order of most likely to cause early exit
        if !bounds.intersectsOrIsInsidePlane(near) { return false }
        if !bounds.intersectsOrIsInsidePlane(right) { return false }
        if !bounds.intersectsOrIsInsidePlane(left) { return false }
        if !bounds.intersectsOrIsInsidePlane(top) { return false }
        if !bounds.intersectsOrIsInsidePlane(bottom) { return false }
        if !bounds.intersectsOrIsInsidePlane(far) { return false }
        
        return true
    }
    
    public var description: String {
        return "{\n\tT: \(top)\n\tB: \(bottom)\n\tR: \(right)\n\tL: \(left)\n\tN: \(near)\n\tF: \(far)}"
    }
}

public func ==(lhs: Frustum, rhs: Frustum) -> Bool {
    return lhs.top == rhs.top && lhs.bottom == rhs.bottom && lhs.right == rhs.right && lhs.left == rhs.left && lhs.near == rhs.near && lhs.far == rhs.far
}
