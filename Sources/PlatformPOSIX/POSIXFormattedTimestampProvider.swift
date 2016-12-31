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
import Lilliput

public final class POSIXFormattedTimestampProvider : FormattedTimestampProvider {
    private var mutex = pthread_mutex_t()
	private let buffer: UnsafeBuffer

	public init() {
        pthread_mutex_init(&mutex, nil)
		self.buffer = POSIXMemory().bufferWithSize(24)
	}

	deinit {
        pthread_mutex_destroy(&mutex)
	}

	public var currentFormattedTimestamp: String {
		var timeVal = timeval()
		gettimeofday(&timeVal, nil)
		let localTime = localtime(&timeVal.tv_sec)
		let milliseconds = timeVal.tv_usec / 1000

        pthread_mutex_lock(&mutex)
        let pointer = buffer.bytes.assumingMemoryBound(to: CChar.self)
        strftime(pointer, buffer.count, "%Y-%m-%d %H:%M:%S.000", localTime)
        withVaList([milliseconds]) {
	        vsnprintf(pointer.advanced(by: 20), 4, "%03ld", $0)
	        return
        }
        let timestamp = UnsafeOrderedBuffer<LittleEndian>(buffer: buffer).getUTF8(length: buffer.count - 1)
        pthread_mutex_unlock(&mutex)
		return timestamp
	}
}
