#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform vec2 resolution;
uniform float threshold = 1.0;
uniform vec3 thresholdRGB = vec3(1.0);
uniform float thresholdNB = 1.0;

uniform float mousex;

in vec4 vertTexCoord;

out vec4 fragColor;

vec4 ContrastSaturationBrightness(vec4 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin = vec3(AvgLumR, AvgLumG, AvgLumB);
	vec3 brtColor = color.rgb * brt;
	vec3 intensity = vec3(dot(brtColor, LumCoeff));
	vec3 satColor = mix(intensity, brtColor, sat);
	vec3 conColor = mix(AvgLumin, satColor, con);
	return vec4(conColor, 1.0);
}

/*
** Gamma correction
** Details: http://blog.mouaif.org/2009/01/22/photoshop-gamma-correction-shader/
*/
#define GammaCorrection(color, gamma)								pow(color, 1.0 / gamma)

/*
** Levels control (input (+gamma), output)
** Details: https://mouaif.wordpress.com/2009/01/28/levels-control-shader/
*/
#define LevelsControlInputRange(color, minInput, maxInput)				min(max(color - vec3(minInput), vec3(0.0)) / (vec3(maxInput) - vec3(minInput)), vec3(1.0))
#define LevelsControlInput(color, minInput, gamma, maxInput)				GammaCorrection(LevelsControlInputRange(color, minInput, maxInput), gamma)
#define LevelsControlOutputRange(color, minOutput, maxOutput) 			mix(vec3(minOutput), vec3(maxOutput), color)
#define LevelsControl(color, minInput, gamma, maxInput, minOutput, maxOutput) 	LevelsControlOutputRange(LevelsControlInput(color, minInput, gamma, maxInput), minOutput, maxOutput)


vec3 rgb2hsv(vec3 rgb)
{
	float Cmax = max(rgb.r, max(rgb.g, rgb.b));
	float Cmin = min(rgb.r, min(rgb.g, rgb.b));
    float delta = Cmax - Cmin;

	vec3 hsv = vec3(0., 0., Cmax);
	
	if (Cmax > Cmin)
	{
		hsv.y = delta / Cmax;

		if (rgb.r == Cmax)
			hsv.x = (rgb.g - rgb.b) / delta;
		else
		{
			if (rgb.g == Cmax)
				hsv.x = 2. + (rgb.b - rgb.r) / delta;
			else
				hsv.x = 4. + (rgb.r - rgb.g) / delta;
		}
		hsv.x = fract(hsv.x / 6.);
	}
	return hsv;
}

float chromaKey(vec3 color)
{
	vec3 backgroundColor = vec3(0.157, 0.576, 0.129);
	vec3 weights = vec3(4., 1., 2.);

	vec3 hsv = rgb2hsv(color);
	vec3 target = rgb2hsv(backgroundColor);
	float dist = length(weights * (target - hsv));
	return 1. - clamp(3. * dist - 1.5, 0., 1.);
}

//based on the tutorial : https://learnopengl.com/#!Advanced-Lighting/Bloom
vec3 getBright(vec3 color_, float threshold_){
	float brightness = dot(color_.rgb, vec3(0.2126, 0.7152, 0.0722));
	float inc = step(threshold_, brightness);
	return color_ * inc;
}

vec3 getBright(vec3 color_, vec3 threshold_){
	//float brightness = dot(color_.rgb, vec3(0.2126, 0.7152, 0.0722));
	float brightRed = color_.r * 0.2126;
	float brightGreen = color_.g * 0.7152;
	float brightBlue = color_.b * 0.0722;

	float incRed = step(threshold_.r, brightRed);
	float incGreen = step(threshold_.g, brightGreen);
	float incBlue = step(threshold_.b, brightBlue);

	return color_ * vec3(incRed, incGreen, incBlue);
}


void main(){
	vec2 uv = gl_FragCoord.xy / resolution.xy;
	uv.y = 1.0 - uv.y;

	vec4 Albedo = texture2D(texture, uv);
	

	vec4 AlbedoC = vec4(getBright(Albedo.rgb, threshold), 1.0);
	//Albedo = ContrastSaturationBrightness(Albedo, 1.0, 0.0, thresholdNB);
	//Albedo.rgb = LevelsControlInput(Albedo.rgb, 0.9, vec3(0.99), 1.0);

	fragColor = AlbedoC;
}