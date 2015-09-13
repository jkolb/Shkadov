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

public class Logic : Synchronizable {
    public let synchronizationQueue: DispatchQueue
    private let renderSystem: RenderSystem
    private let testCubeSystem: TestCubeSystem

    public init(renderer: Renderer, entityComponents: EntityComponents) {
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.logic", attribute: .Concurrent)
        self.testCubeSystem = TestCubeSystem(renderer: renderer, entityComponents: entityComponents)
        self.renderSystem = RenderSystem(renderer: renderer, entityComponents: entityComponents)
    }
    
    public func configure() {
        synchronizeWriteAndWait { logic in
            logic.renderSystem.configure()
            logic.testCubeSystem.configure()
        }
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
        synchronizeWriteAndWait { logic in
            logic.testCubeSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
            logic.renderSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
        }
    }
    
    public func render() {
        synchronizeWriteAndWait { logic in
            logic.testCubeSystem.render()
        }
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        synchronizeWriteAndWait { logic in
            logic.renderSystem.updateViewport(viewport)
        }
    }
}
