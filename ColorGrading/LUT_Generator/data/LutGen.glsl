#version 430
#ifdef GL_ES
#endif

uniform sampler2D texture;
uniform vec2 resolution;

out vec4 fragColor;

void main()
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;


	fragColor = vec4(uv.x, uv.x, uv.x, 1.0);
}

