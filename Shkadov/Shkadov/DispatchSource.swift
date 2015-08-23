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

import Dispatch


public class DispatchSource {
    public let queue: DispatchQueue
    public let GCDSource: dispatch_source_t
    
    private init(type: dispatch_source_type_t, handle: UInt, mask: UInt, queue: DispatchQueue) {
        self.queue = queue
        self.GCDSource = dispatch_source_create(type, handle, mask, queue.GCDQueue)
    }

    public func registrationHandler(handler: () -> ()) {
        dispatch_source_set_registration_handler(GCDSource, handler)
    }

    public func eventHandler(handler: () -> ()) {
        dispatch_source_set_event_handler(GCDSource, handler)
    }
    
    public func cancelHandler(handler: () -> ()) {
        dispatch_source_set_cancel_handler(GCDSource, handler)
    }
    
    public var isCancelled: Bool {
        return dispatch_source_testcancel(GCDSource) != 0
    }
    
    public func cancel() {
        dispatch_source_cancel(GCDSource)
    }
    
    public func resume() {
        dispatch_resume(GCDSource)
    }
    
    public func suspend() {
        dispatch_suspend(GCDSource)
    }
}


public class DispatchTimer : DispatchSource {
    public init(strict: Bool, queue: DispatchQueue) {
        super.init(type: DISPATCH_SOURCE_TYPE_TIMER, handle: 0, mask: strict ? DISPATCH_TIMER_STRICT : 0, queue: queue)
    }
    
    public func timerWithInterval(interval: UInt64, leeway: UInt64) {
        timerWithStart(DISPATCH_TIME_NOW, interval: interval, leeway: leeway)
    }
    
    public func timerWithStart(start: dispatch_time_t, interval: UInt64, leeway: UInt64) {
        dispatch_source_set_timer(GCDSource, start, interval, leeway)
    }
}
