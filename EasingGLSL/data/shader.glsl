#version 150
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform int time;
uniform vec2 mouse;

in vec4 vertTexCoord;
out vec4 fragColor;

#include random.glsl
#include easing.glsl
#include draw.glsl
#include strokeFill.glsl

float fplot(float value, float axis){
	float plt = plot(value, axis);
	return smoothStroke(plt, 0.0, 0.001, 0.0025);
}

float drawCirc(vec2 uv, vec2 pos, float thick, float smoothness){
	float shape = circle(uv, pos);
	return smoothFill(shape, thick, smoothness);
}

void main(){
	vec2 uv = vertTexCoord.xy;

	vec2 colsrows = vec2(3.0, 8.0);
	vec2 nuv = uv*colsrows;
	vec2 iuv = floor(nuv);
	vec2 fuv = fract(nuv);
	float index = floor(iuv.x + iuv.y * colsrows.x);

	float axis = uv.x;
	float value = 1.0 - uv.y;
	float minTime = 2000.0;
	float maxTime = 6000.0;
	//use this two lines if you want random max time for each cells
	// float rndMaxTime = random(iuv) * (maxTime - minTime) + minTime;
	// float normTime = fract(float(time) / rndMaxTime);
	float normTime = fract(float(time) / 2000.0);

	float eased = inQuad(normTime) 				*  (1.0 - step(1.0, index)) +
				  outQuad(normTime) 			* (step(1.0, index) 	* (1.0 -  step(2.0, index))) +
				  inoutQuad(normTime) 			* (step(2.0, index) 	* (1.0 -  step(3.0, index))) +
				  inCubic(normTime) 			* (step(3.0, index) 	* (1.0 -  step(4.0, index))) +
				  outCubic(normTime) 			* (step(4.0, index) 	* (1.0 -  step(5.0, index))) +
				  inoutCubic(normTime)  		* (step(5.0, index) 	* (1.0 -  step(6.0, index))) +
				  inQuartic(normTime) 			* (step(6.0, index) 	* (1.0 -  step(7.0, index))) +
				  outQuartic(normTime) 			* (step(7.0, index) 	* (1.0 -  step(8.0, index))) +
				  inoutQuartic(normTime)		* (step(8.0, index) 	* (1.0 -  step(9.0, index))) +
				  inQuintic(normTime) 			* (step(9.0, index) 	* (1.0 -  step(10.0, index))) +
				  outQuintic(normTime) 			* (step(10.0, index) 	* (1.0 -  step(11.0, index))) +
				  inoutQuintic(normTime)		* (step(11.0, index) 	* (1.0 -  step(12.0, index))) +
				  inSin(normTime) 				* (step(12.0, index) 	* (1.0 -  step(13.0, index))) +
				  outSin(normTime) 				* (step(13.0, index) 	* (1.0 -  step(14.0, index))) +
				  inoutSin(normTime)			* (step(14.0, index) 	* (1.0 -  step(15.0, index))) +
				  inExp(normTime) 				* (step(15.0, index) 	* (1.0 -  step(16.0, index))) +
				  outExp(normTime) 				* (step(16.0, index) 	* (1.0 -  step(17.0, index))) +
				  inoutExp(normTime)			* (step(17.0, index) 	* (1.0 -  step(18.0, index))) +
				  inCirc(normTime) 				* (step(18.0, index) 	* (1.0 -  step(19.0, index))) +
				  outCirc(normTime) 			* (step(19.0, index) 	* (1.0 -  step(20.0, index))) +
				  inoutCirc(normTime)			* (step(20.0, index) 	* (1.0 -  step(21.0, index))) +
				  inElastic(normTime, 4.0) 		* (step(21.0, index) 	* (1.0 -  step(22.0, index))) +
				  outElastic(normTime, 4.0) 	* (step(22.0, index) 	* (1.0 -  step(23.0, index))) +
				  inoutElastic(normTime, 4.0)	* (step(23.0, index) 	* (1.0 -  step(24.0, index)));


	fuv = fuv * 2. - 1.0;
	fuv *= 1.5;
	fuv = fuv *0.5 + 0.5;
	
	float rectaxis =  rect(fuv, vec2(1.0));
	float strokeAxis = smoothStroke(rectaxis, 1.0, 0.05, 0.001);

	float circle = drawCirc(fuv, vec2(0.5), eased * 0.5, 0.025);


	vec3 color = vec3(strokeAxis) + 
				 circle +
				 vec3(fuv, 0);

	fragColor = vec4(color, 1.0);
}


