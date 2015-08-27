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

public final class Engine {
    private let platform: Platform
    private let input: Input
    private let logic: Logic
    private var renderer: Renderer
    private let timer: Timer

    public init(platform: Platform, renderer: Renderer) {
        self.platform = platform
        self.input = Input()
        self.logic = Logic()
        self.renderer = renderer
        self.timer = Timer(platform: platform, name: "net.franticapparatus.shkadov.timer", tickDuration: Duration(seconds: 1.0 / 60.0))
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
    
    public func beginSimulation() {
        renderer.configure()

        let weakUpdateWithTickCount: (Int, Duration) -> () = { [weak self] (tickCount, tickDuration) in
            guard let strongSelf = self else { return }
            
            Engine.updateWithTickCount(strongSelf)(tickCount, tickDuration: tickDuration)
        }

        timer.updateHandler = weakUpdateWithTickCount

        timer.start()
    }

    private func handleInput() {
        let inputEvents = input.drainEventsBeforeTime(platform.currentTime)
        var lookDirection = LookDirection(up: Angle.zero, right: Angle.zero)
        var moveDirection = MoveDirection(x: .None, y: .None, z: .None)
        
        for inputEvent in inputEvents {
            switch inputEvent.kind {
            case .KeyDown(let keyCode):
                switch keyCode {
                case .W:
                    moveDirection.z = .Forward
                case .A:
                    moveDirection.x = .Left
                case .S:
                    moveDirection.z = .Backward
                case .D:
                    moveDirection.x = .Right
                default:
                    print("Unhandled down key code:", keyCode, separator: " ", terminator: "\n")
                }
            case .KeyUp(let keyCode):
                switch keyCode {
                case .W:
                    moveDirection.z = .None
                case .A:
                    moveDirection.x = .None
                case .S:
                    moveDirection.z = .None
                case .D:
                    moveDirection.x = .None
                default:
                    print("Unhandled up key code:", keyCode, separator: " ", terminator: "\n")
                }
            case .MousePosition(let position):
                lookDirection.right = angleFromMouseY(position.x)
                lookDirection.up = angleFromMouseY(position.y)
            default:
                print("Unhandled input event:", inputEvent, separator: " ", terminator: "\n")
            }
        }
        
        dispatchEvent(Event(kind: .Look(lookDirection), timestamp: platform.currentTime))
        dispatchEvent(Event(kind: .Move(moveDirection), timestamp: platform.currentTime))
    }

    private func angleFromMouseX(x: GeometryType) -> Angle {
        return Angle.zero
    }
    
    private func angleFromMouseY(y: GeometryType) -> Angle {
        return Angle.zero
    }
    
    private func dispatchEvent(event: Event) {
        
    }
    
    private func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
        handleInput()
        
        logic.updateWithTickCount(tickCount, tickDuration: tickDuration) { [weak self] (renderState) in
            guard let strongSelf = self else { return }
            strongSelf.renderer.renderState(renderState)
        }
    }
    
    public func updateViewport(viewport: Rectangle2D) {
        logic.updateViewport(viewport)
        renderer.updateViewport(viewport)
    }
}
