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

public protocol Renderer : class {
    weak var delegate: RendererDelegate! { get set }
    
    var viewport: Extent2D { get set }
    
    func pause()
    func resume()
    
    func renderRenderables(renderables: [Renderable])
    
    func generateMipmapsForTextures(textures: [Texture])
}

public protocol RendererDelegate : class {
    func renderer(renderer: Renderer, willChangeViewport viewport: Extent2D)
    func renderer(renderer: Renderer, willRenderFrame frame: Int)
    func renderer(renderer: Renderer, renderFrame frame: Int)
    func renderer(renderer: Renderer, didRenderFrame frame: Int)
}
