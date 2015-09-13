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

public struct LookDirection {
    public var up: Angle
    public var right: Angle
    
    public init(up: Angle, right: Angle) {
        self.up = up
        self.right = right
    }
}

public enum MoveXDirection {
    case None
    case Right
    case Left
}

public enum MoveYDirection {
    case None
    case Up
    case Down
}

public enum MoveZDirection {
    case None
    case Forward
    case Backward
}

public struct MoveDirection {
    public var x: MoveXDirection
    public var y: MoveYDirection
    public var z: MoveZDirection
    
    public init(x: MoveXDirection, y: MoveYDirection, z: MoveZDirection) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct Event {
    public enum System {
        case Input
    }
    
    public enum Kind {
        case Look(LookDirection)
        case Move(MoveDirection)
        case ResetCamera
    }
    
    public let system: System
    public let kind: Kind
    public let timestamp: Time
    
    public init(system: System, kind: Kind, timestamp: Time) {
        self.system = system
        self.kind = kind
        self.timestamp = timestamp
    }
}
