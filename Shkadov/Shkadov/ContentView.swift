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

import AppKit

public class ContentView: NSView {
    public override var acceptsFirstResponder: Bool {
        return true
    }
    
    public override func mouseDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func mouseUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func mouseDragged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func rightMouseDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func rightMouseUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func rightMouseDragged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }

    public override func otherMouseDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func otherMouseUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func otherMouseDragged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func mouseMoved(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func scrollWheel(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func keyDown(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func keyUp(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
    
    public override func flagsChanged(theEvent: NSEvent) {
        NSLog("%@", __FUNCTION__)
    }
}
