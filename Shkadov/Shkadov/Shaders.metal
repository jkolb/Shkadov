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
#include <simd/simd.h>
#include "ShaderUniform.h"

using namespace metal;

struct LightInfo {
    float3 position; // Light position in eye coordinates
    float3 intensity; // Light intensity
};

struct MaterialInfo {
    float3 Ka; // Ambient reflectivity
    float3 Kd; // Diffuse reflectivity
    float3 Ks; // Specular reflectivity
    float Shininess; // Specular shininess factor
};

struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float3 eyeCoords;
    float3 tnorm;
};

struct TextureVertexOut {
    float4 position [[position]];
    float3 eyePosition;
    float3 normal;
    float2 texCoord;
};

float3 calculateLight(float3 eyeCoords, float3 tnorm, LightInfo light, MaterialInfo material);

float3 calculateLight(float3 eyeCoords, float3 tnorm, LightInfo light, MaterialInfo material) {
    float3 s = normalize((light.position - eyeCoords));
    float3 v = normalize(-eyeCoords);
    float3 r = reflect(-s, tnorm);
    float3 ambient = material.Ka;
    float sDotN = max(dot(s, tnorm), 0.0);
    float3 diffuse = material.Kd * sDotN;
    float3 spec = material.Ks * pow(max(dot(r, v), 0.0), material.Shininess);
    
    return light.intensity * (ambient + diffuse + spec);
}

vertex VertexOut passThroughVertex(uint vid [[vertex_id]], constant VertexIn* inVertex [[buffer(0)]], constant UniformIn& inUniform [[buffer(1)]]) {
    float4 vertexPosition = float4(float3(inVertex[vid].position), 1.0);
    float3 vertexNormal = float3(inVertex[vid].normal);
    
    VertexOut outVertex;
    
    outVertex.position = inUniform.modelViewProjectionMatrix * vertexPosition;
    outVertex.color = inUniform.diffuseColor;
    outVertex.eyeCoords = (inUniform.modelViewMatrix * vertexPosition).xyz;
    outVertex.tnorm = normalize(inUniform.normalMatrix * vertexNormal);
    
    return outVertex;
};

fragment half4 passThroughFragment(VertexOut inFrag [[stage_in]]) {
    LightInfo light = {
        float3(0.0, 10.0, 0.0),
        float3(1.0, 1.0, 1.0)
    };
    MaterialInfo material = {
        float3(0.05, 0.05, 0.05),
        float3(1.0, 1.0, 1.0),
        float3(0.2, 0.2, 0.2),
        80
    };
    float3 lighting = calculateLight(inFrag.eyeCoords, inFrag.tnorm, light, material);
    
    return half4(inFrag.color * float4(lighting, 1.0));
};

vertex TextureVertexOut textureVertex(uint vid [[vertex_id]], constant VertexIn* inVertex [[buffer(0)]], constant UniformIn& inUniform [[buffer(1)]]) {
    float4 vertexPosition = float4(float3(inVertex[vid].position), 1.0);
    float3 vertexNormal = float3(inVertex[vid].normal);
    
    TextureVertexOut outVertex;
    
    outVertex.position = inUniform.modelViewProjectionMatrix * vertexPosition;
    outVertex.eyePosition = (inUniform.modelViewMatrix * vertexPosition).xyz;
    outVertex.normal = normalize(inUniform.normalMatrix * vertexNormal);
    outVertex.texCoord = float2(inVertex[vid].texCoord);
    
    return outVertex;
};

fragment float4 textureFragment(TextureVertexOut inFrag [[stage_in]], texture2d<float> diffuseTexture [[texture(0)]], sampler samplr [[sampler(0)]]) {
    LightInfo light = {
        float3(0.0, 10.0, 0.0),
        float3(1.0, 1.0, 1.0)
    };
    MaterialInfo material = {
        float3(0.05, 0.05, 0.05),
        float3(1.0, 1.0, 1.0),
        float3(0.2, 0.2, 0.2),
        80
    };

    float3 diffuseColor = diffuseTexture.sample(samplr, inFrag.texCoord).rgb;
    float3 lighting = calculateLight(inFrag.eyePosition, inFrag.normal, light, material);
    
    return float4(diffuseColor * lighting, 1.0);
};
