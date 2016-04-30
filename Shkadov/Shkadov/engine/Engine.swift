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

public class Engine : PlatformDelegate, RendererDelegate {
    private let platform: Platform
    private let timeSource: TimeSource
    private let renderer: Renderer
    private let sceneManager: SceneManager
    private let logger: Logger
    
    private var totalDuration = Duration.zero
    private var previousTime = Time.zero
    private var accumulatedTime = Duration.zero
    private let tickDuration = Duration(seconds: 1.0 / 60.0)
    private let maxFrameDuration = Duration(seconds: 0.25)
    
    public init(platform: Platform, timeSource: TimeSource, renderer: Renderer, sceneManager: SceneManager, logger: Logger) {
        self.platform = platform
        self.timeSource = timeSource
        self.renderer = renderer
        self.sceneManager = sceneManager
        self.logger = logger
    }
    
    public func start() {
        logger.debug("\(#function)")
        platform.start()
    }
    
    private func main() {
        logger.debug("\(#function)")
        sceneManager.updateViewport(renderer.viewport)
        sceneManager.setUp()
        previousTime = timeSource.currentTime
        renderer.resume()
    }
    
    private func processFrame() {
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
            
            sceneManager.update()
        }
        
        //let alpha = accumulatedTime / tickDuration.nanoseconds
        
        // let state = currentState * alpha + previousState * (1.0 - alpha)
        
        // render(state)

        let renderables = sceneManager.render()
        renderer.renderRenderables(renderables)
    }
    
    public func platformDidStart(platform: Platform) {
        main()
    }

    public func renderer(renderer: Renderer, willChangeViewport viewport: Extent2D) {
        sceneManager.updateViewport(viewport)
    }
    
    public func renderer(renderer: Renderer, willRenderFrame frame: Int) {
    }
    
    public func renderer(renderer: Renderer, renderFrame frame: Int) {
        processFrame()
    }
    
    public func renderer(renderer: Renderer, didRenderFrame frame: Int) {
        
    }
}
