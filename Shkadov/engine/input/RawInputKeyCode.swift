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

public enum RawInputKeyCode : UInt8 {
    case invalid = 0
    
    case a = 1
    case b = 2
    case c = 3
    case d = 4
    case e = 5
    case f = 6
    case g = 7
    case h = 8
    case i = 9
    case j = 10
    case k = 11
    case l = 12
    case m = 13
    case n = 14
    case o = 15
    case p = 16
    case q = 17
    case r = 18
    case s = 19
    case t = 20
    case u = 21
    case v = 22
    case w = 23
    case x = 24
    case y = 25
    case z = 26
    // 27 - 49
    case zero  = 50
    case one   = 51
    case two   = 52
    case three = 53
    case four  = 54
    case five  = 55
    case six   = 56
    case seven = 57
    case eight = 58
    case nine  = 59
    // 60 - 69
    case grave = 70
    case minus = 71
    case equals = 72
    case lbracket = 73
    case rbracket = 74
    case backslash = 75
    case semicolon = 76
    case apostrophe = 77
    case comma = 78
    case period = 79
    case slash = 80
    case tab = 83
    case space = 84
    // 85 - 99
    case capslock  = 100 // Toggle only
    case `return`    = 101
    case lshift    = 102
    case rshift    = 103
    case lcontrol  = 104
    case rcontrol  = 105
    case lalt      = 106
    case ralt      = 107
    case lmeta     = 108
    case rmeta     = 109
    case insert    = 110 // fn
    case delete    = 111
    case home      = 112
    case end       = 113
    case pageup    = 114
    case pagedown  = 115
    case escape    = 116
    case backspace = 117 // DELETE
    case sysrq     = 118 // Windows
    case scroll    = 119 // Windows
    case pause     = 120 // Windows
    // 121 - 159
    case up    = 160
    case down  = 161
    case left  = 162
    case right = 163
    // 164 - 169
    case numlock         = 170 // CLEAR
    case numpad_ZERO     = 171
    case numpad_ONE      = 172
    case numpad_TWO      = 173
    case numpad_THREE    = 174
    case numpad_FOUR     = 175
    case numpad_FIVE     = 176
    case numpad_SIX      = 177
    case numpad_SEVEN    = 178
    case numpad_EIGHT    = 179
    case numpad_NINE     = 180
    case numpad_EQUALS   = 181
    case numpad_DIVIDE   = 182
    case numpad_MULTIPLY = 183
    case numpad_SUBTRACT = 184
    case numpad_ADD      = 185
    case numpad_DECIMAL  = 186
    case numpad_ENTER    = 187
    // 188 - 189
    case f1  = 190
    case f2  = 191
    case f3  = 192
    case f4  = 193
    case f5  = 194
    case f6  = 195
    case f7  = 196
    case f8  = 197
    case f9  = 198
    case f10 = 199
    case f11 = 200
    case f12 = 201
    case f13 = 202
    case f14 = 203
    case f15 = 204
    case f16 = 205
    case f17 = 206
    case f18 = 207
    case f19 = 208
    case f20 = 209
    // 210 - 254
    case unknown = 255
}
