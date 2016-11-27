//
//  Camera.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/15/16.
//
//

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
