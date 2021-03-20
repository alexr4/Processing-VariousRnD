#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define offset 43758.5453123
uniform sampler2D texture;
uniform vec2 resolution;
uniform float randomRatio = 1.0;
uniform float randomDist = 1.0;
uniform float time;

in vec4 vertTexCoord;
out vec4 fragColor;

//RANDOM
float random(vec2 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xy, vec2(12.9898, 78.233))) * offset);
}

float random(vec3 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xyz, vec3(12.9898, 78.233, 12.9898))) * offset);
}

vec2 random2D(vec2 uv){
	uv = vec2(dot(uv, vec2(127.1, 311.7)), dot(uv, vec2(269.5, 183.3)));
	return fract(sin(uv) * offset);
}

void main(){
	vec2 uv = vertTexCoord.xy;
	vec2 texel = vec2(1.0) / resolution;
	float cell = texture(texture, uv).r;

	vec2 timeinc = vec2(1.0, floor(time * 60.0));
	float randomFeed = random(uv + floor(uv * 10.0 + timeinc));
	float stepFeed = step(randomRatio, randomFeed);

	float neighborsCell = 0.0;
	float neighborsParticle = 0.0;

	//Get all neighbors
	
	neighborsCell += texture(texture, uv + vec2(-1.0, -1.0) * texel).r;
	neighborsCell += texture(texture, uv + vec2(0.0, -1.0)  * texel).r;
	neighborsCell += texture(texture, uv + vec2(1.0, -1.0)  * texel).r;
	neighborsCell += texture(texture, uv + vec2(-1.0, 0.0)  * texel).r;
	neighborsCell += texture(texture, uv + vec2(1.0, .0)    * texel).r;
	neighborsCell += texture(texture, uv + vec2(-1.0, 1.0)  * texel).r;
	neighborsCell += texture(texture, uv + vec2(.0, 1.0)    * texel).r;
	neighborsCell += texture(texture, uv + vec2(1.0, 1.0)   * texel).r;
	
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(-1.0, -1.0) * texel));
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(0.0, -1.0)  * texel));
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(1.0, -1.0)  * texel));
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(-1.0, 0.0)  * texel));
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(1.0, .0)    * texel));
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(-1.0, 1.0)  * texel));
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(.0, 1.0)    * texel));
	neighborsParticle += step(randomRatio, random(floor(uv * 1.0 + timeinc) + uv + vec2(1.0, 1.0)   * texel));
	
	//get only an randomNeighbors
	vec2 randTexel 		= random2D(uv * time) * 2.0 - 1.0;
	neighborsParticle 	= step(randomRatio, random(uv + randTexel * texel));

	float isVisible 	= step(randomDist, random(uv));

	float isNeighborACell = step(1.0, neighborsCell) - (step(2.0, neighborsCell));
	float fixedCell = clamp(cell + neighborsParticle * isNeighborACell * isVisible, 0.0, 1.0);

	vec3 debug = vec3(fixedCell, neighborsParticle, neighborsParticle * isNeighborACell);
	vec3 color = vec3(fixedCell);

	fragColor = vec4(color, 1.0);
} 