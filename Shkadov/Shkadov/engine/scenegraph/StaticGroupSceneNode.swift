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

public final class StaticGroupSceneNode : ParentSceneNode, StaticSceneNode {
    public let name: String
    public weak var parent: ParentSceneNode?
    public private(set) var children: [SceneNode]
    public private(set) var worldTransform: Transform3D
    public private(set) var worldBounds: AABB
    
    public let localTransform: Transform3D
    
    public convenience init(name: String) {
        self.init(name: name, localTransform: Transform3D())
    }
    
    public init(name: String, localTransform: Transform3D) {
        self.name = name
        self.parent = nil
        self.children = []
        self.worldTransform = localTransform
        self.localTransform = localTransform
        self.worldBounds = AABB()
    }
    
    public func generateRenderablesForCamera(camera: Camera) -> [Renderable] {
//        if !camera.isPotentiallyVisibleVolume(worldBounds) {
//            return []
//        }
        
        var renderables = [Renderable]()
        renderables.reserveCapacity(children.count * 10)
        
        for child in children {
            renderables.appendContentsOf(child.generateRenderablesForCamera(camera))
        }
        
        return renderables
    }

    public func updateWorldTransformWithParentTransform(parentTransform: Transform3D) {
        worldTransform = parentTransform + localTransform
        
        for child in children {
            child.updateWorldTransformWithParentTransform(worldTransform)
        }
        
        worldTransformDidUpdate()
    }
    
    private func worldTransformDidUpdate() {
        worldBounds = AABB().union(children.map({ $0.worldBounds }))
    }
    
    public func addChildNode(childNode: SceneNode) {
        childNode.parent = self
        children.append(childNode)
        childNode.updateWorldTransformWithParentTransform(worldTransform)
        worldBounds = worldBounds.union(childNode.worldBounds)
    }
    
    public func allChildrenPassingTest(test: (SceneNode) -> Bool) -> [SceneNode] {
        var passedTest = [SceneNode]()

        for child in children {
            if test(child) {
                passedTest.append(child)
            }
            
            if let parentChild = child as? ParentSceneNode {
                passedTest.appendContentsOf(parentChild.allChildrenPassingTest(test))
            }
        }
        
        return passedTest
    }
}
