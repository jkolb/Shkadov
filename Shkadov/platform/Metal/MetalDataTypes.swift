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

import Metal
import Swiftish

public struct MetalDataTypes {
    public static func map(_ blendFactor: BlendFactor) -> MTLBlendFactor {
        switch blendFactor {
        case .zero:
            return .zero
        case .one:
            return .one
        case .sourceColor:
            return .sourceColor
        case .oneMinusSourceColor:
            return .oneMinusSourceColor
        case .sourceAlpha:
            return .sourceAlpha
        case .oneMinusSourceAlpha:
            return .oneMinusSourceAlpha
        case .destinationColor:
            return .destinationColor
        case .oneMinusDestinationColor:
            return .oneMinusDestinationColor
        case .destinationAlpha:
            return .destinationAlpha
        case .oneMinusDestinationAlpha:
            return .oneMinusDestinationAlpha
        case .sourceAlphaSaturated:
            return .sourceAlphaSaturated
        case .blendColor:
            return .blendColor
        case .oneMinusBlendColor:
            return .oneMinusBlendColor
        case .blendAlpha:
            return .blendAlpha
        case .oneMinusBlendAlpha:
            return .oneMinusBlendAlpha
        }
    }
    
    public static func map(_ blendOp: BlendOperation) -> MTLBlendOperation {
        switch blendOp {
        case .add:
            return .add
        case .subtract:
            return .subtract
        case .reverseSubtract:
            return .reverseSubtract
        case .min:
            return .min
        case .max:
            return .max
        }
    }

    public static func map(_ compareFunction: CompareFunction) -> MTLCompareFunction {
        switch compareFunction {
        case .never:
            return .never
        case .less:
            return .less
        case .equal:
            return .equal
        case .lessEqual:
            return .lessEqual
        case .greater:
            return .greater
        case .notEqual:
            return .notEqual
        case .greaterEqual:
            return .greaterEqual
        case .always:
            return .always
        }
    }
    
    public static func map(_ cullMode: CullMode) -> MTLCullMode {
        switch cullMode {
        case .none:
            return .none
        case .front:
            return .front
        case .back:
            return .back
        }
    }
    
    public static func map(_ depthClipMode: DepthClipMode) -> MTLDepthClipMode {
        switch depthClipMode {
        case .clip:
            return .clip
        case .clamp:
            return .clamp
        }
    }
    
    public static func map(_ indexType: IndexType) -> MTLIndexType {
        switch indexType {
        case .uint16:
            return .uint16
        case .uint32:
            return .uint32
        }
    }
    
    public static func map(_ origin: Vector3<Int>) -> MTLOrigin {
        return MTLOrigin(x: origin.x, y: origin.y, z: origin.z)
    }

    public static func map(_ pixelFormat: PixelFormat) -> MTLPixelFormat {
        switch pixelFormat {
        case .rgba8Unorm:
            return .rgba8Unorm
        case .bgra8Unorm:
            return .bgra8Unorm
        default:
            fatalError("Unsupported pixelFormat: \(pixelFormat)")
        }
    }
    
    public static func map(_ primitiveType: PrimitiveType) -> MTLPrimitiveType {
        switch primitiveType {
        case .point:
            return .point
        case .line:
            return .line
        case .lineStrip:
            return .lineStrip
        case .triangle:
            return .triangle
        case .triangleStrip:
            return .triangleStrip
        }
    }
    
    public static func map(_ region: Region3<Int>) -> MTLRegion {
        return MTLRegion(origin: map(region.origin), size: map(region.size))
    }
    
    public static func map(_ options: ResourceOptions) -> MTLResourceOptions {
        var metalOptions = MTLResourceOptions()
        
        if options.contains(.storageModeShared) {
            metalOptions.formUnion(.storageModeShared)
        }
        
        if options.contains(.storageModeManaged) {
            metalOptions.formUnion(.storageModeManaged)
        }
        
        if options.contains(.storageModePrivate) {
            metalOptions.formUnion(.storageModePrivate)
        }
        
        if options.contains(.cpuCacheModeWriteCombined) {
            metalOptions.formUnion(.cpuCacheModeWriteCombined)
        }
        
        return metalOptions
    }

    public static func map(_ scissorRect: ScissorRect) -> MTLScissorRect {
        return MTLScissorRect(
            x: scissorRect.x,
            y: scissorRect.y,
            width: scissorRect.width,
            height: scissorRect.height
        )
    }
    
    public static func map(_ size: Vector3<Int>) -> MTLSize {
        return MTLSize(width: size.width, height: size.height, depth: size.depth)
    }

    public static func map(_ fillMode: TriangleFillMode) -> MTLTriangleFillMode {
        switch fillMode {
        case .fill:
            return .fill
        case .lines:
            return .lines
        }
    }
    
    public static func map(_ viewport: Viewport) -> MTLViewport {
        return MTLViewport(
            originX: viewport.originX,
            originY: viewport.originY,
            width: viewport.width,
            height: viewport.height,
            znear: viewport.znear,
            zfar: viewport.zfar
        )
    }
    
    public static func map(_ winding: Winding) -> MTLWinding {
        switch winding {
        case .clockwise:
            return .clockwise
        case .counterClockwise:
            return .counterClockwise
        }
    }
}
