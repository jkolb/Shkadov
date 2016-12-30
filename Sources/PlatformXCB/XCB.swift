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

import Platform

public final class XCB : Platform, XCBApplicationDelegate {
    public weak var listener: PlatformListener?
    private let connection: XCBConnection
    private let application: XCBApplication
    private let nativeDisplaySystem: XCBDisplaySystem

    public init(displayName: String? = nil) {
        self.connection = try! XCBConnection(displayName: displayName)
        self.application = XCBApplication(connection: connection)
        self.nativeDisplaySystem = XCBDisplaySystem(connection: connection)
    }
    
    public var displaySystem: DisplaySystem {
        return nativeDisplaySystem
    }

    public func startup() {
    	application.delegate = self
    	application.run()
    }
    
    private func didStartup() {
        listener?.didStartup()
    }
    
    public func applicationDidFinishLaunching(_ application: XCBApplication) {
        didStartup()
    }
}
