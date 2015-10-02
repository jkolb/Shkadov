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

struct VertexIn {
    packed_float3 position;
    packed_float3 normal;
    packed_float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

struct TextureVertexOut {
    float4 position [[position]];
    float3 eyePosition;
    float3 normal;
    float2 texCoord;
};

struct LightInfo {
    float4 position; // Light position in eye coordinates
    float3 La; // Ambient light intensity
    float3 Ld; // Diffuse light intensity
    float3 Ls; // Specular light intensity
};

struct MaterialInfo {
    float3 Ka; // Ambient reflectivity
    float3 Kd; // Diffuse reflectivity
    float3 Ks; // Specular reflectivity
    float Shininess; // Specular shininess factor
};

vertex VertexOut passThroughVertex(uint vid [[vertex_id]], constant VertexIn* inVertex [[buffer(0)]], constant UniformIn& inUniform [[buffer(1)]]) {
    LightInfo light = {
        float4(10.0, 10.0, 10.0, 1.0),
        float3(1.0, 1.0, 1.0),
        float3(0.5, 0.5, 0.5),
        float3(0.5, 0.5, 0.5)
    };
    MaterialInfo material = {
        float3(0.5, 0.5, 0.5),
        float3(0.5, 0.5, 0.5),
        float3(0.5, 0.5, 0.5),
        0.5
    };
    float3 vertexPosition = float3(inVertex[vid].position);
    float3 vertexNormal = float3(inVertex[vid].normal);
    
    float3x3 normalMatrix = inUniform.normalMatrix;
    float3 tnorm = normalize(normalMatrix * vertexNormal);
    float4 eyeCoords = inUniform.modelViewMatrix * float4(vertexPosition, 1.0);
    float3 s = normalize((light.position - eyeCoords).xyz);
    float3 v = normalize(-eyeCoords.xyz);
    float3 r = reflect(-s, tnorm);
    float3 ambient = light.La * material.Ka;
    float sDotN = max(dot(s, tnorm), 0.0);
    float3 diffuse = light.Ld * material.Kd * sDotN;
    float3 spec = float3(0.0);
    if (sDotN > 0.0) {
        spec = light.Ls * material.Ks * pow(max(dot(r, v), 0.0), material.Shininess);
    }
    
    VertexOut outVertex;

    outVertex.position = inUniform.modelViewProjectionMatrix * float4(vertexPosition, 1.0);
    outVertex.color = inUniform.diffuseColor * float4((ambient + diffuse + spec), 1.0);
    
    return outVertex;
};

fragment half4 passThroughFragment(VertexOut inFrag [[stage_in]]) {
    return half4(inFrag.color);
};

vertex TextureVertexOut textureVertex(uint vid [[vertex_id]], constant VertexIn* inVertex [[buffer(0)]], constant UniformIn& inUniform [[buffer(1)]]) {
    float3 vertexPosition = float3(inVertex[vid].position);
    float3 vertexNormal = float3(inVertex[vid].normal);
    
    float3x3 normalMatrix = inUniform.normalMatrix;
    float4 eyeCoords = inUniform.modelViewMatrix * float4(vertexPosition, 1.0);
    
    TextureVertexOut outVertex;
    
    outVertex.position = inUniform.modelViewProjectionMatrix * float4(vertexPosition, 1.0);
    outVertex.eyePosition = eyeCoords.xyz;
    outVertex.normal = vertexNormal;
    outVertex.texCoord = float2(inVertex[vid].texCoord);
    
    return outVertex;
};

struct Light
{
    float3 direction;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
};

constant Light light = {
    .direction = { 0.13, 0.72, 0.68 },
    .ambientColor = { 0.05, 0.05, 0.05 },
    .diffuseColor = { 1, 1, 1 },
    .specularColor = { 0.2, 0.2, 0.2 }
};

constant float3 kSpecularColor= { 1, 1, 1 };
constant float kSpecularPower = 80;

fragment float4 textureFragment(TextureVertexOut inFrag [[stage_in]], texture2d<float> diffuseTexture [[texture(0)]], sampler samplr [[sampler(0)]]) {
    float3 diffuseColor = diffuseTexture.sample(samplr, inFrag.texCoord).rgb;
    
    float3 ambientTerm = light.ambientColor * diffuseColor;
    
    float3 normal = normalize(inFrag.normal);
    float diffuseIntensity = saturate(dot(normal, light.direction));
    float3 diffuseTerm = light.diffuseColor * diffuseColor * diffuseIntensity;
    
    float3 specularTerm(0);
    if (diffuseIntensity > 0)
    {
        float3 eyeDirection = normalize(inFrag.eyePosition);
        float3 halfway = normalize(light.direction + eyeDirection);
        float specularFactor = pow(saturate(dot(normal, halfway)), kSpecularPower);
        specularTerm = light.specularColor * kSpecularColor * specularFactor;
    }
    
    return float4(ambientTerm + diffuseTerm + specularTerm, 1);
};
