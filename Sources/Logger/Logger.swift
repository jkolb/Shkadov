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

public final class Logger {
    public var level: LogLevel
    private let name: String
    private let threadIDProvider: ThreadIDProvider
    private let formattedTimestampProvider: FormattedTimestampProvider
    private let pathSeparator: String
    private let publisher: LogPublisher
    
    public init(name: String, threadIDProvider: ThreadIDProvider, formattedTimestampProvider: FormattedTimestampProvider, pathSeparator: String, publisher: LogPublisher = ConsoleLogPublisher()) {
        self.level = .debug
        self.name = name
        self.threadIDProvider = threadIDProvider
        self.formattedTimestampProvider = formattedTimestampProvider
        self.pathSeparator = pathSeparator
        self.publisher = publisher
    }
    
    private func log(_ message: @autoclosure () -> String, level: LogLevel, fileName: String = #file, lineNumber: Int = #line) {
        if level > self.level { return }
        
        let record = LogRecord(
            formattedTimestamp: formattedTimestampProvider.currentFormattedTimestamp,
            level: level,
            name: name,
            threadID: threadIDProvider.currentThreadID(),
            fileName: fileName.characters.split(separator: pathSeparator.characters.first!).map(String.init).last ?? "Unknown",
            lineNumber: lineNumber,
            message: message()
        )
        
        publisher.publish(record)
    }
    
    public func error(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .error, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func error(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .error, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func warn(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .warn, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func warn(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .warn, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func info(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .info, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func info(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .info, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func debug(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .debug, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func debug(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .debug, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func trace(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .trace, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func trace(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .trace, fileName: fileName, lineNumber: lineNumber)
    }
}
