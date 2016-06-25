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

import Foundation

public final class MacFileManager : FileManager {
    private let applicationName: String
    private let fileManager: NSFileManager
    private let filesystem: FileSystem
    private let memory: Memory
    
    public init(applicationName: String, fileManager: NSFileManager, filesystem: FileSystem, memory: Memory) {
        self.applicationName = applicationName
        self.fileManager = fileManager
        self.filesystem = filesystem
        self.memory = memory
        try! createRootDirectoryIfNeeded()
    }
    
    private func applicationSupportDirectory() -> NSURL {
        return try! fileManager.URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
    }
    
    private func rootDirectory() -> NSURL {
        return NSURL(string: applicationName, relativeToURL: applicationSupportDirectory())!
    }

    private func bundlePath(path: String) -> String {
        let bundle = NSBundle.mainBundle()
        let resourceURL = bundle.URLForResource(path, withExtension: "txt", subdirectory: "assets/geometry")!
        precondition(resourceURL.fileURL)
        return resourceURL.path!
    }
    
    private func fullPath(path: String) -> String {
        let fullPathURL = NSURL(string: path, relativeToURL: rootDirectory())!
        precondition(fullPathURL.fileURL)
        return fullPathURL.path!
    }
    
    public func createRootDirectoryIfNeeded() throws {
        try! fileManager.createDirectoryAtURL(rootDirectory(), withIntermediateDirectories: true, attributes: nil)
    }

    public var pageSize: Int {
        return Int(getpagesize())
    }
    
    public func openStringFileForReadingAtPath(path: String) throws -> StringFile {
        let path = filesystem.parsePath(bundlePath(path))
        let channel = try filesystem.openPath(path, options: [.Read])
        let buffer = memory.bufferWithSize(ByteSize(pageSize))
        let stream = FileOctetStream(channel: channel, buffer: buffer)
        return StringFile(octetStream: stream, lineTerminator: "\r\n")
    }
    
    public func texturePathForName(name: String) -> String {
        let bundle = NSBundle.mainBundle()
        let resourceURL = bundle.URLForResource(name, withExtension: "png", subdirectory: "assets/textures")!
        precondition(resourceURL.fileURL)
        return resourceURL.path!
    }
}
