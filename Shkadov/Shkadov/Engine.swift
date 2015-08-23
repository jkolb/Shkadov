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

import simd

public final class Engine {
    private let platform: Platform
    private let input: Input
    private var renderer: Renderer
    private let queue: DispatchQueue
    private let timer: Timer
    var camera: Camera
    var cubes: [Object3D] = [
        Object3D(position: float3(0.0, 0.0, 0.0)),
        Object3D(position: float3(1.5, 0.0, 0.0)),
        Object3D(position: float3(-1.5, 0.0, 0.0)),
        Object3D(position: float3(0.0, 1.5, 0.0)),
        Object3D(position: float3(0.0, -1.5, 0.0)),
        Object3D(position: float3(0.0, 0.0, 1.5)),
        Object3D(position: float3(0.0, 0.0, -1.5)),
    ]

    public init(platform: Platform, renderer: Renderer) {
        self.platform = platform
        self.input = Input()
        self.renderer = renderer
        self.queue = DispatchQueue.queueWithName("net.franticapparatus.engine.update", attribute: .Serial)
        self.timer = Timer(platform: platform, name: "net.franticapparatus.engine.timer", tickDuration: Duration(seconds: 1.0 / 60.0), callbackQueue: self.queue)
        self.camera = Camera()
    }
    
    public func beginSimulation() {
        renderer.configure()
        
        timer.updateHandler { [weak self] (tickCount, tickDuration) in
            guard let strongSelf = self else { return }
            
            strongSelf.updateWithTickCount(tickCount, tickDuration: tickDuration)
        }

        timer.startWithHandler {
        }
    }
    
    public func updateWithTickCount(tickCount: Int, tickDuration: Duration) {
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
    
    public func updateViewport(viewport: Rectangle2D) {
        camera.updateWithAspectRatio(viewport.aspectRatio, fovy: Angle(degrees: 65.0))
        renderer.updateViewport(viewport)
    }
}
