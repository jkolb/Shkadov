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

public class MovementInputContext : InputContext {
    private var keyDown: Set<RawInputKeyCode>
    private var buttonDown: Set<RawInputButtonCode>
    public private(set) var mousePosition: Point2D
    public private(set) var mouseDelta: Vector2D
    
    public init() {
        self.keyDown = Set<RawInputKeyCode>()
        self.buttonDown = Set<RawInputButtonCode>()
        self.mousePosition = Point2D.zero
        self.mouseDelta = Vector2D.zero
    }
    
    private func isKeyDown(keyCode: RawInputKeyCode) -> Bool {
        return keyDown.contains(keyCode)
    }
    
    private func isButtonDown(buttonCode: RawInputButtonCode) -> Bool {
        return buttonDown.contains(buttonCode)
    }
    
    private func handleInputEvents(inputEvents: [RawInputEvent]) {
        for inputEvent in inputEvents {
            switch inputEvent.kind {
            case .KeyDown(let keyCode):
                keyDown.insert(keyCode)
                
            case .KeyUp(let keyCode):
                keyDown.remove(keyCode)
                
            case .ButtonDown(let buttonCode):
                buttonDown.insert(buttonCode)
                
            case .ButtonUp(let buttonCode):
                buttonDown.remove(buttonCode)
                
            case .MousePosition(let position):
                mousePosition = position
                
            case .MouseDelta(let delta):
                mouseDelta = delta
                
            default:
                print("Unhandled input event:", inputEvent, separator: " ", terminator: "\n")
            }
        }
    }
    
    public func translateInputEvents(inputEvents: [RawInputEvent]) -> [EngineEventKind] {
        handleInputEvents(inputEvents)
        
        var moveDirection = MoveDirection(x: .None, y: .None, z: .None)
        
        if isKeyDown(.W) && !isKeyDown(.S) {
            moveDirection.z = .Forward
        }
        else if isKeyDown(.S) && !isKeyDown(.W) {
            moveDirection.z = .Backward
        }
        
        if isKeyDown(.A) && !isKeyDown(.D) {
            moveDirection.x = .Left
        }
        else if isKeyDown(.D) && !isKeyDown(.A) {
            moveDirection.x = .Right
        }
        
        if isKeyDown(.SPACE) && !isKeyDown(.LSHIFT) {
            moveDirection.y = .Up
        }
        else if isKeyDown(.LSHIFT) && !isKeyDown(.SPACE) {
            moveDirection.y = .Down
        }
        
        let hAngle = Angle(radians: mouseDelta.dx * 0.001)
        let vAngle = Angle(radians: mouseDelta.dy * 0.001)
        let lookDirection = LookDirection(up: vAngle, right: hAngle)

        mouseDelta = Vector2D.zero // Reset delta after use to make sure it doesn't continue to cause movement
        
        if isKeyDown(.ESCAPE) {
            return [EngineEventKind.ExitInputContext]
        } else if isKeyDown(.R) {
            return [EngineEventKind.ResetCamera]
        }
        else {
            return [EngineEventKind.Move(moveDirection), EngineEventKind.Look(lookDirection)]
        }
    }
}
