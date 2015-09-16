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

public class PlayerMovementSystem {
    private let entityComponents: EntityComponents
    
    public init(entityComponents: EntityComponents) {
        self.entityComponents = entityComponents
    }
    
    public func handleEvent(event: Event) {
        let camera = entityComponents.getEntitiesWithComponentType(ProjectionComponent.self).first!
        var orientation = entityComponents.componentForEntity(camera, withComponentType: OrientationComponent.self)!
        
        switch event.kind {
        case .Look(let direction):
            orientation.pitch += direction.up
            orientation.yaw += direction.right
            print("pitch: \(orientation.pitch.degrees), yaw: \(orientation.yaw.degrees)")
            print("pitch: \(AngleDelta(radians: orientation.pitch.radians).degrees)")
            
        case .Move(let direction):
            if direction.x == .Right {
                orientation.moveRightByAmount(0.1)
            }
            else if direction.x == .Left {
                orientation.moveRightByAmount(-0.1)
            }
            
            if direction.y == .Up {
                orientation.moveUpByAmount(0.1)
            }
            else if direction.y == .Down {
                orientation.moveUpByAmount(-0.1)
            }
            
            if direction.z == .Forward {
                orientation.moveForwardByAmount(0.1)
            }
            else if direction.z == .Backward {
                orientation.moveForwardByAmount(-0.1)
            }
            
        case .ResetCamera:
            orientation.pitch = Angle.zero
            orientation.yaw = Angle.zero
            orientation.position = float3(0.0, 0.0, -4.0)
        }
        
        entityComponents.updateComponent(orientation, forEntity: camera)
    }
}
