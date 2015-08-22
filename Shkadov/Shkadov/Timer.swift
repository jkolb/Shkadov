//
//  Timer.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/22/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import CoreServices
import Darwin
import Foundation

public class Timer {
    private enum State {
        case Initial
        case Running
        case Paused
        case Stopped
    }
    
    private var state = State.Initial
    private var totalTickCount: UInt64 = 0
    private var previousTime: UInt64 = 0
    private var accumulatedTime: UInt64 = 0
    private let dispatchTimer: DispatchTimer
    private let callbackQueue: DispatchQueue
    private var _updateHandler: ((Int, UInt64) -> ())?
    
    public init(name: String, nanosecondsPerTick: UInt64, callbackQueue: DispatchQueue) {
        self.callbackQueue = callbackQueue
        let queue = DispatchQueue.queueWithName(name, attribute: .Serial, qosClass: .UserInteractive, relativePriority: -1)
        self.dispatchTimer = DispatchTimer(strict: true, queue: queue)
        let interval = nanosecondsPerTick  / 4 // Go slightly faster
        let leeway = interval / 10 // https://developer.apple.com/library/prerelease/mac/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/Timers.html
        self.dispatchTimer.timerWithInterval(UInt64(interval), leeway: UInt64(leeway))

        var timeBaseInfo = mach_timebase_info_data_t()
        mach_timebase_info(&timeBaseInfo)
        let timeBaseNumerator = UInt64(timeBaseInfo.numer)
        let timeBaseDenominator = UInt64(timeBaseInfo.denom)

        self.dispatchTimer.registrationHandler { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.previousTime = mach_absolute_time()
        }
        
        self.dispatchTimer.eventHandler { [weak self] in
            guard let strongSelf = self else { return }
            
            if strongSelf.state != .Running { return }
            if strongSelf._updateHandler == nil { return }
            
            let currentTime = mach_absolute_time()
            strongSelf.accumulatedTime += (currentTime - strongSelf.previousTime) * timeBaseNumerator / timeBaseDenominator
            strongSelf.previousTime = currentTime

            var tickCount = 0
            
            while strongSelf.accumulatedTime >= nanosecondsPerTick {
                ++tickCount
                strongSelf.accumulatedTime -= nanosecondsPerTick
            }
            
            if tickCount > 0 {
                strongSelf.totalTickCount += UInt64(tickCount)
                
                let updateHandler = strongSelf._updateHandler!
                
                strongSelf.callbackQueue.dispatchSerialized {
                    updateHandler(tickCount, nanosecondsPerTick)
                }
            }
        }
    }
    
    public func updateHandler(handler: ((Int, UInt64) -> ())?) {
        dispatchTimer.queue.dispatchSerialized { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf._updateHandler = handler
        }
    }
    
    public func startWithHandler(handler: () -> ()) {
        dispatchTimer.queue.dispatchSerialized { [weak self] in
            guard let strongSelf = self else { return }
            
            precondition(strongSelf.state == .Initial)
            strongSelf.state = .Running
            strongSelf.callbackQueue.dispatchSerialized(handler)
            strongSelf.dispatchTimer.resume()
        }
    }
    
    public func resumeWithHandler(handler: () -> ()) {
        dispatchTimer.queue.dispatchSerialized { [weak self] in
            guard let strongSelf = self else { return }
            
            precondition(strongSelf.state == .Paused)
            strongSelf.state = .Running
            strongSelf.callbackQueue.dispatchSerialized(handler)
            strongSelf.dispatchTimer.resume()
        }
    }
    
    public func pauseWithHandler(handler: () -> ()) {
        dispatchTimer.queue.dispatchSerialized { [weak self] in
            guard let strongSelf = self else { return }
            
            precondition(strongSelf.state == .Running)
            strongSelf.state = .Paused
            strongSelf.callbackQueue.dispatchSerialized(handler)
            strongSelf.dispatchTimer.suspend()
        }
    }
    
    public func stopWithHandler(handler: () -> ()) {
        dispatchTimer.queue.dispatchSerialized { [weak self] in
            guard let strongSelf = self else { return }
            
            precondition(strongSelf.state == .Running)
            strongSelf.state = .Stopped
            strongSelf.callbackQueue.dispatchSerialized(handler)
            strongSelf.dispatchTimer.cancel()
        }
    }
}
