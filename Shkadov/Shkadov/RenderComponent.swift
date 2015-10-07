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

public struct RenderComponent : Component {
    public static let kind = Kind(dataType: RenderComponent.self)
    public let uniformBuffer: Handle
    public let uniformOffset: Int
    public let diffuseColor: Color
    public let modelViewMatrix: Matrix4x4
    public let normalMatrix: Matrix3x3
    public let projectionMatrix: Matrix4x4
    public let modelViewProjectionMatrix: Matrix4x4
    
    public init(
        uniformBuffer: Handle,
        uniformOffset: Int,
        diffuseColor: Color,
        modelViewMatrix: Matrix4x4 = Matrix4x4(1.0),
        normalMatrix: Matrix3x3 = Matrix3x3(1.0),
        projectionMatrix: Matrix4x4 = Matrix4x4(1.0),
        modelViewProjectionMatrix: Matrix4x4 = Matrix4x4(1.0)
    ) {
        self.uniformBuffer = uniformBuffer
        self.uniformOffset = uniformOffset
        self.diffuseColor = diffuseColor
        self.modelViewMatrix = modelViewMatrix
        self.normalMatrix = normalMatrix
        self.projectionMatrix = projectionMatrix
        self.modelViewProjectionMatrix = modelViewProjectionMatrix
    }
}
