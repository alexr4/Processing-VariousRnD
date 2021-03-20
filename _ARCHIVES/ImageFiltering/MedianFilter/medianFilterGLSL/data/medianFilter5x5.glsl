
/*
Morgan McGuire implementation of a 5*5 median filter
http://casual-effects.com/research/McGuire2008Median/index.html
RGB filtering
*/
uniform sampler2D texture;
uniform vec2 resolution;

out vec4 fragColor;

//median functions
#define order(a, b)									temp = a; a = min(a, b); b = max(temp, b);
#define order2(a, b)								order(pix[a], pix[b]);
#define order2by4(a, b, c, d, e, f, g, h)			order2(a, b); order2(c, d); order2(e, f); order2(g, h); 
#define order2by5(a, b, c, d, e, f, g, h, i, j)		order2by4(a, b, c, d, e, f, g, h); order2(i, j);

void main(){
	vec2 uv = gl_FragCoord.xy / resolution.xy; 
	vec2 uvinc = vec2(1.0) / resolution.xy;
	vec2 invuv = vec2(uv.x, 1.0 - uv.y);
	//vec4 tex = texture(texture, invuv);

	//Declare array and temp value
	vec3 pix[25];
	vec3 temp;

	//feed the array with the 5x5 neighbors
	for(int dX = -2; dX <= 2; dX++){
		for(int dY = -2; dY <= 2; dY ++){
			vec2 offset = vec2(dX, dY);
			vec4 pixRGBA  = texture(texture, invuv + offset * uvinc);
			pix[(dX + 2) * 5 + (dY + 2)] = pixRGBA.rgb;
		}
	}

	//order 5*5 neighbors pixels
	order2by5(0,1, 3,4, 2,4, 2,3, 6,7);
	order2by5(5,7, 5,6, 9,7, 1,7, 1,4);
	order2by5(12,13, 11,13, 11,12, 15,16, 14,16);
	order2by5(14,15, 18,19, 17,19, 17,18, 21,22);
	order2by5(20,22, 20,21, 23,24, 2,5, 3,6);
	order2by5(0,6, 0,3, 4,7, 1,7, 1,4);
	order2by5(11,14, 8,14, 8,11, 12,15, 9,15);
	order2by5(9,12, 13,16, 10,16, 10,13, 20,23);
	order2by5(17,23, 17,20, 21,24, 18,24, 18,21);
	order2by5(19,22, 8,17, 9,18, 0,18, 0,9);
	order2by5(10,19, 1,19, 1,10, 11,20, 2,20);
	order2by5(2,11, 12,21, 3,21, 3,12, 13,22);
	order2by5(4,22, 4,13, 14,23,5,23,5,14);
	order2by5(15,24, 6,24, 6,15, 7,16, 7,19);
	order2by5(3,11, 5,17, 11,17, 9,17, 4,10);
	order2by5(6,12, 7,14, 4,6, 4,7, 12,14);
	order2by5(10,14, 6,7, 10,12, 6,10, 6,17);
	order2by5(12,17, 7,17, 7,10, 12,18, 7,12);
	order2by4(10,12, 12,20, 10,20, 10,12);

	vec4 color = vec4(pix[12], 1.0);

	fragColor =  color;
}