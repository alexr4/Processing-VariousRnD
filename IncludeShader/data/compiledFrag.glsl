#version 150
#define PI 3.1415926535897932384626433832795
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

in vec4 vertTexCoord;
out vec4 fragColor;

#define RANDOM_SEED 43758.5453123

float random(float x){
    return fract(sin(x) * RANDOM_SEED);
}

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))* RANDOM_SEED);
}

void main(){
	vec2 uv = vertTexCoord.xy;

	fragColor = vec4(uv, random(vertTexCoord.xy), 1.0);
}


