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

public final class Engine : TimerDelegate, Synchronizable {
    public let synchronizationQueue: DispatchQueue
    private var platform: Platform
    private let rawInputEventBuffer: RawInputEventBuffer
    private let inputContext: InputContext
    private let timer: Timer
    private var eventHandlers: [Event.System:[Component]]
    private let entityComponents: EntityComponents
    private let playerMovementSystem: PlayerMovementSystem
    private let renderSystem: RenderSystem
    private let testCubeSystem: TestCubeSystem

    public init(platform: Platform, renderer: Renderer, assetLoader: AssetLoader) {
        self.synchronizationQueue = DispatchQueue.globalQueueWithQOS(.UserInitiated)
        self.entityComponents = EntityComponents()
        self.platform = platform
        self.rawInputEventBuffer = RawInputEventBuffer()
        self.timer = Timer(platform: platform, name: "net.franticapparatus.shkadov.timer", tickDuration: Duration(seconds: 1.0 / 60.0))
        self.eventHandlers = [:]
        self.playerMovementSystem = PlayerMovementSystem(entityComponents: self.entityComponents)
        self.inputContext = InputContext()
        self.testCubeSystem = TestCubeSystem(renderer: renderer, assetLoader: assetLoader, entityComponents: entityComponents)
        self.renderSystem = RenderSystem(renderer: renderer, entityComponents: entityComponents)
    }
    
    public func postDownEventForKeyCode(keyCode: RawInput.KeyCode) {
        postInputEventForKind(.KeyDown(keyCode))
    }
    
    public func postUpEventForKeyCode(keyCode: RawInput.KeyCode) {
        postInputEventForKind(.KeyUp(keyCode))
    }
    
    public func postDownEventForButtonCode(buttonCode: RawInput.ButtonCode) {
        postInputEventForKind(.ButtonDown(buttonCode))
    }
    
    public func postUpEventForButtonCode(buttonCode: RawInput.ButtonCode) {
        postInputEventForKind(.ButtonUp(buttonCode))
    }
    
    public func postMousePositionEvent(position: Point2D) {
        postInputEventForKind(.MousePosition(position))
    }
    
    public func postMouseDeltaEvent(delta: Vector2D) {
        postInputEventForKind(.MouseDelta(delta))
    }
    
    private func postInputEventForKind(kind: RawInput.Event.Kind) {
        let event = RawInput.Event(kind: kind, timestamp: platform.currentTime)
        rawInputEventBuffer.postEvent(event)
    }
    
    public func start() {
        synchronizeWriteAndWait { engine in
            engine.platform.centerMouse()
            engine.platform.mousePositionRelative = true
            engine.renderSystem.configure()
            engine.testCubeSystem.configure()
            engine.timer.delegate = self
            engine.timer.start()
        }
    }

    public func stop() {
        synchronizeWriteAndWait { engine in
            engine.platform.mousePositionRelative = false
            engine.timer.stop()
        }
    }
    
    private func handleInput() {
        let inputEvents = rawInputEventBuffer.drainEventsBeforeTime(platform.currentTime)
        let eventKinds = inputContext.translateInputEvents(inputEvents)

        for eventKind in eventKinds {
            dispatchEvent(Event(system: .Input, kind: eventKind, timestamp: platform.currentTime))
        }
    }
    
    private func dispatchEvent(event: Event) {
        playerMovementSystem.handleEvent(event)
    }
    
    public func timer(timer: Timer, didFireWithTickCount tickCount: Int, tickDuration: Duration) {
        synchronizeWrite { engine in
            engine.handleInput()
            
            engine.testCubeSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
            engine.renderSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
            engine.testCubeSystem.render()
        }
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        synchronizeWriteAndWait { engine in
            engine.renderSystem.updateViewport(viewport)
        }
    }
}
