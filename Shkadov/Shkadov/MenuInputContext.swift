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

public class MenuInputContext : InputContext {
    private var keyDown: Set<RawInputKeyCode>
    
    public init() {
        self.keyDown = Set<RawInputKeyCode>()
    }
    
    private func isKeyDown(keyCode: RawInputKeyCode) -> Bool {
        return keyDown.contains(keyCode)
    }
    
    private func handleInputEvents(inputEvents: [RawInputEvent]) {
        for inputEvent in inputEvents {
            switch inputEvent.kind {
            case .KeyDown(let keyCode):
                keyDown.insert(keyCode)
                
            case .KeyUp(let keyCode):
                keyDown.remove(keyCode)

            default:
                print("Unhandled input event:", inputEvent, separator: " ", terminator: "\n")
            }
        }
    }
    
    public func translateInputEvents(inputEvents: [RawInputEvent]) -> [EngineEventKind] {
        handleInputEvents(inputEvents)
        if isKeyDown(.ESCAPE) {
            return [EngineEventKind.ExitInputContext]
        } else {
            return []
        }
    }
}
