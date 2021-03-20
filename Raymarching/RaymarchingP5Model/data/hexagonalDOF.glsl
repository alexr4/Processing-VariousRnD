//blend sources : http://wiki.polycount.com/wiki/Blending_functions

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 resolution;
uniform vec2 mouse;

in vec4 vertTexCoord;
out vec4 fragColor;

// blur with hexagonalish sampling pattern from HALCY on ShaderToy https://www.shadertoy.com/view/4tK3WK
// weighs samples according to coc size (so that "in focus" samples count for less)
// and according to tap nb (weighs outer samples higher)
vec3 hexablur(sampler2D tex, vec2 resolution, vec2 uv) {
    vec2 scale = vec2(1.0) / resolution.xy;
    vec3 col = vec3(0.0);
    float asum = 0.0;
    float coc = texture2D(tex, uv).a;
    for(float t = 0.0; t < 8.0 * 2.0 * 3.14; t += 3.14 / 32.0) {
    	float r = cos(3.14 / 6.0) / cos(mod(t, 2.0 * 3.14 / 6.0) - 3.14 / 6.0);
        
        // Tap filter once for coc
        vec2 offset = vec2(sin(t), cos(t)) * r * t * scale * coc;
        vec4 samp = texture(tex, uv + offset * 1.0);
        
        // Tap filter with coc from texture
        offset = vec2(sin(t), cos(t)) * r * t * scale * samp.a;
        samp = texture(tex, uv + offset * 1.0);
        
        // weigh and save
        col += samp.rgb * samp.a * t;
        asum += samp.a * t;
    }
    col = col / asum;
    return col;
}


void main(){
	vec2 uv = vertTexCoord.xy;
	vec3 rgb = hexablur(texture, resolution, uv);

	fragColor = vec4(rgb, 1.0);
}