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

import Swiftish

public final class Camera {
    public var projection: PerspectiveProjection<Float> {
        didSet {
            worldFrustum = worldTransform.applyTo(projection.frustum)
        }
    }
    public fileprivate(set) var worldFrustum: Frustum<Float>
    public var worldTransform: Transform3<Float> {
        didSet {
            worldFrustum = worldTransform.applyTo(projection.frustum)
            viewMatrix = worldTransform.inverseMatrix
        }
    }
    public fileprivate(set) var viewMatrix: Matrix4x4<Float>
    
    public init() {
        self.projection = PerspectiveProjection<Float>(fovy: Angle<Float>(degrees: 90.0), aspectRatio: 1.0, zNear: 1.0, zFar: 10_000.0)
        self.worldFrustum = self.projection.frustum
        self.worldTransform = Transform3<Float>()
        self.viewMatrix = Matrix4x4()
    }
    
    public var projectionMatrix: Matrix4x4<Float> {
        return projection.matrix
    }
    
    public func isPotentiallyVisibleVolume(_ bounds: Bounds3<Float>) -> Bool {
        return test(bounds, intersectsOrIsInside: worldFrustum)
    }
}
