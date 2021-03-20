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
#define NEIGHBORSSTEP 4

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

float getLuma(vec3 rgb){
	float luma = dot(rgb, vec3(0.229, 0.587, 0.114));
	return luma;
}

void main(){
  //compute the normalize screen coordinate
  vec2 st = gl_FragCoord.xy/resolution.xy;
  vec2 texel = vec2(1.0) / resolution.xy;
	vec2 direction = vec2(0, -1);

  //get the color of the pixel and convert it into luma grayscal
  vec4 rgba = texture2D(texture, st);
	float pixelGray = getLuma(rgba.rgb);

  float edge = 0.55;
  vec4 color = vec4(0.0);

  float DDXY = length(fwidth(pixelGray));// -> add extension on GL_ES2
	// float oddxy = DDXY;
	float decrement = .05 / float(NEIGHBORSSTEP);
	for(int x= -NEIGHBORSSTEP; x<=NEIGHBORSSTEP; x++){
		for(int y= -NEIGHBORSSTEP; y<=NEIGHBORSSTEP; y++){
			float inc = decrement * abs(float(x)) + decrement * abs(float(y));
			vec2 nei = vec2(x, y) * texel + st;
			vec4 rgba = texture2D(texture, nei);
			float pixelGray = getLuma(rgba.rgb);
			DDXY += length(fwidth(pixelGray)) * inc;
		}
	}

  // DDXY = clamp(DDXY * 1.0, 0.0, 1.0);
	float dx = dFdx(pixelGray) * 2.5;
	float dy = dFdy(pixelGray) * 2.5;


	color.rgb = vec3(DDXY * 0.9 + 0.1);
  //draw everything
  fragColor = vec4(color.rgb, 1.0);;
}
