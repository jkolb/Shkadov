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

public class RawInputEventBuffer : Synchronizable {
    public let synchronizationQueue: DispatchQueue
    private var events: [RawInput.Event]
    
    public init() {
        self.synchronizationQueue = DispatchQueue.queueWithName("net.franticapparatus.shkadov.input", attribute: .Concurrent)
        self.events = Array<RawInput.Event>()
    }

    public func postEvent(event: RawInput.Event) {
        synchronizeWrite { buffer in
            buffer.events.append(event)
        }
    }
    
    public func drainEventsBeforeTime(time: Time) -> [RawInput.Event] {
        return synchronizeReadWrite { buffer in
            let events = buffer.events
            var foundEvents = Array<RawInput.Event>()
            
            for event in events {
                if event.timestamp <= time {
                    foundEvents.append(event)
                }
                else {
                    break
                }
            }
            
            buffer.events.removeRange(0..<foundEvents.count)
            
            return foundEvents
        }
    }
}
