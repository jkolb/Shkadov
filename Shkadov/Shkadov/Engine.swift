//
//  Engine.swift
//  OSXOpenGLTemplate
//
//  Created by Justin Kolb on 8/20/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//

import simd

public final class Engine {
    private let renderer: Renderer
    private let queue: DispatchQueue
    private let timer: Timer
    public var viewport = Viewport(x: 0, y: 0, width: 800, height: 600)
    var camera: Camera!
    var cubes: [Object3D] = [
        Object3D(position: float3(0.0, 0.0, 0.0)),
        Object3D(position: float3(1.5, 0.0, 0.0)),
        Object3D(position: float3(-1.5, 0.0, 0.0)),
        Object3D(position: float3(0.0, 1.5, 0.0)),
        Object3D(position: float3(0.0, -1.5, 0.0)),
        Object3D(position: float3(0.0, 0.0, 1.5)),
        Object3D(position: float3(0.0, 0.0, -1.5)),
    ]

    public init(renderer: Renderer) {
        self.renderer = renderer
        self.queue = DispatchQueue.queueWithName("net.franticapparatus.engine.update", attribute: .Serial)
        self.timer = Timer(name: "net.franticapparatus.engine.timer", nanosecondsPerTick: UInt64(1.0 / 60.0 * 1_000_000_000.0), callbackQueue: self.queue)
        self.camera = Camera(viewport: viewport, fovy: Angle(degrees: 65.0))
    }
    
    public func beginSimulation() {
        renderer.configure()
        
        timer.updateHandler { [weak self] (tickCount, nanosecondsPerTick) in
            guard let strongSelf = self else { return }
            
            strongSelf.updateWithTickCount(tickCount, nanosecondsPerTick: nanosecondsPerTick)
        }

        timer.startWithHandler {
        }
    }
    
    public func updateWithTickCount(tickCount: Int, nanosecondsPerTick: UInt64) {
        // Generate the data for a frame
        let updateAmount: Float = 0.01
        let viewMatrix = camera.viewMatrix
        var renderObjects = [RenderObject]()
        
        for cube in cubes {
            cube.modelViewMatrix = viewMatrix * cube.modelMatrix
            cube.modelViewProjectionMatrix = camera.projectionMatrix * cube.modelViewMatrix
            
            cube.lookRightByAmount(Angle(radians: updateAmount))
            cube.lookUpByAmount(Angle(radians: updateAmount))
            
            renderObjects.append(RenderObject(modelViewProjectionMatrix: cube.modelViewProjectionMatrix, normalMatrix: cube.normalMatrix))
        }

        // Pass data to render queue for processing
        renderer.renderState(RenderState(objects: renderObjects))
    }
}
