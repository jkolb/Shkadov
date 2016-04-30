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
    func format(record: LogRecord) -> String
}

public protocol LogHandler {
    func publish(record: LogRecord)
}

public class LogRecord {
    public let timestamp: NSDate
    public let level: LogLevel
    public let processName: String
    public let threadID: UInt64
    public let fileName: String
    public let lineNumber: Int
    public let message: String
    
    public init(timestamp: NSDate, level: LogLevel, processName: String, threadID: UInt64, fileName: String, lineNumber: Int, message: String) {
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
    case None
    case Error
    case Warn
    case Info
    case Debug
    case Trace
    
    public var formatted: String {
        switch self {
        case .Error:
            fallthrough
        case .Debug:
            fallthrough
        case .Trace:
            return "\(self)".uppercaseString
        default:
            return "\(self)".uppercaseString + " "
        }
    }
}

public class LogStringFormatter : LogFormatter {
    private let dateFormatter: NSDateFormatter
    
    public init() {
        self.dateFormatter = NSDateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    public init(dateFormatter: NSDateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    public func format(record: LogRecord) -> String {
        return "\(dateFormatter.stringFromDate(record.timestamp)) \(record.processName)[\(record.threadID)] \(record.level.formatted) \(record.fileName):\(record.lineNumber) \(record.message)"
    }
}

public class LogConsoleHandler : LogHandler {
    private let formatter: LogFormatter
    
    public init(formatter: LogFormatter = LogStringFormatter()) {
        self.formatter = formatter
    }
    
    public func publish(record: LogRecord) {
        print(formatter.format(record))
    }
}

public class LogCompositeHandler : LogHandler {
    private let handlers: [LogHandler]
    
    public init(handlers: [LogHandler]) {
        self.handlers = handlers
    }
    
    public func publish(record: LogRecord) {
        for handler in handlers {
            handler.publish(record)
        }
    }
}

public class Logger {
    public let level: LogLevel
    private let handler: LogHandler
    private let processName = NSProcessInfo.processInfo().processName
    
    public init(level: LogLevel, handler: LogHandler = LogConsoleHandler()) {
        self.level = level
        self.handler = handler
    }
    
    private var threadID: UInt64 {
        var ID: __uint64_t = 0
        pthread_threadid_np(nil, &ID)
        return ID
    }
    
    private func log(@autoclosure message: () -> String, level: LogLevel, fileName: String = #file, lineNumber: Int = #line) {
        if level > self.level { return }
        
        let record = LogRecord(
            timestamp: NSDate(),
            level: level,
            processName: processName,
            threadID: self.threadID,
            fileName: NSString(string: fileName).lastPathComponent,
            lineNumber: lineNumber,
            message: message()
        )
        
        handler.publish(record)
    }
    
    public func error(@autoclosure message: () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .Error, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func error(fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .Error, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func warn(@autoclosure message: () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .Warn, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func warn(fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .Warn, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func info(@autoclosure message: () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .Info, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func info(fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .Info, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func debug(@autoclosure message: () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .Debug, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func debug(fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .Debug, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func trace(@autoclosure message: () -> String, fileName: String = #file, lineNumber: Int = #line) {
        log(message, level: .Trace, fileName: fileName, lineNumber: lineNumber)
    }
    
    public func trace(fileName: String = #file, lineNumber: Int = #line, message: () -> String) {
        log(message(), level: .Trace, fileName: fileName, lineNumber: lineNumber)
    }
}

public func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
    return lhs.rawValue < rhs.rawValue
}
