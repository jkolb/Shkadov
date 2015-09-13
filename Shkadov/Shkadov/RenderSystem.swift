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

import simd

public class RenderSystem {
    private let renderer: Renderer
    private let entityComponents: EntityComponents
    
    public init(renderer: Renderer, entityComponents: EntityComponents) {
        self.renderer = renderer
        self.entityComponents = entityComponents
        
        let camera = entityComponents.createEntity()
        entityComponents.addComponent(OrientationComponent(position: float3(0.0, 0.0, -4.0)), toEntity: camera)
        entityComponents.addComponent(ProjectionComponent(projectionMatrix: float4x4(fovy: Angle(degrees: 90.0), aspect: 1.0, zNear: 0.1, zFar: 100.0)), toEntity: camera)
    }
    
    public func configure() {
        renderer.configure()
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        let camera = entityComponents.getEntitiesWithComponentType(ProjectionComponent.self).first!
        var projection = entityComponents.componentForEntity(camera, withComponentType: ProjectionComponent.self)!
        projection.projectionMatrix = float4x4(fovy: Angle(degrees: 65.0), aspect: viewport.aspectRatio, zNear: 0.1, zFar: 100.0)
        entityComponents.updateComponent(projection, forEntity: camera)
        
        renderer.updateViewport(viewport)
    }

    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
        let camera = entityComponents.getEntitiesWithComponentTypes([ProjectionComponent.self, OrientationComponent.self]).first!
        let cameraOrientation = entityComponents.componentForEntity(camera, withComponentType: OrientationComponent.self)!
        let projection = entityComponents.componentForEntity(camera, withComponentType: ProjectionComponent.self)!
        let viewMatrix = cameraOrientation.lookAtMatrix
        let projectionMatrix = projection.projectionMatrix
        
        for entity in entityComponents.getEntitiesWithComponentTypes([RenderComponent.self, OrientationComponent.self]) {
            let orientation = entityComponents.componentForEntity(entity, withComponentType: OrientationComponent.self)!
            var render = entityComponents.componentForEntity(entity, withComponentType: RenderComponent.self)!
            
            let modelViewMatrix = viewMatrix * orientation.orientationMatrix
            render.modelViewProjectionMatrix = projectionMatrix * modelViewMatrix
            render.normalMatrix = modelViewMatrix.inverse.transpose
            
            entityComponents.updateComponent(render, forEntity: entity)
        }
    }
}
