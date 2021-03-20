#version 450
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
#define offset 43758.5453123
uniform sampler2D texture;
uniform vec2 resolution;
uniform float step = 20.0;
uniform float strength = 0.05;
uniform float inc = 0.25;
uniform float distMin = 0.0;
uniform float distMax = 1.0;

in vec4 vertTexCoord;
out vec4 fragColor;

//RANDOM
float random(vec2 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xy, vec2(12.9898, 78.233))) * offset);
}

float random(vec3 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xyz, vec3(12.9898, 78.233, 12.9898))) * offset);//43758.5453123);
}

//CHROMA WARPING
vec4 chromaWarping(float step, sampler2D texture, vec2 uv, vec2 texCoord, vec2 texSize, float strength, float inc, float distMin, float distMax){
	vec4 blur = vec4(0.0);
    vec2 toCenter = (texCoord.xy) - gl_FragCoord.xy;
	float dist = smoothstep(distMin, distMax, distance(uv, texCoord / texSize));
	float strengthRad = strength * dist;

    /* randomize the lookup values to hide the fixed number of samples */
    float offsetRad = random(vec3(12.9898, 78.233, 151.7182));
    
    for (float t = 0.0; t <= step; t++) {
        float percent = (t + offsetRad) / step;
        float weight = 4.0 * (percent - percent * percent);  
		//Define offset for RGB split
		vec2 offsetR = vec2(inc, inc);
		vec2 offsetG= vec2(0, 0);
		vec2 offsetB = vec2(inc, inc) * -1.0;

		vec2 uvR = uv + offsetR * percent * strengthRad;
		vec2 uvG = uv + offsetG * percent * strengthRad;
		vec2 uvB = uv + offsetB * percent * strengthRad;
		vec2 uvA = uv;

        vec4 sampleTex = vec4(texture2D(texture, uvR + toCenter * percent * strengthRad / texSize.xy).r, texture2D(texture, uvG + toCenter * percent * strengthRad / texSize.xy).g, texture2D(texture, uvB + toCenter * percent * strengthRad / texSize.xy).b, texture2D(texture, uvA + toCenter * percent * strengthRad / texSize.xy).a);

        /* switch to pre-multiplied alpha to correctly blur transparent images */      
        sampleTex.rgb *= sampleTex.a;
        
        blur.rgb += sampleTex.rgb * weight;
        blur.a += weight;
    }

    return vec4(blur.rgb / blur.a, 1.0);
}

void main(){
	vec4 chromawarp = chromaWarping(step, texture, vertTexCoord.xy, resolution.xy/2.0, resolution.xy, strength, inc, distMin, distMax);
	fragColor = chromawarp;
}