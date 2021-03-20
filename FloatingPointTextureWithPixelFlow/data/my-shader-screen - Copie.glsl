#version 130

uniform sampler2D uTexture;
varying out vec4 fragColor;

void main(){
	vec2 uv = gl_FragCoord.xy / vec2(512.0);
	vec4 rgba = texture(uTexture, uv);
	float steper = step(1.45, rgba.g);

	fragColor = rgba + vec4(steper, 0, 0, 1);
}