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

public enum RawInputButtonCode : UInt8 {
    case INVALID = 0
    
    case MOUSE0  = 1
    case MOUSE1  = 2
    case MOUSE2  = 3
    case MOUSE3  = 4
    case MOUSE4  = 5
    case MOUSE5  = 6
    case MOUSE6  = 7
    case MOUSE7  = 8
    case MOUSE8  = 9
    case MOUSE9  = 10
    case MOUSE10 = 11
    case MOUSE11 = 12
    case MOUSE12 = 13
    case MOUSE13 = 14
    case MOUSE14 = 15
    case MOUSE15 = 16
    
    case UNKNOWN = 255
}
