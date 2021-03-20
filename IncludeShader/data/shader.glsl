#version 150
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

in vec4 vertTexCoord;
out vec4 fragColor;

#include random.glsl

void main(){
	vec2 uv = vertTexCoord.xy;

	fragColor = vec4(uv, random(vertTexCoord.xy), 1.0);
}


