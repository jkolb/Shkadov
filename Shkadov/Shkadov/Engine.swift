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

public final class Engine {
    private var platform: Platform
    private let rawInputEventBuffer: RawInputEventBuffer
    private var inputContext: InputContext
    private var eventHandlers: [EngineEventSystem:[Component]]
    private let entityComponents: EntityComponents
    private let playerMovementSystem: PlayerMovementSystem
    private let renderSystem: RenderSystem
    private let testSystem0: TestIcosahedronSystem
    private let testSystem1: TestCubeSystem
    private let terrainSystem: TerrainSystem
    private let renderer: Renderer
    private var menuOpen = false
    
    private var isRunning: Bool = false
    private var totalTickCount: UInt64 = 0
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let tickDuration: Duration = Duration(seconds: 1.0 / 60.0)
    
    public init(platform: Platform, renderer: Renderer, assetLoader: AssetLoader) {
        self.entityComponents = EntityComponents()
        self.platform = platform
        self.rawInputEventBuffer = RawInputEventBuffer()
        self.eventHandlers = [:]
        self.playerMovementSystem = PlayerMovementSystem(entityComponents: self.entityComponents)
        self.inputContext = MovementInputContext()
        self.testSystem0 = TestIcosahedronSystem(renderer: renderer, assetLoader: assetLoader, entityComponents: entityComponents)
        self.testSystem1 = TestCubeSystem(renderer: renderer, assetLoader: assetLoader, entityComponents: entityComponents)
        self.terrainSystem = TerrainSystem(renderer: renderer, assetLoader: assetLoader, entityComponents: entityComponents)
        self.renderSystem = RenderSystem(renderer: renderer, entityComponents: entityComponents)
        self.renderer = renderer
    }
    
    public func postInputEventForKind(kind: RawInputEventKind) {
        let event = RawInputEvent(kind: kind, timestamp: platform.currentTime)
        rawInputEventBuffer.postEvent(event)
    }
    
    public func start() {
        platform.centerMouse()
        platform.mousePositionRelative = true
        renderSystem.configure()
        terrainSystem.configure()
        testSystem0.configure()
        testSystem1.configure()
        
        isRunning = true
        main()
    }

    public func stop() {
        isRunning = false
        platform.mousePositionRelative = false
    }
    
    public func main() {
        while isRunning {
            let currentTime = platform.currentTime
            accumulatedTime += (currentTime - previousTime)
            previousTime = currentTime
            
            var tickCount = 0
            
            while accumulatedTime >= tickDuration {
                ++tickCount
                accumulatedTime -= tickDuration
            }
            
            if tickCount > 0 {
                totalTickCount += UInt64(tickCount)
                render(tickCount)
            }
        }
    }
    
    public func render(tickCount: Int) {
        handleInput()
        
        terrainSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
        testSystem0.updateWithTickCount(tickCount, tickDuration: tickDuration)
        testSystem1.updateWithTickCount(tickCount, tickDuration: tickDuration)
        renderSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
        
        var states = [RenderState]()
        
        states.append(testSystem0.render())
        states.append(testSystem1.render())
        states.append(terrainSystem.render())
        
        renderer.renderStates(states)
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
    
    public func updateViewport(viewport: Rectangle2D) {
        renderSystem.updateViewport(viewport)
    }
}
