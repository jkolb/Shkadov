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

#if os(macOS)
import Darwin
#elseif os(Linux)
import Glibc
#endif

import Platform

public class POSIXThreadIDProvider : ThreadIDProvider {
    private var mutex = pthread_mutex_t()
    private var threadIDs: [pthread_t]

    public init() {
        pthread_mutex_init(&mutex, nil)
        self.threadIDs = []
    }

    deinit {
        pthread_mutex_destroy(&mutex)
    }

    public func currentThreadID() -> UInt64 {
    	let current = pthread_self()
        
        pthread_mutex_lock(&mutex)
        let threadIDs = self.threadIDs
        pthread_mutex_unlock(&mutex)

        for (index, threadID) in threadIDs.enumerated() {
            if pthread_equal(current, threadID) != 0 {
                return UInt64(index)
            }
        }

        pthread_mutex_lock(&mutex)
        let index = self.threadIDs.count
        self.threadIDs.append(current)
        pthread_mutex_unlock(&mutex)

        return UInt64(index)
    }
}
