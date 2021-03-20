#version 150
#ifdef GL_ES
precision highp float;
precision highp vec4;
precision highp vec3;
precision highp vec2;
precision highp int;
#endif

const vec4 efactor = vec4(1.0, 255.0, 65025.0, 16581375.0);
const vec4 dfactor = vec4(1.0/1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0);
const float mask = 1.0/256.0;

uniform sampler2D texture;
uniform sampler2D velBuffer;
uniform vec2 textureResolution;
uniform vec3 worldResolution;
uniform float maxSpeed;
//debug
uniform vec3 force;

in vec4 vertColor;
in vec4 vertTexCoord;
out vec4 fragColor;

struct interleavedUVS{
	vec2 uv;
	vec2 uvxy;
	vec2 uvxz;
	vec2 uvyx;
	vec2 uvyz;
	vec2 uvzx;
	vec2 uvzy;
};

vec4 encodeRGBA24(float v){
	vec3 rgb = v * efactor.rgb;
	rgb.gb = fract(rgb.gb);
	rgb.rg -= rgb.gb * mask;
	return vec4(rgb, 1.0);
}

vec4 encodeRGBA32(float v){
	vec4 rgba = v * efactor.rgba;
	rgba.gba = fract(rgba.gba);
	rgba.rgb -= rgba.gba * mask;
	return rgba;
}

float decodeRGBA32(vec4 rgba){
	return dot(rgba, dfactor.rgba);
}

float decodeRGBA24(vec3 rgb){
	return dot(rgb, dfactor.rgb);
}

vec3 getInterleavedXYZ(float pindex){
	//check the type of the fragment using %3 where 0 = x, 1 = y and z = 2
	float modi = round(mod(pindex, 3.0));

	//define stepper
	float isX = 1.0 - step(1.0, modi);
	float isZ = step(2.0, modi);
	float isY = 1.0 - (isX + isZ);

	return vec3(isX, isY, isZ);
}

interleavedUVS getInterleavedXYZUV(vec2 uv, float pindex, vec2 samplerResolution){//inout vec2 array[6], 
	//define other index per fragment
	//if x
	float ix1 = pindex + 1;
	float ix2 = pindex + 2;
	//if y
	float iy1 = pindex - 1;
	float iy2 = pindex + 1;
	//if z
	float iz1 = pindex - 2;
	float iz2 = pindex - 1;

	//define all the uv coord
	//if x
	float uxy = round(mod(ix1, samplerResolution.x));
	float vxy = round((ix1 - uxy) / samplerResolution.x);

	float uxz = round(mod(ix2, samplerResolution.x));
	float vxz = round((ix2 - uxz) / samplerResolution.x);

	//if y
	float uyx = round(mod(iy1, samplerResolution.x));
	float vyx = round((iy1 - uyx) / samplerResolution.x);

	float uyz = round(mod(iy2, samplerResolution.x));
	float vyz = round((iy2 - uyz) / samplerResolution.x);
	//if z
	float uzx = round(mod(iz1, samplerResolution.x));
	float vzx = round((iz1 - uzx) / samplerResolution.x);

	float uzy = round(mod(iz2, samplerResolution.x));
	float vzy = round((iz2 - uzy) / samplerResolution.x);

	//construct uvs
	vec2 uvxy = vec2(uxy, vxy) / samplerResolution;
	vec2 uvxz = vec2(uxz, vxz) / samplerResolution;

	vec2 uvyx = vec2(uyx, vyx) / samplerResolution;
	vec2 uvyz = vec2(uyz, vyz) / samplerResolution;

	vec2 uvzx = vec2(uzx, vzx) / samplerResolution;
	vec2 uvzy = vec2(uzy, vzy) / samplerResolution;

	interleavedUVS iuvs = interleavedUVS(
		uv,
		uvxy, uvxz,
		uvyx, uvyz,
		uvzx, uvzy
		);

	return iuvs;
}

vec3 getData(interleavedUVS iuvs, sampler2D samplerData, vec3 is){
	//get all the samplers per fragment
	vec4 RGBAX = texture2D(samplerData, iuvs.uv)   * is.x + texture2D(samplerData, iuvs.uvyx) * is.y + texture2D(samplerData, iuvs.uvzx) * is.z;
	vec4 RGBAY = texture2D(samplerData, iuvs.uvxy) * is.x + texture2D(samplerData, iuvs.uv)   * is.y + texture2D(samplerData, iuvs.uvzy) * is.z;
	vec4 RGBAZ = texture2D(samplerData, iuvs.uvxz) * is.x + texture2D(samplerData, iuvs.uvyz) * is.y + texture2D(samplerData, iuvs.uv)   * is.z;

	float x = decodeRGBA24(RGBAX.rgb);
	float y = decodeRGBA24(RGBAY.rgb);
	float z = decodeRGBA24(RGBAZ.rgb);

	return vec3(x, y, z);
}

void main(){
	//GLSL start 0,0 at bottom left, our buffer are fead from top left so we du not used vertTextCoord but defines our own uv
	vec2 pixelPosition = vec2(gl_FragCoord.x, textureResolution.y - gl_FragCoord.y);
	vec2 uv = pixelPosition.xy / textureResolution;

	//check if pixel is x, y or z
  	float pindex = round(gl_FragCoord.x + (textureResolution.y - gl_FragCoord.y) * textureResolution.x);
  	vec3  isXYZ = getInterleavedXYZ(pindex);

  	//get uvs for each pixels (if p is x get the yz, if p is y get xz, if p is z get xy)
	interleavedUVS iuvs = getInterleavedXYZUV(uv, pindex, textureResolution);

  	//Get the data from buffers
  	vec3 nvel = getData(iuvs, velBuffer, isXYZ);
  	vec3 nloc = getData(iuvs, texture, isXYZ);

  	//remap data into real world coord and max vel
  	vec3 vel = (nvel * 2.0 - 1.0) * maxSpeed;
  	vec3 loc = (nloc * 2.0 - 1.0) * worldResolution;

  	//physics happens here
  	loc += vel;

  	//check edge here

  	//encode data for next loop
  	loc /= worldResolution;
  	loc = loc * 0.5 + 0.5; //remap from -1, 1.0 to 0.0, 1.0
  	loc = clamp(loc, 0.0, 1.0);// clamp value (security only)

  	vec4 newPos = encodeRGBA24(loc.x) * isXYZ.x +
  				  encodeRGBA24(loc.y) * isXYZ.y +
  				  encodeRGBA24(loc.z) * isXYZ.z;

	fragColor = newPos;
}