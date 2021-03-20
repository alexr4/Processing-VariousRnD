#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define offset 43758.5453123
uniform sampler2D texture;
uniform float angle;
uniform float leaklength = 25.0;
uniform vec2 resolution;
uniform float threshold = 0.75;
uniform float thresholdGap = 0.05;
uniform float thresholdSmooth = 0.05;
uniform float damping = 0.1;

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
	vec2 texel = vec2(0.0, 1.0) / resolution.xy;
	//define target uv
	vec2 orientation = vec2(cos(angle), sin(angle));
	vec2 targetUV = uv + orientation * texel * leaklength;

	//get pixel and target pixel
	vec4 tex = texture(texture, uv);
	vec4 texTarget = texture(texture, targetUV);

	//define mask and damping for gradient leaking
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