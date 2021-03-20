#version 150
#ifdef GL_ES
precision highp float;
precision highp vec4;
precision highp vec3;
precision highp vec2;
precision highp int;
precision highp sampler2D;
#endif


uniform mat4 transform;
uniform mat4 projection;
uniform mat4 rotationMatrix = mat4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
uniform vec4 translationMatrix = vec4(0, 0, 0, 0);
uniform vec4 intrinsicMatrix = vec4(1, 1, 1, 1);
uniform sampler2D dataTexture;
uniform int dataMax = 8000;
uniform float size = 500.0;

in vec4 vertex;
in vec4 color;
in vec4 texCoord;
out vec4 vertColor;

int decodeRGBAMod(vec4 rgba, float edge){
	float divider = (float(edge) / 256.0);
	int index = int(round(rgba.b * divider));
	return int(rgba.r * 255) + index * 255;
}

vec4 backProject(vec2 pixel, float depth){
	float x = (pixel.x - intrinsicMatrix.x) * depth / intrinsicMatrix.z;
	float y = (pixel.y - intrinsicMatrix.y) * depth / intrinsicMatrix.w;
	return vec4(x, y, depth, 1.0);
}

vec4 computeNewPosition(vec4 pos, mat4 R, vec4 T){
	return (R * pos) + T;
}

void main(){
	vec2 uv = texCoord.xy;
	vec4 tex = texture(dataTexture, uv);
	float depth =float(decodeRGBAMod(tex, float(dataMax))) / dataMax;
	vec4 backproj = backProject(vertex.xy, float(depth));
	backproj.xyz *= size;
	vec4 pos = computeNewPosition(backproj, rotationMatrix, translationMatrix);
	gl_Position = transform * pos;
	vertColor = color;
}
