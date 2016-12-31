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
import PlatformAppKit
import PlatformDarwin
import PlatformFoundation
import FieryCrucible
import Logger

public final class macOSBootstrap : DepencencyFactory, Bootstrap {
	public func makePlatform() -> Platform {
		return scoped(
			AppKit(loggerFactory: LoggerFactory)
		)
	}
    
    public func makeLogger() -> Logger {
        return loggerFactory().makeLogger()
    }

    private func loggerFactory() -> LoggerFactory {
        return scoped(
            LoggerFactory(
                applicationNameProvider: applicationNameProvider(),
                threadIDProvider: threadIDProvider(),
                formattedTimestampProvider: formattedTimestampProvider(),
            	pathSeparator: "/"
            )
        )
    }
    
    private func threadIDProvider() -> ThreadIDProvider {
        return scoped(DarwinThreadIDProvider())
    }
    
    private func formattedTimestampProvider() -> FormattedTimestampProvider {
        return scoped(FoundationFormattedTimestampProvider())
    }
    
    private func applicationNameProvider() -> ApplicationNameProvider {
        return scoped(FoundationApplicationNameProvider())
    }
}
