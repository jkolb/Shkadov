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

public protocol LineReader {
    func readLine() throws -> String?
}

extension LineReader {
    public func readSplitOnSeparator(separator: Character) throws -> [String] {
        guard let line = try readLine() else {
            return []
        }
        
        return line.characters.split(separator).map({String($0)})
    }
    
    public func readInts() throws -> [Int] {
        return try readSplitOnSeparator(" ").map({ (text) -> Int in
            guard let value = Int(text) else {
                throw StringParsingError.UnableToParseInt(text)
            }
            return value
        })
    }
    
    public func readFloats() throws -> [Float] {
        return try readSplitOnSeparator(" ").map({ (text) -> Float in
            guard let value = Float(text) else {
                throw StringParsingError.UnableToParseFloat(text)
            }
            return value
        })
    }
    
    public func readEmptyLine() throws {
        guard let line = try readLine() else {
            return
        }
        
        if !line.isEmpty {
            throw StringParsingError.UnableToParseEmpty(line)
        }
    }
}
