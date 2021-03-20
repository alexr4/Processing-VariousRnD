#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define offset 43758.5453123
uniform sampler2D texture;
uniform vec2 resolution;
uniform float randomRatio = 1.0;
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

	float texRed = texture(texture, uv).r;
	vec3 color = vec3(1.0);

	/** 
	* This version take all neighbors
	*/
	/*
	vec3 neighbors = vec3(0);
	neighbors  = texture(texture, uv + vec2(-1.0, -1.0) * texel).rgb;
	neighbors += texture(texture, uv + vec2(0.0, -1.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(1.0, -1.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(-1.0, 0.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(1.0, .0)    * texel).rgb;
	neighbors += texture(texture, uv + vec2(-1.0, 1.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(.0, 1.0)    * texel).rgb;
	neighbors += texture(texture, uv + vec2(1.0, 1.0)   * texel).rgb;
	float ratio   	= neighbors.r / 8.0;

	vec3 DLAUV	 	= vec3(uv, randomRatio);
	//float randRatio = (texRed != 1) ? random(DLAUV) : 0.0; -> quite interesting value... look like a burning effect
	float randRatio = random(DLAUV);
	float isVisible = step(0.575, randRatio);
	float isWhite 	= step(1.0/8.0, ratio);
	*/
	/**
	* This one pick a random neighbors
	*/
	
	vec2 randTexel = random2D(uv + time) * 2.0 - 1.0;
	vec3 neighbor  = texture(texture, uv + randTexel * texel).rgb;

	vec3 DLAUV	 	= vec3(uv, randomRatio);
	float randRatio = random(DLAUV);
	float isVisible = step(0.5, randRatio);
	float isWhite 	= step(0.7, neighbor.r);
	
	/**
	* This version limit the number of coinnected neighbors
	*/
	/*
	vec3 neighbors = vec3(0);
	neighbors  = texture(texture, uv + vec2(-1.0, -1.0) * texel).rgb;
	neighbors += texture(texture, uv + vec2(0.0, -1.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(1.0, -1.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(-1.0, 0.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(1.0, .0)    * texel).rgb;
	neighbors += texture(texture, uv + vec2(-1.0, 1.0)  * texel).rgb;
	neighbors += texture(texture, uv + vec2(.0, 1.0)    * texel).rgb;
	neighbors += texture(texture, uv + vec2(1.0, 1.0)   * texel).rgb;
	float ratio   	= neighbors.r / 8.0;

	float odist = length(vec2(0.5) - uv);
	vec3 DLAUV	 	= vec3(uv, randomRatio);// * odist);
	//float randRatio = (texRed != 1) ? random(DLAUV) : 0.0; //-> quite interesting value... look like a burning effect
	float randRatio = random(DLAUV);
	float isVisible = step(0.5, randRatio);
	//float isVisible = step(dist * 0.5 + 0.5, randRatio);
	//float isVisible = step(pow(dist, 1.0 + randRatio), randRatio);
	float rad = 0.4;
	float dist = odist * rad + (1 - rad);
	float neighborsratio = 1.0/8.0;
	float nbNeighbors = 1.0 + 3.0 * (1.0 - dist) * isVisible;
	float isWhite 	= step(neighborsratio, ratio) * (1.0 - step(neighborsratio * nbNeighbors, ratio));
*/
	float colorStepper = step(0.9, texRed);
	color = vec3(isWhite * isVisible) * (1.0 - colorStepper) + vec3(texRed) * colorStepper;
	
	fragColor = vec4(color, 1.0);
}