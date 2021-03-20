
//Morgan McGuire implementation : http://casual-effects.com/research/McGuire2008Median/index.html
uniform sampler2D texture;
uniform vec2 resolution;

out vec4 fragColor;

//median functions
#define order(a, b)					temp = a; a = min(a, b); b = max(temp, b);
#define order2(a, b)				order(pix[a], pix[b]);
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

	vec3 pix[9];
	vec3 temp;

	//feed the array with the 5x5 neighbors
	for(int dX = -1; dX <= 1; dX++){
		for(int dY = -1; dY <= 1; dY ++){
			vec2 offset = vec2(dX, dY);
			vec4 pixRGBA  = texture(texture, invuv + offset * uvinc);
			pix[(dX + 1) * 3 + (dY + 1)] = pixRGBA.rgb;
		}
	}

	order6(0, 1, 2, 3, 4, 5);
	order5(1, 2, 3, 4, 6);
	order4(2, 3, 4, 7);
	order3(3, 4, 8);

	vec4 color = vec4(pix[4], 1.0);

	fragColor =  color;
}