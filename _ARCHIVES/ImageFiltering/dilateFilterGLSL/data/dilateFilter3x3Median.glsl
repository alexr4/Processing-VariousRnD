

uniform sampler2D texture;
uniform vec2 resolution;
uniform float ratio = 0.1;

out vec4 fragColor;


#define order(a, b)					temp = a; a = min(a, b); b = max(temp, b);
#define order2(a, b)				order(steps[a], steps[b]);
#define orderMin3(a, b, c)			order2(a, b); order2(a, c);
#define orderMax3(a, b, c)			order2(b, c); order2(a, c);
#define order3(a, b, c)				orderMax3(a, b, c); order2(a, b);
#define order4(a, b, c, d)			order2(a, b); order2(c, d); order2(a, c); order2(b, d);
#define order5(a, b, c, d, e)		order2(a, b); order2(c, d); orderMin3(a, c, e); orderMax3(b, d, e);
#define order6(a, b, c, d, e, f)	order2(a, d); order2(b, e); order2(c, f); orderMin3(a, b, c); orderMax3(d, e, f);

void main(){
	vec2 uv = gl_FragCoord.xy / resolution.xy; 
	vec2 uvinc = vec2(1.0) / resolution.xy;
	vec2 invuv = vec2(uv.x, 1.0 - uv.y);
	vec4 tex = texture(texture, invuv);

	float steps[9];
	float temp;
	steps[0] = step(ratio, texture(texture, invuv + vec2(-1.0, -1.0) * uvinc).r);
	steps[1] = step(ratio, texture(texture, invuv + vec2(0.0, -1.0)  * uvinc).r);
	steps[2] = step(ratio, texture(texture, invuv + vec2(1.0, -1.0)  * uvinc).r);
	steps[3] = step(ratio, texture(texture, invuv + vec2(-1.0, 0.0)  * uvinc).r);
	steps[4] = step(ratio, texture(texture, invuv + vec2(.0, .0)     * uvinc).r);
	steps[5] = step(ratio, texture(texture, invuv + vec2(1.0, .0)    * uvinc).r);
	steps[6] = step(ratio, texture(texture, invuv + vec2(-1.0, 1.0)  * uvinc).r);
	steps[7] = step(ratio, texture(texture, invuv + vec2(.0, 1.0)    * uvinc).r);
	steps[8] = step(ratio, texture(texture, invuv + vec2(1.0, 1.0)   * uvinc).r);

	
	vec4 color = vec4(vec3(steps[8]), 1.0);
	

	fragColor =  color;
}