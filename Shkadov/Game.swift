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
    private let engine: Engine
    private let logger: Logger

    private var totalDuration = Duration.zero
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let tickDuration = Duration(seconds: 1.0 / 60.0)
    private let maxFrameDuration = Duration(seconds: 0.25)
    private let camera = Camera()

    public init(engine: Engine, logger: Logger) {
        self.engine = engine
        self.logger = logger
    }
    
    public func didStartup() {
        logger.debug("\(#function)")
        logger.debug("Screen Size: \(engine.screensSize)")
        camera.projection.fovy = Angle<Float>(degrees: 30.0)
        camera.projection.zNear = 0.1
        camera.projection.zFar = 1000.0
        camera.worldTransform.t = Vector3<Float>(0.0, 0.0, 0.0)
        camera.worldTransform.r = rotation(pitch: Angle<Float>(), yaw: Angle<Float>(), roll: Angle<Float>())
        engine.followsMouseCursor = true
        engine.mouseCursorHidden = true
        engine.enterFullScreen()
        previousTime = engine.currentTime
    }
    
    public func willShutdown() {
        logger.debug("\(#function)")
        
        do {
            try engine.writeConfig()
        }
        catch {
            logger.error("\(error)")
        }
    }
    
    public func willResizeScreen(size: Vector2<Int>) -> Vector2<Int> {
        logger.debug("\(#function) \(size)")
        return size
    }

    public func didResizeScreen() {
        logger.debug("\(#function)")
    }
    
    public func willMoveScreen() {
        logger.debug("\(#function)")
    }
    
    public func didMoveScreen() {
        logger.debug("\(#function)")
    }
    
    public func willEnterFullScreen() {
        logger.debug("\(#function)")
    }
    
    public func didEnterFullScreen() {
        logger.debug("\(#function)")
    }
    
    public func willExitFullScreen() {
        logger.debug("\(#function)")
    }
    
    public func didExitFullScreen() {
        logger.debug("\(#function)")
    }

    public  func received(input: RawInput) {
        logger.debug("\(#function) \(input)")
    }
    
    public func processFrame() {
        logger.trace("\(#function)")
        //        renderer.waitForNextFrame()
        // var previousState
        
        // var currentState
        
        let currentTime = engine.currentTime
        var frameDuration = currentTime - previousTime
        logger.trace("FRAME DURATION: \(frameDuration)")
        
        if frameDuration > maxFrameDuration {
            logger.debug("EXCEEDED FRAME DURATION")
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
        logger.trace("\(#function)")
    }
    
    private func render() {
        logger.trace("\(#function)")
    }
}
