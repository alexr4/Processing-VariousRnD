#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define offset 43758.5453123
#define PI 3.14159265359
uniform sampler2D texture;
uniform float angle;
uniform float leaklength = 25.0;
uniform vec2 resolution;
uniform float threshold = 0.75;
uniform float thresholdGap = 0.05;
uniform float thresholdSmooth = 0.05;
uniform float time = 1.0;

in vec4 vertTexCoord;
out vec4 fragColor;

float random(vec2 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xy, vec2(12.9898, 78.233))) * offset);
}

float random(vec3 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xyz, vec3(12.9898, 78.233, 12.9898))) * offset);
}

//useful method
vec3 mod289(vec3 v){ return v - floor(v * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 v){ return v - floor(v * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 v){ return mod289(((v * 34.0) + 1.0) * v); }

//simplex noise implementation of Ian McEwan & Ashima Art
float noise(vec2 uv){
	//compute value for skewed grid
	const vec4 C = vec4(0.211324865405187,
                        // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  
                        // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  
                        // -1.0 + 2.0 * C.x
                        0.024390243902439); 
                        // 1.0 / 41.0
    
    //compute first corner
    vec2 iuv = floor(uv + dot(uv, C.yy));
    vec2 x0 = uv - iuv + dot(iuv, C.xx);

    //Other 2 corners
    vec2 iuv1 = vec2(0.0);
    iuv1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 x1 = x0.xy + C.xx - iuv1;
    vec2 x2 = x0.xy + C.zz;

    //Permutation to avoid truncation
    iuv = mod289(iuv);
    vec3 p = permute(
    	permute(iuv.y + vec3(0.0, iuv1.y, 1.0))
    	+ iuv.x + vec3(0.0, iuv1.x, 1.0));

    vec3 m = max(0.5 - vec3(
    		dot(x0, x0),
    		dot(x1, x1),
    		dot(x2, x2)
    	), 0.0);

    m = m * m;
    m = m * m;

    //gradients
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    //normalize gradient
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

    //compute noise
    vec3 g = vec3(0.0);
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * vec2(x1.x, x2.x) + h.yz * vec2(x1.y, x2.y);

    return (130.0 * dot(m, g));// * 0.5 + 0.5; 
}

float noise3D(vec3 uv){	
	float n0 = noise(uv.xy);
	float n1 = noise(uv.yz);
	float n2 = noise(uv.xz);

	return ((n0 + n1 + n2) / 3.0) *.5+.5;
}


float luma(vec3 rgb){
	return dot(rgb, vec3(0.229, 0.587, 0.114));
}

float getMaxValue(float value, float target){
	float test = step(value,target);//(luma > targetLuma) ? 1.0 : 0.0
	value = target * test + value * (1.0 - test);
	return value;
}

vec3 getMaxLumaValue(float value, float target, vec3 valueRGB, vec3 targetRGB){
	float test = step(value,target);//(luma > targetLuma) ? 1.0 : 0.0
	targetRGB = targetRGB * test + valueRGB * (1.0 - test);
	return targetRGB;
}

void main(){
	vec2 uv = vertTexCoord.xy;

	//define texel size
	vec2 texel = vec2(1.0) / resolution.xy;
	//define target uv
	float noiseInc = 8.0;
	//float noiseUV = noise(uv);
	float noiseUVI = noise(uv * noiseInc);
	float noiseVUI = noise(uv.yx * noiseInc);
	float index = uv.x + uv.y;
	float amplitude = 0.1 + noiseUVI * 0.1;
	float loop = 8.0 + 0.25 * (noiseVUI * 2.0 - 1.0);
	float wave = sin(time + uv.x * PI * loop) * amplitude;

	vec2 orientation = vec2(cos(angle + wave), sin(angle + wave));
	vec2 targetUV = uv + orientation * texel * leaklength;

	//get pixel and target pixel
	vec4 tex = texture(texture, uv);
	vec4 texTarget = texture(texture, targetUV);

	//define mask and damping for gradient leaking
	float damping = 0.25;
	vec4 mask = vec4(0.0, 0.0, 0.0, 1.0);
	for(int i=0; i<leaklength; i++){
		//get target uv on distance
		vec2 targetUV = uv + orientation * texel * i;
		//get the pixel
		vec4 targetPixel = texture(texture, targetUV);
		//get the luma
		float targetLuma = luma(targetPixel.rgb);

		//check if color pixel is behind the threshold
		//float betweenStepper = step(threshold - thresholdGap, targetLuma) * (1.0 - step(threshold + thresholdGap, targetLuma)); //i(x > y) ? 1.0 : 0.0
		float betweenSmoothStepper = smoothstep(threshold - thresholdGap - thresholdSmooth, threshold - thresholdGap, targetLuma) * (1.0 - smoothstep(threshold + thresholdGap, threshold + thresholdGap + thresholdSmooth, targetLuma)); //i(x > y) ? 1.0 : 0.0
		//float stepper = step(threshold, targetLuma);


		//normalize index on the distance
		float normi = 1.0  - (float(i) / leaklength);
		//define mask
		mask.rgb += vec3(1.0 * normi * betweenSmoothStepper) * damping;

		//check if final luma is > to target, if not keep luma, else final became new
		texTarget.r = getMaxValue(texTarget.r, targetPixel.r);
		texTarget.g = getMaxValue(texTarget.g, targetPixel.g);
		texTarget.b = getMaxValue(texTarget.b, targetPixel.b);
	}

	mask = clamp(mask, vec4(0.0), vec4(1.0));

	fragColor = mix(tex, texTarget, mask);
}