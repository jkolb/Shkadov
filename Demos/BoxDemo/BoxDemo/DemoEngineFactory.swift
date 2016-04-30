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

import AppKit
import Metal
import MetalKit
import Shkadov

public final class DemoEngineFactory : DependencyFactory, EngineFactory {
    private let windowSize = CGSize(width: 1280, height: 720)
    
    public func engine() -> Engine {
        return shared(
            Engine(
                platform: platform(),
                timeSource: timeSource(),
                renderer: renderer(),
                sceneManager: sceneManager(),
                logger: engineLogger()
            )
        )
    }
    
    private func sceneManager() -> DemoSceneManager {
        return scoped(
            DemoSceneManager(
                mouseCursorManager: mouseCursorManager(),
                shaderLibrary: shaderLibrary(),
                renderStateBuilder: renderStateBuilder(),
                gpuMemory: gpuMemory(),
                renderer: renderer(),
                boxGeometryBuilder: boxGeometryBuilder(),
                logger: sceneManagerLogger()
            )
        )
    }
    
    private func boxGeometryBuilder() -> BoxGeometryBuilder {
        return scoped(
            BoxGeometryBuilder(
                gpuMemory: gpuMemory()
            )
        )
    }
    
    private func platform() -> MacPlatform {
        return scoped(
            MacPlatform(
                application: application(),
                window: window(),
                viewController:  viewController(),
                logger: platformLogger()
            ),
            configure: { instance in
                instance.delegate = self.engine()
            }
        )
    }
    
    private func timeSource() -> TimeSource {
        return scoped(
            MacTimeSource()
        )
    }
    
    private func renderer() -> MetalRenderer {
        return scoped(
            MetalRenderer(
                metalDevice: metalDevice(),
                metalView:  metalView(),
                logger: rendererLogger()
            ),
            configure: { instance in
                instance.delegate = self.engine()
            }
        )
    }
    
    private func metalDevice() -> MTLDevice {
        return scoped(
            MTLCreateSystemDefaultDevice()!
        )
    }
    
    private func metalView() -> MTKView {
        return scoped(
            factory: {
                let instance = MTKView(
                    frame: CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
                    device: metalDevice()
                )
                instance.framebufferOnly = true
                instance.presentsWithTransaction = false
                instance.colorPixelFormat = .BGRA8Unorm
                instance.depthStencilPixelFormat = .Depth32Float
                instance.sampleCount = 1
                instance.clearColor = MTLClearColor(red: 178.0/255.0, green: 1.0, blue: 1.0, alpha: 1.0)
                instance.clearDepth = 1.0
                instance.clearStencil = 0
                instance.paused = true
                instance.autoResizeDrawable = true
                instance.drawableSize = windowSize
                return instance
            },
            configure: { instance in
                instance.delegate = self.renderer()
            }
        )
    }
    
    private func renderStateBuilder() -> RenderStateBuilder {
        return scoped(
            MetalRenderStateBuilder(
                metalDevice: metalDevice(),
                metalView: metalView()
            )
        )
    }
    
    private func shaderLibrary() -> ShaderLibrary {
        return scoped(
            MetalShaderLibrary(device: metalDevice())
        )
    }

    private func gpuMemory() -> GPUMemory {
        return scoped(
            MetalGPUMemory(device: metalDevice(), perFrameCount: 3)
        )
    }
    
    private func fileManager() -> FileManager {
        return scoped(
            MacFileManager(
                applicationName: applicationName(),
                fileManager: NSFileManager.defaultManager(),
                filesystem: filesystem(),
                memory: memory()
            )
        )
    }
    
    private func imageTextureLoader() -> ImageTextureLoader {
        return scoped(
            MacImageTextureLoader(
                gpuMemory: gpuMemory()
            )
        )
    }
    
    private func engineLogger() -> Logger {
        return scoped(Logger(level: .Debug))
    }
    
    private func platformLogger() -> Logger {
        return scoped(Logger(level: .Debug))
    }
    
    private func rendererLogger() -> Logger {
        return scoped(Logger(level: .Debug))
    }
    
    private func viewControllerLogger() -> Logger {
        return scoped(Logger(level: .Debug))
    }

    private func inputLogger() -> Logger {
        return scoped(Logger(level: .Debug))
    }
    
    private func sceneManagerLogger() -> Logger {
        return scoped(Logger(level: .Debug))
    }
    
    private func mouseCursorManager() -> MouseCursorManager {
        return scoped(
            MacMouseCursorManager(),
            configure: { instance in
                instance.delegate = self.viewController()
            }
        )
    }
    
    private func viewController() -> MacViewController {
        return scoped(
            MacViewController(
                mouseCursorManager: mouseCursorManager(),
                renderView: renderer().view,
                logger: viewControllerLogger()
            ),
            configure: { instance in
                instance.rawInputListener = self.sceneManager()
            }
        )
    }

    private func applicationName() -> String {
        return scoped(
            NSProcessInfo.processInfo().processName
        )
    }
    
    private func application() -> NSApplication {
        return scoped(
            NSApplication.sharedApplication(),
            configure: { instance in
                instance.setActivationPolicy(.Regular)
                instance.mainMenu = self.mainMenu()
                instance.delegate = self.platform()
            }
        )
    }
    
    private func mainMenu() -> NSMenu {
        return scoped(
            factory: {
                let instance = NSMenu()

                let applicationMenuItem = NSMenuItem()
                instance.addItem(applicationMenuItem)
                
                let applicationMenu = NSMenu()
                applicationMenuItem.submenu = applicationMenu
                
                applicationMenu.addItemWithTitle("Quit \(applicationName())", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
                
                let viewMenuItem = NSMenuItem()
                instance.addItem(viewMenuItem)
                
                let viewMenu = NSMenu(title: "View")
                viewMenuItem.submenu = viewMenu
                
                viewMenu.addItemWithTitle("Toggle Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
                
                return instance
            }
        )
    }
    
    private func window() -> NSWindow {
        return scoped(
            NSWindow(
                contentRect: CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
                styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask,
                backing: .Buffered,
                defer: false
            ),
            configure: { instance in
                instance.delegate = self.platform()
                instance.title = self.applicationName()
                instance.collectionBehavior = .FullScreenPrimary
                instance.contentMinSize = self.windowSize
                instance.contentViewController = self.viewController()
                instance.center()
            }
        )
    }
    
    private func memory() -> Memory {
        return shared(
            POSIXMemory()
        )
    }
    
    private func filesystem() -> FileSystem {
        return shared(
            POSIXFileSystem()
        )
    }
}
