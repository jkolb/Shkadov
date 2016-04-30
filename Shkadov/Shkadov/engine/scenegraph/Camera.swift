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

public final class Camera {
    public var projection: PerspectiveProjection {
        didSet {
            worldFrustum = worldTransform.applyTo(projection.frustum)
        }
    }
    public private(set) var worldFrustum: Frustum
    private var worldTransform: Transform3D
    public private(set) var viewMatrix: Matrix4x4
    
    public init() {
        self.projection = PerspectiveProjection()
        self.worldFrustum = self.projection.frustum
        self.worldTransform = Transform3D()
        self.viewMatrix = Matrix4x4()
    }

    public var projectionMatrix: Matrix4x4 {
        return projection.matrix
    }
    
    public func isPotentiallyVisibleVolume(bounds: AABB) -> Bool {
        return worldFrustum.containsVolume(bounds)
    }
    
    public func updateWorldTransform(transform: Transform3D) {
        if worldTransform != transform {
            worldTransform = transform
            worldTransformDidUpdate()
        }
    }
    
    private func worldTransformDidUpdate() {
        worldFrustum = worldTransform.applyTo(projection.frustum)
        viewMatrix = worldTransform.inverseMatrix
    }
}
