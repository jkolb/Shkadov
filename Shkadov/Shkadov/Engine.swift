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
    private let platform: Platform
    private let input: Input
    private let logic: Logic
    private let timer: Timer
    private var eventHandlers: [Event.System:[Component]]
    private let entityComponents: EntityComponents
    private let renderSystem: RenderSystem
    private let inputSystem: InputSystem
    private var lookDirection = LookDirection(up: Angle.zero, right: Angle.zero)
    private var moveDirection = MoveDirection(x: .None, y: .None, z: .None)

    public init(platform: Platform, renderer: Renderer) {
        self.synchronizationQueue = DispatchQueue.globalQueueWithQOS(.UserInitiated)
        self.entityComponents = EntityComponents()
        self.platform = platform
        self.input = Input()
        self.logic = Logic(entityComponents: self.entityComponents)
        self.timer = Timer(platform: platform, name: "net.franticapparatus.shkadov.timer", tickDuration: Duration(seconds: 1.0 / 60.0))
        self.eventHandlers = [:]
        self.renderSystem = RenderSystem(renderer: renderer, entityComponents: self.entityComponents)
        self.inputSystem = InputSystem(entityComponents: self.entityComponents)
    }
    
    public func postDownEventForKeyCode(keyCode: Input.KeyCode) {
        postInputEventForKind(.KeyDown(keyCode))
    }
    
    public func postUpEventForKeyCode(keyCode: Input.KeyCode) {
        postInputEventForKind(.KeyUp(keyCode))
    }
    
    public func postDownEventForButtonCode(buttonCode: Input.ButtonCode) {
        postInputEventForKind(.ButtonDown(buttonCode))
    }
    
    public func postUpEventForButtonCode(buttonCode: Input.ButtonCode) {
        postInputEventForKind(.ButtonUp(buttonCode))
    }
    
    public func postMousePositionEvent(position: Point2D) {
        postInputEventForKind(.MousePosition(position))
    }
    
    private func postInputEventForKind(kind: Input.Event.Kind) {
        let event = Input.Event(kind: kind, timestamp: platform.currentTime)
        input.postEvent(event)
    }
    
    public func start() {
        renderSystem.configure()
        timer.delegate = self
        timer.start()
    }

    public func stop() {
        timer.stop()
    }
    
    private func handleInput() {
        let inputEvents = input.drainEventsBeforeTime(platform.currentTime)
        
        for inputEvent in inputEvents {
            switch inputEvent.kind {
            case .KeyDown(let keyCode):
                if keyCode == .W && keyCode == .S {
                    moveDirection.z = .None
                }
                else if keyCode == .W {
                    moveDirection.z = .Forward
                }
                else if keyCode == .S {
                    moveDirection.z = .Backward
                }
                
                if keyCode == .D && keyCode == .A {
                    moveDirection.x = .None
                }
                else if keyCode == .D {
                    moveDirection.x = .Right
                }
                else if keyCode == .A {
                    moveDirection.x = .Left
                }

                if keyCode == .SPACE && keyCode == .C {
                    moveDirection.y = .None
                }
                else if keyCode == .SPACE {
                    moveDirection.y = .Up
                }
                else if keyCode == .C {
                    moveDirection.y = .Down
                }
                
            case .KeyUp(let keyCode):
                if keyCode == .W && moveDirection.z == .Forward {
                    moveDirection.z = .None
                }
                else if keyCode == .S && moveDirection.z == .Backward {
                    moveDirection.z = .None
                }
                
                if keyCode == .D && moveDirection.x == .Right {
                    moveDirection.x = .None
                }
                else if keyCode == .A && moveDirection.x == .Left {
                    moveDirection.x = .None
                }
                
                if keyCode == .SPACE && moveDirection.y == .Up {
                    moveDirection.y = .None
                }
                else if keyCode == .C && moveDirection.y == .Down {
                    moveDirection.y = .None
                }

            case .MousePosition(let position):
                lookDirection.right = angleFromMouseX(position.x)
                lookDirection.up = angleFromMouseY(position.y)
            default:
                print("Unhandled input event:", inputEvent, separator: " ", terminator: "\n")
            }
        }
        
        dispatchEvent(Event(system: .Input, kind: .Look(lookDirection), timestamp: platform.currentTime))
        dispatchEvent(Event(system: .Input, kind: .Move(moveDirection), timestamp: platform.currentTime))
    }

    private func angleFromMouseX(x: GeometryType) -> Angle {
        return Vector2D(dx: x, dy: 0.0).angle
    }
    
    private func angleFromMouseY(y: GeometryType) -> Angle {
        return Vector2D(dx: y, dy: 0.0).angle
    }
    
    private func dispatchEvent(event: Event) {
        inputSystem.handleEvent(event)
    }
    
    public func timer(timer: Timer, didFireWithTickCount tickCount: Int, tickDuration: Duration) {
        synchronizeWrite { engine in
            engine.handleInput()
            
            engine.logic.updateWithTickCount(tickCount, tickDuration: tickDuration)
            engine.renderSystem.updateWithTickCount(tickCount, tickDuration: tickDuration)
        }
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        renderSystem.updateViewport(viewport)
    }
}
