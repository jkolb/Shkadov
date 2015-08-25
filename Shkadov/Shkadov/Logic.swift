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

public class Logic: Synchronizable {
    public let synchronizationQueue: DispatchQueue
    public var state: WorldState
    
    public init() {
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.logic", attribute: .Concurrent)
        self.state = WorldState()
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        synchronizeWrite { logic in
            logic.state.camera.updateWithAspectRatio(viewport.aspectRatio, fovy: Angle(degrees: 65.0))
        }
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration, render: (RenderState) -> ()) {
        synchronizeWrite { logic in
            // Generate the data for a frame
            let updateAmount: Float = 0.01
            let viewMatrix = logic.state.camera.viewMatrix
            var renderObjects = [RenderObject]()
            
            for cube in logic.state.cubes {
                cube.modelViewMatrix = viewMatrix * cube.modelMatrix
                cube.modelViewProjectionMatrix = logic.state.camera.projectionMatrix * cube.modelViewMatrix
                
                cube.lookRightByAmount(Angle(radians: updateAmount))
                cube.lookUpByAmount(Angle(radians: updateAmount))
                
                renderObjects.append(RenderObject(modelViewProjectionMatrix: cube.modelViewProjectionMatrix, normalMatrix: cube.normalMatrix))
            }
            
            // Pass data to render queue for processing
            render(RenderState(objects: renderObjects))
        }
    }
}
