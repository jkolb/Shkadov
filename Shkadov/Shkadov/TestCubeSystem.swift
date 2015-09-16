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

import Foundation
import simd

public class TestCubeSystem {
    private let renderer: Renderer
    private let entityComponents: EntityComponents
    private var renderState: RenderState
    
    public init(renderer: Renderer, entityComponents: EntityComponents) {
        self.renderer = renderer
        self.entityComponents = entityComponents
        self.renderState = RenderState()
    }
    
    deinit {
        renderer.destroyProgram(renderState.program)
        renderer.destoryBuffer(renderState.buffer)
    }
    
    public func configure() {
        var vertexDescriptor = VertexDescriptor()
        vertexDescriptor.addAttribute(.Position, format: .Float3)
        vertexDescriptor.addAttribute(.Normal, format: .Float3)
        
        let mesh = Mesh3D.cubeWithSize(1.0)
        let meshData = mesh.createBufferForVertexDescriptor(vertexDescriptor)
        
        self.renderState.program = renderer.createProgramWithVertexPath(NSBundle.mainBundle().pathForResource("Shader", ofType: "vsh")!, fragmentPath: NSBundle.mainBundle().pathForResource("Shader", ofType: "fsh")!)
        self.renderState.buffer = renderer.createBufferFromDescriptor(vertexDescriptor, buffer: meshData)
        
        let positions = [
            float3(0.0, 0.0, 0.0),
            float3(1.5, 0.0, 0.0),
            float3(-1.5, 0.0, 0.0),
            float3(0.0, 1.5, 0.0),
            float3(0.0, -1.5, 0.0),
            float3(0.0, 0.0, 1.5),
            float3(0.0, 0.0, -1.5),
        ]
        
        let colors = [
            Color.white.vector,
            Color.red.vector,
            Color.magenta.vector,
            Color.green.vector,
            Color.yellow.vector,
            Color.blue.vector,
            Color.cyan.vector,
        ]
        
        for index in 0..<positions.count {
            let cube = self.entityComponents.createEntity()
            self.entityComponents.addComponent(OrientationComponent(position: positions[index]), toEntity: cube)
            self.entityComponents.addComponent(RenderComponent(diffuseColor: colors[index]), toEntity: cube)
        }
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
        let updateAmount: Float = 0.01
        
        for entity in entityComponents.getEntitiesWithComponentType(RenderComponent.self) {
            var orientation = entityComponents.componentForEntity(entity, withComponentType: OrientationComponent.self)!
            
            orientation.pitch += Angle(radians: updateAmount)
            orientation.yaw += Angle(radians: updateAmount)
            
            entityComponents.updateComponent(orientation, forEntity: entity)
        }
    }
    
    public func render() {
        var renderObjects = [RenderComponent]()
        
        for entity in entityComponents.getEntitiesWithComponentType(RenderComponent.self) {
            let renderObject = entityComponents.componentForEntity(entity, withComponentType: RenderComponent.self)!
            renderObjects.append(renderObject)
        }
        
        renderState.objects = renderObjects
        
        renderer.renderState(renderState)
    }
}
