
uniform sampler2D texture;
uniform sampler2D mask;
uniform sampler2D backTexture;
uniform float type = 0.0;
uniform vec2 resolution;

out vec4 fragColor;

void main(){
	vec2 uv = gl_FragCoord.xy / resolution.xy; 
	vec4 rgbTop = texture(texture, uv);
	vec4 rgbBackColor = vec4(1., 1., 1., 0.0);
	vec4 rgbBackTex = vec4(texture(backTexture, uv).rgb, 0.0);
	vec4 rgbBack = mix(rgbBackColor, rgbBackTex, type);

	vec4 a = texture(mask, uv);

	vec4 color = mix(rgbBack, rgbTop, smoothstep(0.5, 0.8, a.r));
	//vec4 color = rgbTop * a.r + (1. - a.r) * rgbBack;
	//vec4 color = rgbd + a * (rgbs - rgbd);

	fragColor =  color;
}