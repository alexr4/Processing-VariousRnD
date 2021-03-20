#version 430
#ifdef GL_ES
#endif

uniform sampler2D texture;
uniform sampler2D lut;
uniform vec2 resolution;

out vec4 fragColor;

vec4 curves(vec4 inColor, sampler2D texCurve)
{
    return vec4(texture2D(texCurve, vec2(inColor.r, 0.5)).r, texture2D(texCurve, vec2(inColor.g, 0.5)).g, texture2D(texCurve, vec2(inColor.b, 0.5)).b, inColor.a);
}

void main()
{
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	vec4 color = texture2D(texture, vec2(uv.x, 1.0 - uv.y));
	float steper = 1.0 - step(uv.x, 0.5);
	vec4 newColor = curves(color, lut) ;
	

   	fragColor = newColor * steper + color * (1.0 - steper);
}

