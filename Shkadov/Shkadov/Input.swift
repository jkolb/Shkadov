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

public class Input: Synchronizable {
    public let synchronizationQueue: DispatchQueue
    private var events: [Event]
    
    public init() {
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.input", attribute: .Concurrent)
        self.events = [Event]()
    }

    public func postEvent(event: Event) {
        synchronizeWrite { input in
            input.events.append(event)
        }
    }
    
    public func drainEventsBeforeTime(time: Time) -> [Event] {
        return synchronizeReadWrite { input in
            let events = input.events
            var foundEvents = [Event]()
            
            for event in events {
                if event.timestamp <= time {
                    foundEvents.append(event)
                }
                else {
                    break
                }
            }
            
            input.events.removeRange(0..<foundEvents.count)
            
            return foundEvents
        }
    }
    
    public struct Event {
        public enum Kind {
            case ButtonDown(ButtonCode)
            case ButtonUp(ButtonCode)
            case JoystickAxis(Vector2D)
            case KeyDown(KeyCode)
            case KeyUp(KeyCode)
            case MousePosition(Point2D)
            case ScrollWheel(Vector2D)
        }
        
        public let kind: Kind
        public let timestamp: Time
        
        public init(kind: Kind, timestamp: Time) {
            self.kind = kind
            self.timestamp = timestamp
        }
    }

    public enum ButtonCode : UInt8 {
        case INVALID = 0
        
        case MOUSE0  = 1
        case MOUSE1  = 2
        case MOUSE2  = 3
        case MOUSE3  = 4
        case MOUSE4  = 5
        case MOUSE5  = 6
        case MOUSE6  = 7
        case MOUSE7  = 8
        case MOUSE8  = 9
        case MOUSE9  = 10
        case MOUSE10 = 11
        case MOUSE11 = 12
        case MOUSE12 = 13
        case MOUSE13 = 14
        case MOUSE14 = 15
        case MOUSE15 = 16
        
        case UNKNOWN = 255
    }
    
    public enum KeyCode : UInt8 {
        case INVALID = 0
        
        case A = 1
        case B = 2
        case C = 3
        case D = 4
        case E = 5
        case F = 6
        case G = 7
        case H = 8
        case I = 9
        case J = 10
        case K = 11
        case L = 12
        case M = 13
        case N = 14
        case O = 15
        case P = 16
        case Q = 17
        case R = 18
        case S = 19
        case T = 20
        case U = 21
        case V = 22
        case W = 23
        case X = 24
        case Y = 25
        case Z = 26
        // 27 - 49
        case ZERO  = 50
        case ONE   = 51
        case TWO   = 52
        case THREE = 53
        case FOUR  = 54
        case FIVE  = 55
        case SIX   = 56
        case SEVEN = 57
        case EIGHT = 58
        case NINE  = 59
        // 60 - 69
        case GRAVE = 70
        case MINUS = 71
        case EQUALS = 72
        case LBRACKET = 73
        case RBRACKET = 74
        case BACKSLASH = 75
        case SEMICOLON = 76
        case APOSTROPHE = 77
        case COMMA = 78
        case PERIOD = 79
        case SLASH = 80
        case TAB = 83
        case SPACE = 84
        // 85 - 99
        case CAPSLOCK  = 100 // Toggle only
        case RETURN    = 101
        case LSHIFT    = 102
        case RSHIFT    = 103
        case LCONTROL  = 104
        case RCONTROL  = 105
        case LALT      = 106
        case RALT      = 107
        case LMETA     = 108
        case RMETA     = 109
        case INSERT    = 110 // fn
        case DELETE    = 111
        case HOME      = 112
        case END       = 113
        case PAGEUP    = 114
        case PAGEDOWN  = 115
        case ESCAPE    = 116
        case BACKSPACE = 117 // DELETE
        case SYSRQ     = 118 // Windows
        case SCROLL    = 119 // Windows
        case PAUSE     = 120 // Windows
        // 121 - 159
        case UP    = 160
        case DOWN  = 161
        case LEFT  = 162
        case RIGHT = 163
        // 164 - 169
        case NUMLOCK         = 170 // CLEAR
        case NUMPAD_ZERO     = 171
        case NUMPAD_ONE      = 172
        case NUMPAD_TWO      = 173
        case NUMPAD_THREE    = 174
        case NUMPAD_FOUR     = 175
        case NUMPAD_FIVE     = 176
        case NUMPAD_SIX      = 177
        case NUMPAD_SEVEN    = 178
        case NUMPAD_EIGHT    = 179
        case NUMPAD_NINE     = 180
        case NUMPAD_EQUALS   = 181
        case NUMPAD_DIVIDE   = 182
        case NUMPAD_MULTIPLY = 183
        case NUMPAD_SUBTRACT = 184
        case NUMPAD_ADD      = 185
        case NUMPAD_DECIMAL  = 186
        case NUMPAD_ENTER    = 187
        // 188 - 189
        case F1  = 190
        case F2  = 191
        case F3  = 192
        case F4  = 193
        case F5  = 194
        case F6  = 195
        case F7  = 196
        case F8  = 197
        case F9  = 198
        case F10 = 199
        case F11 = 200
        case F12 = 201
        case F13 = 202
        case F14 = 203
        case F15 = 204
        case F16 = 205
        case F17 = 206
        case F18 = 207
        case F19 = 208
        case F20 = 209
        // 210 - 254
        case UNKNOWN = 255
    }
}
