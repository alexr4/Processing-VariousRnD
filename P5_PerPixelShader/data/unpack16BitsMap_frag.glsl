//shadow map
#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

in vec4 vertTexCoord;

out vec4 fragColor;

  // Unpack the 16bit depth float from the first two 8bit channels of the rgba vector
float unpackDepth(vec4 color) { 
	return color.r + color.g / 255;
}


void main(void) {
	float depth = unpackDepth(texture2D(texture, vertTexCoord.st));
	fragColor = vec4(depth, depth, depth, 1.0);
}