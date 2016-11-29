/*
 The MIT License (MIT)
 
 Copyright (c) 2016 Justin Kolb
 
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

import Swiftish

public final class Game : EngineListener {
    private var engine: Engine!
    
    private var totalDuration = Duration.zero
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let tickDuration = Duration(seconds: 1.0 / 60.0)
    private let maxFrameDuration = Duration(seconds: 0.25)
    private let camera = Camera()

    public init() { }
    
    public func didStartup(engine: Engine) {
        self.engine = engine
        
        engine.logger.trace("")
        camera.projection.fovy = Angle<Float>(degrees: 30.0)
        camera.projection.zNear = 0.1
        camera.projection.zFar = 1000.0
        camera.worldTransform.t = Vector3<Float>(0.0, 0.0, 0.0)
        camera.worldTransform.r = rotation(pitch: Angle<Float>(), yaw: Angle<Float>(), roll: Angle<Float>())
        previousTime = engine.timeSource.currentTime
    }
    
    public func willShutdown() {
        engine.logger.trace("")
        
        do {
            try engine.writeConfig()
        }
        catch {
            engine.logger.error("\(error)")
        }
    }
    
    public  func received(input: RawInput) {
        engine.logger.trace("\(input)")
    }
    
    public func processFrame() {
        engine.logger.trace("")
        //        renderer.waitForNextFrame()
        // var previousState
        
        // var currentState
        
        let currentTime = engine.timeSource.currentTime
        var frameDuration = currentTime - previousTime
        engine.logger.trace("FRAME DURATION: \(frameDuration)")
        
        if frameDuration > maxFrameDuration {
            engine.logger.debug("EXCEEDED FRAME DURATION")
            frameDuration = maxFrameDuration
        }
        
        accumulatedTime += frameDuration
        previousTime = currentTime
        
        while accumulatedTime >= tickDuration {
            // previousState = currentState
            // currentState = integrate(currentState, totalDuration, tickDuration)
            accumulatedTime -= tickDuration
            totalDuration += tickDuration
            
            update(elapsed: tickDuration)
        }
        
        //let alpha = accumulatedTime / tickDuration.nanoseconds
        
        // let state = currentState * alpha + previousState * (1.0 - alpha)
        
        // render(state)
        
        render()
    }
    
    private func update(elapsed: Duration) {
        engine.logger.trace("")
    }
    
    private func render() {
        engine.logger.trace("")
    }
}
