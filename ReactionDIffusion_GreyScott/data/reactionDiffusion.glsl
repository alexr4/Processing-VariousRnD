//grayScott shader algorithm based on http://www.karlsims.com/rd.html

#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

//GrayScott variable
uniform float dT = 1.0;
uniform float dA = 1.0;
uniform float dB = 0.15;
uniform float feedRate = 0.0545;
uniform float killRate = 0.062;

//Texture information binded from p5
uniform sampler2D texture;
uniform vec2 texOffset;

in vec4 vertColor;
in vec4 vertTexCoord;

out vec4 fragColor;

vec4 laplace()
{
	/* Look-up table
	-1-1  0-1 1-1
	-1 0  0 0 1 0
	-1 1  0 1 1 1
	 */

    vec4 uv0 = texture2D(texture, vertTexCoord.st + vec2(-texOffset.s, -texOffset.t));
    vec4 uv1 = texture2D(texture, vertTexCoord.st + vec2(         0.0, -texOffset.t));
    vec4 uv2 = texture2D(texture, vertTexCoord.st + vec2(+texOffset.s, -texOffset.t));
    vec4 uv3 = texture2D(texture, vertTexCoord.st + vec2(-texOffset.s,          0.0));
    vec4 uv4 = texture2D(texture, vertTexCoord.st + vec2(         0.0,          0.0));
    vec4 uv5 = texture2D(texture, vertTexCoord.st + vec2(+texOffset.s,          0.0));
    vec4 uv6 = texture2D(texture, vertTexCoord.st + vec2(-texOffset.s, +texOffset.t));
    vec4 uv7 = texture2D(texture, vertTexCoord.st + vec2(         0.0, +texOffset.t));
    vec4 uv8 = texture2D(texture, vertTexCoord.st + vec2(+texOffset.s, +texOffset.t));

	return ( 0.05 * uv0 + 0.2 * uv1 + 0.05 * uv2 +
		     0.2 * uv3 - 1.0 * uv4 + 0.2 * uv5 +
		     0.05 * uv6 + 0.2 * uv7 + 0.05 * uv8);
}


void main() {
	vec2 data = texture2D(texture, vertTexCoord.st).rg;

	float chemicalA = data.r;
	float chemicalB = data.g;
	float AB2 = chemicalA * (chemicalB * chemicalB);

	//compute delta base on http://www.karlsims.com/rd.html
	float A_ = (dA * laplace().r) - AB2 + feedRate * (1.0 - chemicalA);
	float B_ = (dB * laplace().g) + AB2 - (feedRate + killRate) * chemicalB;

	vec2 reactiondiffusion = clamp(data + dT * vec2(A_, B_), 0.0, 1.0);



	fragColor = vec4(reactiondiffusion.rg, 0.0, 1.0);
}
