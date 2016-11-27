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

public protocol LogFormatter {
    func format(_ record: LogRecord) -> String
}

public protocol LogHandler {
    func publish(_ record: LogRecord)
}

open class LogRecord {
    open let timestamp: Date
    open let level: LogLevel
    open let processName: String
    open let threadID: UInt64
    open let fileName: String
    open let lineNumber: Int
    open let message: String
    
    public init(timestamp: Date, level: LogLevel, processName: String, threadID: UInt64, fileName: String, lineNumber: Int, message: String) {
        self.timestamp = timestamp
        self.level = level
        self.processName = processName
        self.threadID = threadID
        self.fileName = fileName
        self.lineNumber = lineNumber
        self.message = message
    }
}

public enum LogLevel : UInt8, Comparable {
    case none
    case error
    case warn
    case info
    case debug
    case trace
    
    public var formatted: String {
        switch self {
        case .error:
            fallthrough
        case .debug:
            fallthrough
        case .trace:
            return "\(self)".uppercased()
        default:
            return "\(self)".uppercased() + " "
        }
    }
}

open class LogStringFormatter : LogFormatter {
    fileprivate let dateFormatter: DateFormatter
    
    public init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    public init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    open func format(_ record: LogRecord) -> String {
        return "\(dateFormatter.string(from: record.timestamp)) \(record.processName)[\(record.threadID)] \(record.level.formatted) \(record.fileName):\(record.lineNumber) \(record.message)"
    }
}

open class LogConsoleHandler : LogHandler {
    fileprivate let formatter: LogFormatter
    
    public init(formatter: LogFormatter = LogStringFormatter()) {
        self.formatter = formatter
    }
    
    open func publish(_ record: LogRecord) {
        print(formatter.format(record))
    }
}

open class LogCompositeHandler : LogHandler {
    fileprivate let handlers: [LogHandler]
    
    public init(handlers: [LogHandler]) {
        self.handlers = handlers
    }
    
    open func publish(_ record: LogRecord) {
        for handler in handlers {
            handler.publish(record)
        }
    }
}

open class Logger {
    open let level: LogLevel
    fileprivate let handler: LogHandler
    fileprivate let processName = ProcessInfo.processInfo.processName
    
    public init(level: LogLevel, handler: LogHandler = LogConsoleHandler()) {
        self.level = level
        self.handler = handler
    }
    
    fileprivate var threadID: UInt64 {
        var ID: __uint64_t = 0
        pthread_threadid_np(nil, &ID)
        return ID
    }
    
    fileprivate func log(_ message: @autoclosure () -> String, level: LogLevel, fileName: String = #file, lineNumber: Int = #line) {
        if level > self.level { return }
        
        let record = LogRecord(
            timestamp: Date(),
            level: level,
            processName: processName,
            threadID: self.threadID,
            fileName: NSString(string: fileName).lastPathComponent,
            lineNumber: lineNumber,
            message: message()
        )
        
        handler.publish(record)
    }
    
    open func error(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .error, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func error(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .error, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func warn(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .warn, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func warn(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .warn, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func info(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .info, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func info(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .info, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func debug(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .debug, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func debug(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .debug, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func trace(_ message: @autoclosure () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .trace, fileName: fileName, lineNumber: lineNumber)
    }
    
    open func trace(_ fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .trace, fileName: fileName, lineNumber: lineNumber)
    }
}

public func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
