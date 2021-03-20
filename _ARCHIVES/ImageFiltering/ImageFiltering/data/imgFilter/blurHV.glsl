#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif
const float PI = 3.14159265;

uniform sampler2D texture;
uniform float blurSize = 8.0;
uniform int pass; //0 = horizontal , 1 = vertical
uniform float sigma = 4.0; //The sigma value for the gaussian function: higher value means more blur
uniform vec2 texOffset = vec2(2.0, 2.0);

in vec4 vertTexCoord;
in vec4 vertColor;
out vec4 fragColor;



void main(){
	float blurPerSide = blurSize / 2.0;
	vec2 blurMultiply = vec2(0.0, 0.0);
	if(pass == 0){
		blurMultiply = vec2(1.0, 0.0);
	}else{
		blurMultiply = vec2(0.0, 1.0);
	}

	//Incremental Gaussian Coefficient computation (See GPU Gems 3 pp. 877 - 889)
	vec3 incGaussian = vec3(0.0);
	incGaussian.x = 1.0 / (sqrt(2.0 * PI) * sigma);
	incGaussian.y = exp(-0.5 / (sigma * sigma));
	incGaussian.z = incGaussian.y * incGaussian.y;

	vec4 averageVal = vec4(0.0);
	float coeffSum = 0.0;

	//Take central point at first
	averageVal += texture(texture, vertTexCoord.st) * incGaussian.x;
	coeffSum += incGaussian.x;
	incGaussian.xy *= incGaussian.yz;

	//Pass throught the 8 samples (4 by sides)
	for(float i=1.0; i<=blurPerSide; i++){
		averageVal += texture(texture, vertTexCoord.st - i * texOffset * blurMultiply) * incGaussian.x;
		averageVal +=  texture(texture, vertTexCoord.st + i * texOffset * blurMultiply) * incGaussian.x;
		coeffSum += 2.0 *incGaussian.x;
		incGaussian.xy *= incGaussian.yz;
	}

	vec4 Albedo = averageVal / coeffSum;

	fragColor = Albedo;
}