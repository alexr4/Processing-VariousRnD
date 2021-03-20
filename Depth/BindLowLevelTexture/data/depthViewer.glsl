
uniform sampler2D texture;
uniform sampler2D depthTexture;

varying vec4 vertTexCoord;

const vec4 one = vec4(1.);

float LinearizeDepth(float zoverw){
	float n = 200.0; // camera z near	
	float f = 1000.0; // camera z far	
	return (2.0 * n) / (f + n - zoverw * (f - n));
}


void main() {  
 	// vec4 t1 = texture2D(texture, vertTexCoord.st); 
    vec4 t2 = texture2D(depthTexture, vertTexCoord.st); 

    gl_FragColor = vec4(t2.rgb, 1.0); 

	// depth = LinearizeDepth(depth) ;
	// depth = depth==0.0 ? 0 : 1;
	// gl_FragColor = vec4(depth, depth, depth, 1.0);
	//gl_FragColor = vec4(linearDepth(t2.r),0,0 ,1.);
}


