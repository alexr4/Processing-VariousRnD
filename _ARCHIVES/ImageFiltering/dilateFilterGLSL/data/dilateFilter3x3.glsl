

uniform sampler2D texture;
uniform vec2 resolution;
uniform float ratio = 0.5;

out vec4 fragColor;


void main(){
	vec2 uv = gl_FragCoord.xy / resolution.xy; 
	vec2 uvinc = vec2(1.0) / resolution.xy;
	vec2 invuv = vec2(uv.x, 1.0 - uv.y);
	vec4 tex = texture(texture, invuv);

	float averageNeighbors;
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0, -1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(0.0, -1.0)  * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(1.0, -1.0)  * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0, 0.0)  * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(.0, .0)     * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(1.0, .0)    * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0, 1.0)  * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(.0, 1.0)    * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(1.0, 1.0)   * uvinc).r);
	averageNeighbors /= 9.0;

	float isWhite = step(ratio, averageNeighbors);

	
	vec4 color = vec4(vec3(isWhite), 1.0);
	

	fragColor =  color;
}