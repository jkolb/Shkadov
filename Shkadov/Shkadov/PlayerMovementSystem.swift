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

public final class PlayerMovementSystem {
    private let entityComponents: EntityComponents
    
    public init(entityComponents: EntityComponents) {
        self.entityComponents = entityComponents
    }
    
    public func handleEvent(event: EngineEvent) {
        let camera = entityComponents.getEntitiesWithComponentType(ProjectionComponent.self).first!
        let oldOrientation = entityComponents.componentForEntity(camera, withComponentType: OrientationComponent.self)
        var position = oldOrientation.position
        var pitch = oldOrientation.pitch
        var yaw = oldOrientation.yaw
        
        switch event.kind {
        case .Look(let direction):
            pitch += direction.up
            
            if pitch < Angle(degrees: -85.0) {
                pitch = Angle(degrees: -85.0)
            }
            
            if pitch > Angle(degrees: 85.0) {
                pitch = Angle(degrees: 85.0)
            }

            yaw += direction.right
//            print("pitch: \(orientation.pitch.degrees), yaw: \(orientation.yaw.degrees)")
            
        case .Move(let direction):
            var updatedOrientation = oldOrientation
            
            if direction.x == .Right {
                updatedOrientation = updatedOrientation.moveRightByAmount(0.1)
            }
            else if direction.x == .Left {
                updatedOrientation = updatedOrientation.moveRightByAmount(-0.1)
            }
            
            if direction.y == .Up {
                updatedOrientation = updatedOrientation.moveUpByAmount(0.1)
            }
            else if direction.y == .Down {
                updatedOrientation = updatedOrientation.moveUpByAmount(-0.1)
            }
            
            if direction.z == .Forward {
                updatedOrientation = updatedOrientation.moveForwardByAmount(0.1)
            }
            else if direction.z == .Backward {
                updatedOrientation = updatedOrientation.moveForwardByAmount(-0.1)
            }
            
            position = updatedOrientation.position
            
        case .ResetCamera:
            position = Point3D(0.0, 0.0, -4.0)
            pitch = Angle()
            yaw = Angle()
        case .ExitInputContext:
            fatalError("Handle this in Engine")
        }
        
        let newOrientation = OrientationComponent(
            position: position,
            pitch: pitch,
            yaw: yaw
        )
        
        entityComponents.replaceComponent(newOrientation, forEntity: camera)
    }
}
