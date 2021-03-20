#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform float exponent = .5;
uniform float strength = 1.0;
uniform float radius = 4.0;
uniform vec2 resolution;

in vec4 vertTexCoord;

out vec4 fragColor;


void main() {
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	uv.y = 1.0 - uv.y;
	vec4 center = texture2D(texture, uv);
	vec4 color = vec4(0.0);
	float total = 0.0;
	for (float x = -radius; x <= radius; x += 1.0) {
		for (float y = -radius; y <= radius; y += 1.0) {
			vec4 samplePix = texture2D(texture, uv + vec2(x, y) / resolution);
			float weight = 1.0 - abs(dot(samplePix.rgb - center.rgb, vec3(0.25)));
			weight = pow(weight, exponent);
			color += samplePix * weight;
			total += weight;
		}
	}

	fragColor = color / total;

}