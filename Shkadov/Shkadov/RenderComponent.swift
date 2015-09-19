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

import simd

public struct RenderComponent : Component {
    public static let kind = Kind(dataType: RenderComponent.self)
    public var modelViewProjectionMatrix: float4x4
    public var normalMatrix: float4x4
    public var diffuseColor: float4
    public var texture: Handle
    public var vertexArray: Handle
    
    public init(diffuseColor: float4 = Color.white.vector) {
        self.modelViewProjectionMatrix = float4x4(1.0)
        self.normalMatrix = float4x4(1.0)
        self.diffuseColor = diffuseColor
        self.texture = Handle.invalid
        self.vertexArray = Handle.invalid
    }
}
