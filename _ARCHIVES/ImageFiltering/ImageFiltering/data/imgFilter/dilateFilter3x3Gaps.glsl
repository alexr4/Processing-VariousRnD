

uniform sampler2D texture;
uniform vec2 resolution;
uniform float ratio = 0.5;
uniform float radius = 0.0;
uniform vec2 offset = vec2(0.0);

out vec4 fragColor;

void dilate(inout float average_, float ratio_, float radius_, vec2 uv_, vec2 offset_, vec2 uvInc_, sampler2D texture_){
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2(-1.0 - radius_, -1.0 - radius_) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2( 0.0          , -1.0 - radius_) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2( 1.0 + radius_, -1.0 - radius_) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2(-1.0 - radius_,  0.0          ) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2( 0.0          ,  0.0          ) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2( 1.0 + radius_,  0.0          ) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2(-1.0 - radius_,  1.0 + radius_) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2( 0.0          ,  1.0 + radius_) * uvInc_).r);
	average_ += step(ratio_, texture(texture_, uv_ + offset_ * uvInc_ + vec2( 1.0 + radius_,  1.0 + radius_) * uvInc_).r);
	average_ /= 9.0;
}

void main(){
	vec2 uv = gl_FragCoord.xy / resolution.xy; 
	vec2 uvinc = vec2(1.0) / resolution.xy;
	vec2 invuv = vec2(uv.x, 1.0 - uv.y);
	vec4 tex = texture(texture, invuv);

	vec2 offset = vec2(0.0);
	//First star
	float averageNeighbors0;
	float averageNeighbors1;
	float averageNeighbors2;
	float averageNeighbors3;
	float averageNeighbors4;
	//Second star
	float averageNeighbors5;
	float averageNeighbors6;
	float averageNeighbors7;
	float averageNeighbors8;
	//third star
	float averageNeighbors9;
	float averageNeighbors10;
	float averageNeighbors11;
	float averageNeighbors12;
	//fourth star
	float averageNeighbors13;
	float averageNeighbors14;
	float averageNeighbors15;
	float averageNeighbors16;

	dilate(averageNeighbors0 , ratio, radius, invuv, offset, uvinc, texture);


	dilate(averageNeighbors1 , ratio, radius, invuv, vec2(-2, -1), uvinc, texture);
	dilate(averageNeighbors2 , ratio, radius, invuv, vec2( 2, -1), uvinc, texture);
	dilate(averageNeighbors3 , ratio, radius, invuv, vec2(-2,  1), uvinc, texture);
	dilate(averageNeighbors4 , ratio, radius, invuv, vec2( 2,  1), uvinc, texture);

	dilate(averageNeighbors5 , ratio, radius, invuv, vec2(-1, -2), uvinc, texture);
	dilate(averageNeighbors6 , ratio, radius, invuv, vec2( 1, -2), uvinc, texture);
	dilate(averageNeighbors7 , ratio, radius, invuv, vec2(-1,  2), uvinc, texture);
	dilate(averageNeighbors8 , ratio, radius, invuv, vec2( 1,  2), uvinc, texture);

	dilate(averageNeighbors9 , ratio, radius, invuv, vec2(-4, -2), uvinc, texture);
	dilate(averageNeighbors10, ratio, radius, invuv, vec2( 4, -2), uvinc, texture);
	dilate(averageNeighbors11, ratio, radius, invuv, vec2(-4,  2), uvinc, texture);
	dilate(averageNeighbors12, ratio, radius, invuv, vec2( 4,  2), uvinc, texture);

	dilate(averageNeighbors13, ratio, radius, invuv, vec2(-2, -4), uvinc, texture);
	dilate(averageNeighbors14, ratio, radius, invuv, vec2( 2, -4), uvinc, texture);
	dilate(averageNeighbors15, ratio, radius, invuv, vec2(-2,  4), uvinc, texture);
	dilate(averageNeighbors16, ratio, radius, invuv, vec2( 2,  4), uvinc, texture);

	float average = averageNeighbors0  +
					averageNeighbors1  +
					averageNeighbors2  +
					averageNeighbors3  +
					averageNeighbors4  +
					averageNeighbors5  +
					averageNeighbors6  +
					averageNeighbors7  +
					averageNeighbors9  +
					averageNeighbors10 +
					averageNeighbors11 +
					averageNeighbors12 +
					averageNeighbors13 +
					averageNeighbors14 +
					averageNeighbors15 +
					averageNeighbors16;
	average /= 17.0;


	float isWhite  = step(ratio, average);

	
	vec4 color = vec4(vec3(isWhite), 1.0);
	

	fragColor =  color;
}