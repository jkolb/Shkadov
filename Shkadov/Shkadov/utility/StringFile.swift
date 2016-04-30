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

public final class StringFile : LineReader {
    private var octetStream: OctetStream
    private var unicodeScalars: [UnicodeScalar]
    private let lineTerminator: [UnicodeScalar]
    private var codec: UTF8
    private var foundLineTerminators: [UnicodeScalar]
    private var generator: OctetStreamGenerator
    
    public init(octetStream: OctetStream, lineTerminator: String) {
        precondition(!lineTerminator.isEmpty)
        self.octetStream = octetStream
        self.unicodeScalars = [UnicodeScalar]()
        self.lineTerminator = [UnicodeScalar](lineTerminator.unicodeScalars)
        self.codec = UTF8()
        self.foundLineTerminators = [UnicodeScalar]()
        self.generator = OctetStreamGenerator(stream: octetStream)
        
        self.foundLineTerminators.reserveCapacity(self.lineTerminator.count)
        self.unicodeScalars.reserveCapacity(1024)
    }
    
    public func readLine() throws -> String? {
        var eol = false
        
        while (!eol) {
            switch codec.decode(&generator) {
            case .Result(let scalar):
                if scalar == lineTerminator[foundLineTerminators.count] {
                    foundLineTerminators.append(scalar)
                }
                else if foundLineTerminators.count > 0 {
                    unicodeScalars.appendContentsOf(foundLineTerminators)
                    foundLineTerminators.removeAll(keepCapacity: true)
                    unicodeScalars.append(scalar)
                }
                else {
                    unicodeScalars.append(scalar)
                }
                
                if foundLineTerminators.count == lineTerminator.count {
                    foundLineTerminators.removeAll(keepCapacity: true)
                    eol = true
                }
                
            case .EmptyInput:
                if let error = generator.error {
                    throw error
                }
                else if unicodeScalars.count > 0 {
                    eol = true
                }
                else {
                    return nil
                }
                
            case .Error:
                throw StringParsingError.UnableToDecodeCharacter
            }
        }
        
        let line = String(unicodeScalars.map({Character($0)}))
        unicodeScalars.removeAll(keepCapacity: true)

        return line
    }
}
