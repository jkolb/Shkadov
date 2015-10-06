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
    private var inputContext: InputContext
    private let timer: Timer
    private var eventHandlers: [EngineEventSystem:[Component]]
    private let entityComponents: EntityComponents
    private let playerMovementSystem: PlayerMovementSystem
    private let renderSystem: RenderSystem
    private let testCubeSystem: TestCubeSystem
    private let terrainSystem: TerrainSystem
    private let renderer: Renderer
    private var menuOpen = false
    
    public init(platform: Platform, renderer: Renderer, assetLoader: AssetLoader) {
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.engine", attribute: .Serial, qosClass: .UserInitiated, relativePriority: -1)
        self.entityComponents = EntityComponents()
        self.platform = platform
        self.rawInputEventBuffer = RawInputEventBuffer()
        self.timer = Timer(platform: platform, name: "net.franticapparatus.shkadov.timer", tickDuration: Duration(seconds: 1.0 / 60.0))
        self.eventHandlers = [:]
        self.playerMovementSystem = PlayerMovementSystem(entityComponents: self.entityComponents)
        self.inputContext = MovementInputContext()
        self.testCubeSystem = TestCubeSystem(renderer: renderer, assetLoader: assetLoader, entityComponents: entityComponents)
        self.terrainSystem = TerrainSystem(renderer: renderer, assetLoader: assetLoader, entityComponents: entityComponents)
        self.renderSystem = RenderSystem(renderer: renderer, entityComponents: entityComponents)
        self.renderer = renderer
    }
    
    public func postInputEventForKind(kind: RawInputEventKind) {
        let event = RawInputEvent(kind: kind, timestamp: platform.currentTime)
        rawInputEventBuffer.postEvent(event)
    }
    
    public func start() {
        synchronizeWrite { engine in
            engine.platform.centerMouse()
            engine.platform.mousePositionRelative = true
            engine.renderSystem.configure()
            engine.terrainSystem.configure()
            engine.testCubeSystem.configure()
            engine.timer.delegate = self
            engine.timer.start()
        }
    }

    public func stop() {
        synchronizeWrite { engine in
            engine.platform.mousePositionRelative = false
            engine.timer.stop()
        }
    }
    
    private func handleInput() {
        let inputEvents = rawInputEventBuffer.drainEventsBeforeTime(platform.currentTime)
        let eventKinds = inputContext.translateInputEvents(inputEvents)

        for eventKind in eventKinds {
            switch eventKind {
            case .ExitInputContext:
                if menuOpen {
                    platform.centerMouse()
                    platform.mousePositionRelative = true
                    inputContext = MovementInputContext()
                    menuOpen = false
                }
                else {
                    platform.mousePositionRelative = false
                    inputContext = MenuInputContext()
                    menuOpen = true
                }
            default:
                if menuOpen {
                }
                else {
                    dispatchEvent(EngineEvent(system: .Input, kind: eventKind, timestamp: platform.currentTime))
                }
            }
        }
    }
    
    private func dispatchEvent(event: EngineEvent) {
        playerMovementSystem.handleEvent(event)
    }
    
    public func timer(timer: Timer, didFireWithTickCount tickCount: Int, tickDuration: Duration) {
        synchronizeWrite { engine in
            engine.handleInput()
            
            engine.terrainSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
            engine.testCubeSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
            engine.renderSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
            
            var states = [RenderState]()
            
            states.append(engine.terrainSystem.render())
            states.append(engine.testCubeSystem.render())
            
            engine.renderer.renderStates(states)
        }
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        synchronizeWrite { engine in
            engine.renderSystem.updateViewport(viewport)
        }
    }
}
