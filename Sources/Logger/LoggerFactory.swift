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

public final class LoggerFactory {
    private let applicationNameProvider: ApplicationNameProvider
    private let threadIDProvider: ThreadIDProvider
    private let formattedTimestampProvider: FormattedTimestampProvider
    private let pathSeparator: String

    public init(applicationNameProvider: ApplicationNameProvider, threadIDProvider: ThreadIDProvider, formattedTimestampProvider: FormattedTimestampProvider, pathSeparator: String) {
        self.applicationNameProvider = applicationNameProvider
        self.threadIDProvider = threadIDProvider
        self.formattedTimestampProvider = formattedTimestampProvider
        self.pathSeparator = pathSeparator
    }
    
    public func makeLogger() -> Logger {
        return Logger(
            name: applicationNameProvider.applicationName,
            threadIDProvider: threadIDProvider,
            formattedTimestampProvider: formattedTimestampProvider,
            pathSeparator: pathSeparator
        )
    }
}
