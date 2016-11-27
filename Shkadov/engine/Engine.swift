//
//  Engine.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

import Swiftish

public final class Engine : RawInputListener {
    fileprivate let timeSource: TimeSource
    fileprivate let logger: Logger
    
    fileprivate var totalDuration = Duration.zero
    fileprivate var previousTime = Time.zero
    fileprivate var accumulatedTime = Duration.zero
    fileprivate let tickDuration = Duration(seconds: 1.0 / 60.0)
    fileprivate let maxFrameDuration = Duration(seconds: 0.25)
    fileprivate let camera = Camera()
    
    public init(timeSource: TimeSource, logger: Logger) {
        self.timeSource = timeSource
        self.logger = logger
    }
    
    public func start() {
        logger.debug("\(#function)")
        camera.projection.fovy = Angle<Float>(degrees: 30.0)
        camera.projection.zNear = 0.1
        camera.projection.zFar = 1000.0
        camera.worldTransform.t = Vector3<Float>(0.0, 0.0, 0.0)
        camera.worldTransform.r = rotation(pitch: Angle<Float>(), yaw: Angle<Float>(), roll: Angle<Float>())
        previousTime = timeSource.currentTime
    }
    
    public func receivedRawInput(_ rawInput: RawInput) {
        logger.trace("\(rawInput)")
    }

    public func renderFrame() {
//        renderer.waitForNextFrame()
        // var previousState
        
        // var currentState
        
        let currentTime = timeSource.currentTime
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

    public func update(elapsed: Duration) {
        
    }
    
    public func render() {
//        renderer.renderFrame(camera: camera)
    }
}
