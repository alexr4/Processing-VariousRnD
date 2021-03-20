
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D checker;
uniform sampler2D depthTexture;

varying vec4 vertTexCoord;

const vec4 one = vec4(1.);

float LinearizeDepth(float zoverw){
	float n = 200.0; // camera z near	
	float f = 1000.0; // camera z far	
	return (2.0 * n) / (f + n - zoverw * (f - n));
}


void main() {  
 	vec4 t1 = texture2D(texture1, vertTexCoord.st); 
 	vec4 t2 = texture2D(texture2, vertTexCoord.st); 
 	vec4 checkrgb = texture2D(checker, vertTexCoord.st); 
	 checkrgb.rgb *= 0.5;
	float stepper = step(0.5, vertTexCoord.s);
	vec4 t12 = t1 * stepper + t2 * (1.0 - stepper);
    vec4 t3 = texture2D(depthTexture, vertTexCoord.st); 

    gl_FragColor = vec4(mix(t12.rgb, t3.rgb, 0.5), 1.0) + checkrgb; 
}


