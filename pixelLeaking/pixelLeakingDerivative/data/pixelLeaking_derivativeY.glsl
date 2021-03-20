/*
Pre-processor macro defining the behavior of the GLSL program according to the GLSL version
Here we define, if the program run on a GL_ES environment (mainly used for web and mobile devices) we will use float value with medium precision
More precision (highp) will goes will more latency and low precision (lowp) will be faster but not precise
*/
#ifdef GL_ES
precision mediump float;
#endif


//pre-processor macro defining the key word PI as 3.14159265359 will compiled
#define PI 3.14159265359

/*
uniform variables are the variables bounds to the shader from the CPU side (Javascript in our case)
They are set to read-only and cannot be modified by the shader because they need to be identical for each fragment of the images
u_time, u_resolution, u_mouse and image are uniform provided by the glsl-preview package. See the documentation of the package online for more informations
*/
uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D texture; //beach.jpg

in vec4 vertTexCoord;
out vec4 fragColor;

mat2 rotate2d(float angle){
  return mat2(cos(angle), -sin(angle),
              sin(angle),  cos(angle));
}

vec2 rotate(vec2 st, float angle){
  //move to center
  st -= vec2(0.5);
  //rotate
  st = rotate2d(angle) * st;
  //reset position
  st += vec2(0.5);
  return st;
}

float getLuma(vec3 rgb){
	float luma = dot(rgb, vec3(0.229, 0.587, 0.114));
	return luma;
}

void main(){
  //compute the normalize screen coordinate
  vec2 st = gl_FragCoord.xy/resolution.xy;
  st.y = 1.0 - st.y;
  vec2 texel = vec2(1.0) / resolution.xy;
	vec2 direction = vec2(0, -1);

  //get the color of the pixel and convert it into luma grayscal
  vec4 rgba = texture2D(texture, st);
	float pixelGray = getLuma(rgba.rgb);

  float edge = .5;
  vec4 color = rgba;

  float DDXY = length(dFdy(pixelGray));// -> add extension on GL_ES2
	// DDXY = length(fwidth(pixelGray));
	float stepPerTexel = 2.;
	#define IT 45
		for(int y=0; y<IT; y++){
			float normi = float(y) / float(IT);
			float inormi = 1.0 - normi;
			vec2 dir = vec2(0.0, float(y) * stepPerTexel) * texel;
		  // dir = rotate2d(PI * 2.0 * fract(u_time * 0.5)) * dir;

			vec2 nei = st + dir;
			vec4 neirgba = texture2D(texture, nei);
			float npixelGray = getLuma(neirgba.rgb);
			float stepper = step(edge, npixelGray);
			float value = npixelGray * stepper;
			// DDXY += length(dFdy(value)) * inormi;
			DDXY += length(dFdy(value)) * inormi;
			DDXY = clamp(DDXY, 0.0, 1.0);
			// color = neirgba * DDXY + rgba * (1.0 - DDXY);
			// color = max(rgba, neirgba * DDXY);
			color = mix(rgba, neirgba, DDXY);
		}

  //draw everything
  fragColor = vec4(color.rgb, 1.0);;
}
