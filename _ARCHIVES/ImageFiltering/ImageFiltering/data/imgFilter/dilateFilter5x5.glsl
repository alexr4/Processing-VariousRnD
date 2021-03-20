
uniform sampler2D texture;
uniform vec2 resolution;
uniform float ratio;

out vec4 fragColor;


void main(){
	vec2 uv = gl_FragCoord.xy / resolution.xy; 
	vec2 uvinc = vec2(1.0) / resolution.xy;
	vec2 invuv = vec2(uv.x, 1.0 - uv.y);
	//vec4 tex = texture(texture, invuv);

	//Declare array and temp value
	float averageNeighbors;

	//3*3 neighbors
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-2.0, -2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0, -2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 0.0, -2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 1.0, -2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 2.0, -2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-2.0, -1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0, -1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 0.0, -1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 1.0, -1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 2.0, -1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-2.0,  0.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0,  0.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 0.0,  0.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 1.0,  0.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 2.0,  0.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-2.0,  1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0,  1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 0.0,  1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 1.0,  1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 2.0,  1.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-2.0,  2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2(-1.0,  2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 0.0,  2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 1.0,  2.0) * uvinc).r);
	averageNeighbors += step(ratio, texture(texture, invuv + vec2( 2.0,  2.0) * uvinc).r);
	averageNeighbors /= 25.0;


	float isWhite = step(ratio, averageNeighbors);

	
	vec4 color = vec4(vec3(isWhite), 1.0);

	fragColor =  color;
}