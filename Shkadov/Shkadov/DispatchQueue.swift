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

import Dispatch

public class DispatchQueue : CustomStringConvertible {
    
    public enum Attribute : RawRepresentable {
        case Serial
        case Concurrent
        
        public init?(rawValue: dispatch_queue_attr_t!) {
            if rawValue == nil { // DISPATCH_QUEUE_SERIAL is nil
                self = .Serial
            }
            else if rawValue.isEqual(DISPATCH_QUEUE_CONCURRENT) {
                self = .Concurrent
            }
            else {
                self = .Serial
                return nil
            }
        }

        public var rawValue: dispatch_queue_attr_t! {
            switch self {
            case .Serial:
                return DISPATCH_QUEUE_SERIAL
            case .Concurrent:
                return DISPATCH_QUEUE_CONCURRENT
            }
        }
    }
    
    public enum QOSClass : RawRepresentable {
        case UserInteractive
        case UserInitiated
        case Default
        case Utility
        case Background
        case Unspecified
        
        public init?(rawValue: qos_class_t) {
            if rawValue == QOS_CLASS_USER_INTERACTIVE {
                self = .UserInteractive
            }
            else if rawValue == QOS_CLASS_USER_INITIATED {
                self = .UserInitiated
            }
            else if rawValue == QOS_CLASS_DEFAULT {
                self = .Default
            }
            else if rawValue == QOS_CLASS_UTILITY {
                self = .Utility
            }
            else if rawValue == QOS_CLASS_BACKGROUND {
                self = .Background
            }
            else if rawValue == QOS_CLASS_UNSPECIFIED {
                self = .Unspecified
            }
            else {
                self = .Unspecified
                return nil
            }
        }

        public var rawValue: qos_class_t {
            switch self {
            case .UserInteractive:
                return QOS_CLASS_USER_INTERACTIVE
            case .UserInitiated:
                return QOS_CLASS_USER_INITIATED
            case .Default:
                return QOS_CLASS_DEFAULT
            case .Utility:
                return QOS_CLASS_UTILITY
            case .Background:
                return QOS_CLASS_BACKGROUND
            case .Unspecified:
                return QOS_CLASS_UNSPECIFIED
            }
        }
    }
    
    public let GCDQueue: dispatch_queue_t
    
    public init(GCDQueue: dispatch_queue_t) {
        self.GCDQueue = GCDQueue
    }
    
    public class func main() -> DispatchQueue {
        return DispatchQueue(GCDQueue: dispatch_get_main_queue())
    }
    
    public class func queueWithName(name: String, attribute: Attribute, qosClass: QOSClass, relativePriority: Int32) -> DispatchQueue {
        return queueWithName(name, attribute: attribute, qosClass: qosClass.rawValue, relativePriority: relativePriority)
    }
    
    public class func queueWithName(name: String, attribute: Attribute, qosClass: qos_class_t, relativePriority: Int32) -> DispatchQueue {
        return queueWithName(name, attributes: dispatch_queue_attr_make_with_qos_class(attribute.rawValue, qosClass, relativePriority))
    }
    
    public class func queueWithName(name: String, attribute: Attribute) -> DispatchQueue {
        return queueWithName(name, attributes: attribute.rawValue)
    }
    
    public class func queueWithName(name: String, attributes: dispatch_queue_attr_t!) -> DispatchQueue {
        return DispatchQueue(GCDQueue: dispatch_queue_create(name, attributes))
    }
    
    public class func globalQueueWithQOS(qos: QOSClass) -> DispatchQueue {
        return globalQueueWithQOS(qos.rawValue)
    }
    
    public class func globalQueueWithQOS(qos: qos_class_t) -> DispatchQueue {
        return DispatchQueue(GCDQueue: dispatch_get_global_queue(qos, 0))
    }
    
    public func dispatch(block: () -> ()) {
        dispatch_async(GCDQueue, block)
    }
    
    public func dispatchAndWait(block: () -> ()) {
        dispatch_sync(GCDQueue, block)
    }
    
    public func dispatchSerialized(block: () -> ()) {
        dispatch_barrier_async(GCDQueue, block)
    }
    
    public func dispatchSerializedAndWait(block: () -> ()) {
        dispatch_barrier_sync(GCDQueue, block)
    }
    
    public var description: String {
        return String.fromCString(dispatch_queue_get_label(GCDQueue)) ?? "nil"
    }
}
