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

public class Timer {
    private enum State {
        case Initial
        case Running
        case Paused
        case Stopped
    }
    
    private var state = State.Initial
    private var totalTickCount: UInt64 = 0
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let dispatchTimer: DispatchTimer
    private let callbackQueue: DispatchQueue
    private var _updateHandler: ((Int, Duration) -> ())?
    
    public init(platform: Platform, name: String, tickDuration: Duration, callbackQueue: DispatchQueue) {
        self.callbackQueue = callbackQueue
        let queue = DispatchQueue.queueWithName(name, attribute: .Serial, qosClass: .UserInteractive, relativePriority: -1)
        self.dispatchTimer = DispatchTimer(strict: true, queue: queue)
        let interval = tickDuration  / 4 // Go slightly faster
        let leeway = interval / 10 // https://developer.apple.com/library/prerelease/mac/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/Timers.html
        self.dispatchTimer.timerWithInterval(interval, leeway: leeway)

        self.dispatchTimer.registrationHandler { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.previousTime = platform.currentTime
        }
        
        self.dispatchTimer.eventHandler { [weak self] in
            guard let strongSelf = self else { return }
            
            if strongSelf.state != .Running { return }
            if strongSelf._updateHandler == nil { return }
            
            let currentTime = platform.currentTime
            strongSelf.accumulatedTime += (currentTime - strongSelf.previousTime)
            strongSelf.previousTime = currentTime

            var tickCount = 0
            
            while strongSelf.accumulatedTime >= tickDuration {
                ++tickCount
                strongSelf.accumulatedTime -= tickDuration
            }
            
            if tickCount > 0 {
                strongSelf.totalTickCount += UInt64(tickCount)
                
                let updateHandler = strongSelf._updateHandler!
                
                strongSelf.callbackQueue.dispatchSerialized {
                    updateHandler(tickCount, tickDuration)
                }
            }
        }
    }
    
    public func updateHandler(handler: ((Int, Duration) -> ())?) {
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
