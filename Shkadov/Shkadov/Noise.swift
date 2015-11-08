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

public final class Noise {
    private static var i = 0
    private static var j = 0
    private static var k = 0
    private static var A = [0, 0, 0]
    private static var u: Float = 0.0
    private static var v: Float = 0.0
    private static var w: Float = 0.0
    
    public static func fbm(xyz: float3, octaves: Int, lacunarity: Float, gain: Float) -> Float {
        var amplitude: Float = 1.0
        var frequency = float3(1.0)
        var sum: Float = 0.0
    
        for _ in 0..<octaves {
            sum += amplitude * noise(xyz * frequency)
            amplitude *= gain
            frequency *= lacunarity
        }
    
        return sum
    }

    public static func noise(xyz: float3) -> Float {
        return Noise.noise(xyz.x, xyz.y, xyz.z)
    }
    
    public static func noise(x: Float, _ y: Float, _ z: Float) -> Float {
        let s = (x + y + z) / 3
        i = Int(floor(x + s))
        j = Int(floor(y + s))
        k = Int(floor(z + s))
        let s2 = Float(i + j + k) / 6.0
        u = x - Float(i) + s2
        v = y - Float(j) + s2
        w = z - Float(k) + s2
        A[0] = 0
        A[1] = 0
        A[2] = 0
        let hi = u >= w ? u >= v ? 0 : 1 : v >= w ? 1 : 2
        let lo = u < w ? u < v ? 0 : 1 : v < w ? 1 : 2
        return K(hi) + K(3 - hi - lo) + K(lo) + K(0)
    }
    
    public static func K(a: Int) -> Float {
        let s = Float(A[0] + A[1] + A[2]) / 6.0
        let x = u - Float(A[0]) + s
        let y = v - Float(A[1]) + s
        let z = w - Float(A[2]) + s
        var t = 0.6 - x * x - y * y - z * z
        let h = shuffle(i + A[0], j + A[1], k + A[2])
        A[a]++
        if (t < 0) {
            return 0
        }
        let b5 = h >> 5 & 1
        let b4 = h >> 4 & 1
        let b3 = h >> 3 & 1
        let b2 = h >> 2 & 1
        let b = h & 3
        var p = b == 1 ? x : b == 2 ? y : z
        var q = b == 1 ? y : b == 2 ? z : x
        var r = b == 1 ? z : b == 2 ? x : y
        p = (b5 == b3 ? -p : p)
        q = (b5 == b4 ? -q : q)
        r = (b5 != (b4 ^ b3) ? -r : r)
        t *= t
        return 8.0 * t * t * (p + (b == 0 ? q + r : b2 == 0 ? q : r))
    }
    
    private static func shuffle(i: Int, _ j: Int, _ k: Int) -> Int {
        return b(i, j, k, 0) + b(j, k, i, 1) + b(k, i, j, 2) + b(i, j, k, 3) + b(j, k, i, 4) + b(k, i, j, 5) + b(i, j, k, 6) + b(j, k, i, 7)
    }
    
    private static func b(i: Int, _ j: Int, _ k: Int, _ B: Int) -> Int {
        return T[b(i, B) << 2 | b(j, B) << 1 | b(k, B)]
    }
    
    private static func b(N: Int, _ B: Int) -> Int {
        return N >> B & 1
    }
    private static let T = [0x15, 0x38, 0x32, 0x2c, 0x0d, 0x13, 0x07, 0x2a]
}
