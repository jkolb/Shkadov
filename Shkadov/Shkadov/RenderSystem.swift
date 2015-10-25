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

public final class RenderSystem {
    private let renderer: Renderer
    private let entityComponents: EntityComponents
    private let camera: Entity
    
    public init(renderer: Renderer, entityComponents: EntityComponents) {
        self.camera = entityComponents.createEntity()
        self.renderer = renderer
        self.entityComponents = entityComponents
        
        entityComponents.addComponent(OrientationComponent(position: Point3D(0.0, -65495.0, 0.0)), toEntity: camera)
        entityComponents.addComponent(ProjectionComponent(projectionMatrix: Matrix4x4(fovy: Angle(degrees: 90.0), aspect: 1.0, zNear: 0.1, zFar: 100.0)), toEntity: camera)
    }
    
    public func configure() {
        renderer.configure()
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        // http://www.rjdown.co.uk/projects/bfbc2/fovcalculator.php
        let projection = ProjectionComponent(
            projectionMatrix: Matrix4x4(fovy: Angle(degrees: 46.0), aspect: viewport.aspectRatio, zNear: 0.1, zFar: 147456.0)
        )
        entityComponents.replaceComponent(projection, forEntity: camera)
        renderer.updateViewport(viewport)
    }

    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
        let cameraOrientation = entityComponents.componentForEntity(camera, withComponentType: OrientationComponent.self)
        let projection = entityComponents.componentForEntity(camera, withComponentType: ProjectionComponent.self)
        let viewMatrix = cameraOrientation.inverseTransform
        let projectionMatrix = projection.projectionMatrix
        let entities = entityComponents.getEntitiesWithComponentTypes([RenderComponent.self, OrientationComponent.self])
            
        for entity in entities {
            let render = entityComponents.componentForEntity(entity, withComponentType: RenderComponent.self)
            let orientation = entityComponents.componentForEntity(entity, withComponentType: OrientationComponent.self)
            
            let modelViewMatrix = viewMatrix * orientation.transform
            let normalMatrix = modelViewMatrix.matrix3x3
            let modelViewProjectionMatrix = projectionMatrix * modelViewMatrix
            
            let bufferContents = UnsafeMutablePointer<UniformIn>(render.uniformBuffer.contents.advancedBy(render.uniformOffset))
            bufferContents.memory = UniformIn(
                modelViewMatrix: modelViewMatrix.cmatrix,
                projectionMatrix: projectionMatrix.cmatrix,
                modelViewProjectionMatrix: modelViewProjectionMatrix.cmatrix,
                normalMatrix: normalMatrix.cmatrix,
                diffuseColor: render.diffuseColor.vector
            )
        }
    }
}
