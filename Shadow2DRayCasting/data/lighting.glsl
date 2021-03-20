//blend sources : http://wiki.polycount.com/wiki/Blending_functions

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D shadowMap;
uniform vec2 light;
uniform vec2 resolution;
uniform float intensity;

in vec4 vertTexCoord;
out vec4 fragColor;


void main(){
	vec2 uv = vertTexCoord.xy;
	vec2 invuv = vec2(uv.x, 1.0 - uv.y);
	vec4 tex = texture(texture, uv);
	vec4 shadow = texture(shadowMap, uv);
	float dist = length(light - invuv);
	float hyp = sqrt(2.0);
	float pdist = 1.0 - smoothstep(0, hyp * 0.015, dist);
	dist = 1.0 - (pow(dist, 0.5) + dist * 0.5) + pdist;
	dist *= intensity;
	dist = clamp(dist, 0.0, 1.0); 
	
	vec4 background = clamp(tex + shadow, 0.0, 1.0);;
	float sdist = mix(0.5, 1.0, dist);

	fragColor = background * sdist;
}