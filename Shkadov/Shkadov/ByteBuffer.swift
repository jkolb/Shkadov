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

public final class ByteBuffer {
    private static let undefinedMark = -1
    private var bytes: UnsafeMutablePointer<UInt8>
    public let capacity: Int
    private let deallocOnDeinit: Bool
    private var bits: UnsafeMutablePointer<UInt8>
    public var position: Int {
        willSet {
            // The new position value; must be non-negative and no larger than the current limit
            precondition(newValue >= 0)
            precondition(newValue <= limit)
        }
        didSet {
            // If the mark is defined and larger than the new position then it is discarded.
            if markedPosition > position {
                discardMark()
            }
        }
    }
    public var limit: Int {
        willSet {
            // The new limit value; must be non-negative and no larger than this buffer's capacity
            precondition(newValue >= 0)
            precondition(newValue <= capacity)
        }
        didSet {
            // If the position is larger than the new limit then it is set to the new limit.
            if position > limit {
                position = limit
            }
            
            // If the mark is defined and larger than the new limit then it is discarded.
            if markedPosition > limit {
                discardMark()
            }
        }
    }
    private var markedPosition: Int
    private func discardMark() {
        markedPosition = ByteBuffer.undefinedMark
    }
    
    public convenience init(capacity: Int) {
        precondition(capacity >= 0)
        
        let data = UnsafeMutablePointer<UInt8>.alloc(capacity)
        
        self.init(data: data, length: capacity, deallocOnDeinit: true)
    }
    
    public init(data: UnsafeMutablePointer<Void>, length: Int, deallocOnDeinit: Bool = false) {
        precondition(length >= 0)
        
        self.bytes = UnsafeMutablePointer<UInt8>(data)
        self.capacity = length
        self.deallocOnDeinit = deallocOnDeinit
        
        self.bits = UnsafeMutablePointer<UInt8>.alloc(sizeof(UIntMax))
        
        // The new buffer's position will be zero, its limit will be its capacity, its mark will be undefined.
        self.position = 0
        self.limit = capacity
        self.markedPosition = ByteBuffer.undefinedMark
    }
    
    deinit {
        bits.dealloc(sizeof(UIntMax))
        
        if deallocOnDeinit {
            bytes.dealloc(capacity)
        }
    }
    
    public var data: UnsafePointer<Void> {
        return UnsafePointer<Void>(bytes)
    }
    
    public func mark() {
        // Sets this buffer's mark at its position.
        markedPosition = position
    }
    
    public func reset() {
        precondition(markedPosition != ByteBuffer.undefinedMark)
        // Resets this buffer's position to the previously-marked position.
        // Invoking this method neither changes nor discards the mark's value.
        position = markedPosition
    }
    
    public func clear() {
        // Clears this buffer. The position is set to zero, the limit is set to the capacity, and the mark is discarded.
        position = 0
        limit = capacity
        discardMark()
    }
    
    public func flip() {
        // Flips this buffer. The limit is set to the current position and then the position is set to zero. If the mark is defined then it is discarded.
        limit = position
        position = 0
        discardMark()
    }
    
    public func rewind() {
        // Rewinds this buffer. The position is set to zero and the mark is discarded.
        position = 0
        discardMark()
    }
    
    public var remaining: Int {
        // Returns the number of elements between the current position and the limit.
        return limit - position
    }
    
    public var hasRemaining: Bool {
        // Tells whether there are any elements between the current position and the limit.
        return remaining > 0
    }
    
    public func compact() {
        bytes.moveInitializeFrom(bytes + position, count: remaining)
        position = remaining
        limit = capacity
    }

    public func getNextValue<T : Bufferable>() -> T {
        for index in 0..<sizeof(T) {
            bits[index] = bytes[position++]
        }
        
        return UnsafePointer<T>(bits).memory
    }
    
    public func putNextValue<T : Bufferable>(value: T) {
        UnsafeMutablePointer<T>(bits).memory = value
        
        for index in 0..<sizeof(T) {
            bytes[position++] = bits[index]
        }
    }
}

public protocol Bufferable {
}

extension Float32 : Bufferable {
}

extension Float64 : Bufferable {
}

extension Int8 : Bufferable {
}

extension Int16 : Bufferable {
}

extension Int32 : Bufferable {
}

extension UInt8 : Bufferable {
}

extension UInt16 : Bufferable {
}

extension UInt32 : Bufferable {
}

extension ByteBuffer {
    public func putNextValue(value: Point2D) {
        putNextValue(value.x)
        putNextValue(value.y)
    }
    
    public func putNextValue(value: Vector2D) {
        putNextValue(value.x)
        putNextValue(value.y)
    }
    
    public func putNextValue(value: Point3D) {
        putNextValue(value.x)
        putNextValue(value.y)
        putNextValue(value.z)
    }
    
    public func putNextValue(value: Vector3D) {
        putNextValue(value.x)
        putNextValue(value.y)
        putNextValue(value.z)
    }
    
    public func putNextValue(value: Color) {
        putNextValue(value.red)
        putNextValue(value.green)
        putNextValue(value.blue)
        putNextValue(value.alpha)
    }
    
    public func putNextValue(value: ColorRGBA8) {
        putNextValue(value.red)
        putNextValue(value.green)
        putNextValue(value.blue)
        putNextValue(value.alpha)
    }
}
