//
//  Shader.vsh
//  iOSOpenGLTemplate
//
//  Created by Justin Kolb on 8/15/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//
#version 150

uniform mat4 modelViewProjectionMatrix;
uniform mat4 normalMatrix;

in vec4  position;
in vec3 normal;

out vec4 vertColor;

void main()
{
    vec3 eyeNormal = normalize(mat3(normalMatrix) * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
    
    vertColor = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
}
