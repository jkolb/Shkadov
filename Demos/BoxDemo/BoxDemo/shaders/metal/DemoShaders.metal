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

#include <metal_texture>
#include <simd/simd.h>

using namespace metal;

struct VertexP
{
    packed_float3 position;
};

struct VertexPNT1
{
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texcoord;
};

struct ProjectedVertex
{
    float4 position [[position]];
    float2 texcoord;
};

struct LitUniform
{
    float4x4 modelViewProjectionMatrix;
    float3x3 normalMatrix;
};

struct ColorUniform
{
    float4x4 modelViewProjectionMatrix;
    uchar4 color;
};

vertex ProjectedVertex litTexturedVertex(uint vid [[ vertex_id ]], const device VertexPNT1* vertexIn [[ buffer(0) ]], constant LitUniform& uniform [[ buffer(1) ]])
{
    ProjectedVertex outVertex;
    outVertex.position = uniform.modelViewProjectionMatrix * float4(vertexIn[vid].position, 1.0);
    outVertex.texcoord = vertexIn[vid].texcoord;
    return outVertex;
}

fragment float4 litTexturedFragment(ProjectedVertex vert [[ stage_in ]], texture2d<float> diffuseTexture [[ texture(0) ]], sampler samplr [[ sampler(0) ]])
{
    return diffuseTexture.sample(samplr, vert.texcoord);
}

vertex float4 lineVertex(uint vid [[ vertex_id ]], const device VertexP* vertexIn [[ buffer(0) ]], constant ColorUniform& uniform [[ buffer(1) ]])
{
    return uniform.modelViewProjectionMatrix * float4(vertexIn[vid].position, 1.0);
}

fragment float4 lineFragment(constant ColorUniform& uniform [[buffer(0)]])
{
    return float4(uniform.color);
}
