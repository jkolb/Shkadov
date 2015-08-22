//
//  Shader.fsh
//  iOSOpenGLTemplate
//
//  Created by Justin Kolb on 8/15/15.
//  Copyright © 2015 Justin Kolb. All rights reserved.
//
#version 150

in vec4 vertColor;

out vec4 fragColor;

void main()
{
    fragColor = vertColor;
}
