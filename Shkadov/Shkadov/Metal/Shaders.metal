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

#include <metal_stdlib>

using namespace metal;

struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texCoord;
};

struct UniformIn {
    float4x4 modelViewProjectionMatrix;
    float4x4 normalMatrix;
    float4 diffuseColor;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut passThroughVertex(uint vid [[vertex_id]], constant VertexIn* inVertex [[buffer(0)]], constant UniformIn& inUniform [[buffer(1)]]) {
    float3 normalMatrixCol0 = inUniform.normalMatrix[0].xyz;
    float3 normalMatrixCol1 = inUniform.normalMatrix[1].xyz;
    float3 normalMatrixCol2 = inUniform.normalMatrix[2].xyz;
    float3x3 normalMatrix = float3x3(normalMatrixCol0, normalMatrixCol1, normalMatrixCol2);
    float3 normal = float3(inVertex[vid].normal);
    float3 eyeNormal = normalize(normalMatrix * normal);
    float3 lightPosition = float3(0.0, 0.0, 1.0);
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    float4 position = float4(float3(inVertex[vid].position), 1.0);
    
    VertexOut outVertex;

    outVertex.position = inUniform.modelViewProjectionMatrix * position;
    outVertex.color = inUniform.diffuseColor * nDotVP;
    
    return outVertex;
};

fragment half4 passThroughFragment(VertexOut inFrag [[stage_in]]) {
    return half4(inFrag.color);
};
