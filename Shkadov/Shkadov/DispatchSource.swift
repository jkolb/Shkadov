//
//  DispatchSource.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/22/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

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
