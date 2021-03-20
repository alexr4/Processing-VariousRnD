// #extension GL_OES_standard_derivatives : enable
#ifdef GL_ES
precision mediump float;
#endif


#define PI 3.14159265359
#define MAXITERATION 40
#define OFFSET 1.

uniform vec2 resolution;

uniform sampler2D texture;

in vec4 vertTexCoord;
out vec4 fragColor;

float getLuma(vec3 rgb){
	float luma = dot(rgb, vec3(0.229, 0.587, 0.114));
	return luma;
}

void main(){
  //compute the normalize screen coordinate
  vec2 st = gl_FragCoord.xy / resolution.xy;
  st.y = 1.0 - st.y;
  vec2 texel = vec2(1.0) / vertTexCoord.xy;
  vec2 direction = vec2(0, -1);

  //get the color of the pixel and convert it into luma grayscal
  vec4 rgba = texture2D(texture, st.xy);
  float pixelGray = getLuma(rgba.rgb);

  float edge = 0.5;
  vec4 color = vec4(0.0);
  float DDXY = length(fwidth(rgba));// -> add extension on GL_ES2
  DDXY = clamp(DDXY * 2.5, 0.0, 1.0);
	
	
  for(int i=MAXITERATION; i>=0; i--){
		float ni = float(i) / float(MAXITERATION);
    	vec2 dst = st.xy - vec2(float(i) * OFFSET) * texel * direction;
    	vec4 nei = texture2D(texture, dst);

		float nDDXY = length(fwidth(nei));
		nDDXY = clamp(DDXY * 2.5, 0.0, 1.0);
   		 float gray = getLuma(nei.rgb);
		// float deviation = gray - pixelGray;
		float deviation = max(gray, pixelGray);
		// float deviation = DDXY - nDDXY;
    	float stepper = step(edge, deviation);
    	// float stepper = smoothstep(edge, edge + DDXY, deviation);
    	// float stepper = step(edge, gray);

		if(stepper >= 1.0){
			// color = vec4(vec3(deviation), 1.0);
			color = nei * (1. - ni) + rgba * ni;
			// color = rgba * (1.0 - ni) + nei * ni;
			break;
		}else{
			color = rgba;
		}

		// color.rgb = vec3(stepper);
  }
  
  //draw everything
  fragColor = vec4(color.rgb, 1.0);;
}
