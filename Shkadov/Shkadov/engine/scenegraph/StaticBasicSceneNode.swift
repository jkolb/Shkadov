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

public final class StaticBasicSceneNode : StaticSceneNode, CollidableSceneNode {
    public let name: String
    public weak var parent: ParentSceneNode?
    public private(set) var worldTransform: Transform3D
    public private(set) var worldBounds: AABB
    public let localTransform: Transform3D
    public let localBounds: AABB
    private let renderable: Renderable
    private let updateUniforms: ((projectionMatrix: Matrix4x4, viewMatrix: Matrix4x4, modelMatrix: Matrix4x4) -> Void)?
    private var worldMatrix: Matrix4x4
    public let collisionMesh: CollisionMesh
    
    public convenience init(name: String, bounds: AABB, renderable: Renderable, collisionMesh: CollisionMesh, updateUniforms: ((projectionMatrix: Matrix4x4, viewMatrix: Matrix4x4, modelMatrix: Matrix4x4) -> Void)? = nil) {
        self.init(name: name, localTransform: Transform3D(), bounds: bounds, renderable: renderable, collisionMesh: collisionMesh, updateUniforms: updateUniforms)
    }
    
    public init(name: String, localTransform: Transform3D, bounds: AABB, renderable: Renderable, collisionMesh: CollisionMesh, updateUniforms: ((projectionMatrix: Matrix4x4, viewMatrix: Matrix4x4, modelMatrix: Matrix4x4) -> Void)? = nil) {
        self.name = name
        self.parent = nil
        self.localBounds = bounds
        self.localTransform = localTransform
        self.worldBounds = self.localBounds
        self.renderable = renderable
        self.updateUniforms = updateUniforms
        self.worldTransform = localTransform
        self.worldMatrix = localTransform.matrix
        self.collisionMesh = collisionMesh
        
        if !worldTransform.isIdentity {
            collisionMesh.transform(worldTransform)
        }
    }
    
    public func generateRenderablesForCamera(camera: Camera) -> [Renderable] {
//        if !camera.isPotentiallyVisibleVolume(worldBounds) {
//            return []
//        }

        if let updateUniforms = updateUniforms {
            updateUniforms(projectionMatrix: camera.projectionMatrix, viewMatrix: camera.viewMatrix, modelMatrix: worldMatrix)
        }
        
        return [renderable]
    }

    private func worldTransformDidUpdate() {
        worldBounds = worldTransform.applyTo(localBounds)
        worldMatrix = worldTransform.matrix
        collisionMesh.transform(worldTransform)
    }
    
    public func updateWorldTransformWithParentTransform(parentTransform: Transform3D) {
        worldTransform = parentTransform + localTransform
        worldTransformDidUpdate()
    }
}
