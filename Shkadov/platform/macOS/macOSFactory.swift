//
//  Factory.swift
//  Nostalgia
//
//  Created by Justin Kolb on 10/8/16.
//
//

import AppKit
import FieryCrucible
import Metal
import MetalKit

public class macOSFactory : DependencyFactory {
    fileprivate let windowSize = CGSize(width: 1280, height: 720)
    
    fileprivate func engine() -> Engine {
        return scoped(
            Engine(
                timeSource: timeSource(),
                logger: engineLogger()
            )
        )
    }
    
    fileprivate func timeSource() -> TimeSource {
        return scoped(
            MachOTimeSource()
        )
    }

    public func platform() -> Platform {
        return platform_macOS()
    }
    
    public func platform_macOS() -> macOSPlatform {
        return shared(
            macOSPlatform(
                application: application(),
                window: window(),
                viewController: viewController(),
                engine: engine(),
                logger: platformLogger()
            )
        )
    }

    fileprivate func applicationName() -> String {
        return scoped(
            ProcessInfo.processInfo.processName
        )
    }
    
    fileprivate func application() -> NSApplication {
        return scoped(
            NSApplication.shared(),
            configure: { instance in
                instance.setActivationPolicy(.regular)
                instance.mainMenu = self.mainMenu()
                instance.delegate = self.platform_macOS()
            }
        )
    }
    
    fileprivate func mainMenu() -> NSMenu {
        return scoped(
            factory: {
                let instance = NSMenu()
                
                let applicationMenuItem = NSMenuItem()
                instance.addItem(applicationMenuItem)
                
                let applicationMenu = NSMenu()
                applicationMenuItem.submenu = applicationMenu
                
                applicationMenu.addItem(withTitle: "Quit \(applicationName())", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
                
                let viewMenuItem = NSMenuItem()
                instance.addItem(viewMenuItem)
                
                let viewMenu = NSMenu(title: "View")
                viewMenuItem.submenu = viewMenu
                
                viewMenu.addItem(withTitle: "Toggle Full Screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
                
                return instance
            }
        )
    }
    
    fileprivate func engineLogger() -> Logger {
        return scoped(Logger(level: .debug))
    }
    
    fileprivate func platformLogger() -> Logger {
        return scoped(Logger(level: .debug))
    }
    
    fileprivate func rendererLogger() -> Logger {
        return scoped(Logger(level: .debug))
    }
    
    fileprivate func viewControllerLogger() -> Logger {
        return scoped(Logger(level: .debug))
    }
    
    fileprivate func inputLogger() -> Logger {
        return scoped(Logger(level: .debug))
    }
    
    fileprivate func sceneManagerLogger() -> Logger {
        return scoped(Logger(level: .debug))
    }

    fileprivate func window() -> NSWindow {
        return scoped(
            NSWindow(
                contentRect: CGRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            ),
            configure: { instance in
                instance.delegate = self.windowDelegate()
                instance.title = self.applicationName()
                instance.collectionBehavior = .fullScreenPrimary
                instance.contentMinSize = self.windowSize
                instance.contentViewController = self.viewController()
                instance.center()
            }
        )
    }
    
    fileprivate func windowDelegate() -> NSWindowDelegate {
        return platform_macOS()
    }
    
    fileprivate func viewController() -> macOSViewController {
        return scoped(
            macOSViewController(
                mouseCursorManager: mouseCursorManager(),
                renderView: metalView(),
                logger: viewControllerLogger()
            ),
            configure: { instance in
                instance.rawInputListener = self.engine()
            }
        )
    }
    
    fileprivate func mouseCursorManager() -> MouseCursorManager {
        return scoped(
            macOSMouseCursorManager(),
            configure: { instance in
                instance.delegate = self.viewController()
            }
        )
    }
    
    fileprivate func metalDevice() -> MTLDevice {
        return scoped(
            MTLCreateSystemDefaultDevice()!
        )
    }
    
    fileprivate func metalViewDelegate() -> MTKViewDelegate {
        return platform_macOS()
    }
    
    fileprivate func metalView() -> MTKView {
        return scoped(
            factory: {
                let instance = MTKView(frame: CGRect(x: 0.0, y: 0.0, width: windowSize.width, height: windowSize.height), device: metalDevice())
                instance.framebufferOnly = true
                instance.presentsWithTransaction = false
                instance.colorPixelFormat = .bgra8Unorm
                instance.depthStencilPixelFormat = .depth32Float
                instance.sampleCount = 1
                instance.clearColor = MTLClearColor(red: 178.0/255.0, green: 1.0, blue: 1.0, alpha: 1.0)
                instance.clearDepth = 1.0
                instance.clearStencil = 0
                instance.isPaused = true
                instance.autoResizeDrawable = true
                instance.drawableSize = windowSize
                return instance
            },
            configure: { instance in
                instance.delegate = self.metalViewDelegate()
            }
        )
    }
}
