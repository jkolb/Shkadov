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

public final class Scene {
    public let camera: Camera
    public let rootNode: ParentSceneNode
    public let cameraNode: DynamicSceneNode
    private var staticTree: AABBTree<SceneNode>
    
    public init() {
        self.camera = Camera()
        self.rootNode = StaticGroupSceneNode(name: "Root")
        self.cameraNode = DynamicEmptySceneNode(name: "Camera")
        self.staticTree = AABBTree<SceneNode>()
    }
    
    public func compile() {
        buildStaticTree()
    }
    
    public func update() {
        camera.updateWorldTransform(cameraNode.worldTransform)
    }
    
    public func generatePotentiallyVisibleRenderables() -> [Renderable] {
        let potentiallyVisibleNodes = staticTree.filter(camera.worldFrustum, testNode: { $0.containsVolume($1) }, testLeaf: { $0.containsVolume($1.worldBounds) })
        var renderables = [Renderable]()
        
        for node in potentiallyVisibleNodes {
            renderables.appendContentsOf(node.generateRenderablesForCamera(camera))
        }
        
        return renderables
    }
    
    private var staticRenderableNodes: [SceneNode] {
        return rootNode.allChildrenPassingTest({ (child) -> Bool in
            return child is StaticBasicSceneNode && !child.worldBounds.isNull
        })
    }
    
    private func nodesInFrustum(frustum: Frustum) -> [SceneNode] {
        return []
    }
    
    private func buildStaticTree() {
        staticTree = buildTreeForSceneNodes(staticRenderableNodes)
    }
    
    public func potentiallyCollidingSceneNodes(ray: Ray3D) -> [CollidableSceneNode] {
        return staticTree.filter(
            ray,
            testNode: {
                intersectTest($0, $1) // || insideTest($0.origin, $1)
            },
            testLeaf: {
                $1 is CollidableSceneNode && (intersectTest($0, $1.worldBounds) /* || insideTest($0.origin, $1.worldBounds) */)
            }).map({
                $0 as! CollidableSceneNode
            })
    }
    
    private func buildTreeForSceneNodes(sceneNodes: [SceneNode]) -> AABBTree<SceneNode> {
        let bounds = sceneNodes.map({ $0.worldBounds })
        
        return AABBTree<SceneNode>(
            leaf: sceneNodes,
            bounds: bounds,
            unionBounds: { (leafPointers, leaf) -> AABB in
                AABB(union: leafPointers.map({ leaf[$0].worldBounds }))
            }
        )
    }
}
