#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D previousFrame;
uniform sampler2D texture;
uniform float threshold = 0.001; //framedifferencing Threshold
uniform float offsetInc = 0.1;
uniform vec2 offset = vec2(1.0, 1.0); //offset for sobel Operation
uniform float lambda = 0.1;
uniform vec2 scale = vec2(1.0, 1.0);

in vec4 vertTexCoord;
in vec4 vertColor;
out vec4 fragColor;

vec4 packFlowAsColor(float fx ,float fy, vec2 scale){
	vec2 flowX = vec2(max(fx, 0.0), abs(min(fx, 0.0))) * scale.x;
	vec2 flowY = vec2(max(fy, 0.0), abs(min(fy, 0.0))) * scale.y;
	float dirY = 1.0;
	if(flowY.x > flowY.y){
		dirY = 0.9;
	}
	vec4 rgbaPacked = vec4(flowX.x, flowX.y, max(flowY.x, flowY.y), dirY);

	return rgbaPacked;
}

vec4 getGray(vec4 inputPix){
	float gray = dot(vec3(inputPix.x, inputPix.y, inputPix.z), vec3(0.3, 0.59, 0.11));
	return vec4(gray, gray, gray, 1.0);
}

vec4 getGrayTexture(sampler2D tex, vec2 texCoord){
	return getGray(texture2D(tex, texCoord));
}

vec4 getGradientAt(sampler2D current, sampler2D previous, vec2 texCoord, vec2 offset){
	vec4 gradient = getGrayTexture(previous, texCoord + offset) - getGrayTexture(previous, texCoord - offset);
	gradient += getGrayTexture(current, texCoord + offset) - getGrayTexture(current, texCoord - offset);
	return gradient;
}

void main()
{
	vec4 current = texture(texture, vertTexCoord.st);
	vec4 previous = texture(previousFrame, vertTexCoord.st);
	
	vec2 offsetX = vec2(offset.x * offsetInc, 0.0);
	vec2 offsetY = vec2(0.0, offset.y * offsetInc);

	//Frame Differencing (dT)
	vec4 differencing = previous - current;
	float vel = (differencing.r + differencing.g + differencing.b)/3;
	float movement = smoothstep(threshold, 1.0, vel);
	vec4 newDifferencing = vec4(movement);
	//movement = pow(movement, 1.0);


	//Compute the gradient (movement Per Axis) (look alike sobel Operation)
	vec4 gradX = getGradientAt(texture, previousFrame, vertTexCoord.st, offsetX);
	vec4 gradY = getGradientAt(texture, previousFrame, vertTexCoord.st, offsetY);

	//Compute gradMagnitude
	vec4 gradMag = sqrt((gradX * gradX) + (gradY * gradY) + vec4(lambda));

	//compute Flow
	vec4 vx = newDifferencing * (gradX / gradMag);
	vec4 vy = newDifferencing * (gradY / gradMag);

	vec4 flowCoded = packFlowAsColor(vx.r, vy.r, scale);
	
	fragColor = flowCoded;
}
