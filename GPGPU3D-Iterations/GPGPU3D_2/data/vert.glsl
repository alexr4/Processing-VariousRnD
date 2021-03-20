/*
 Porcessing pixel shader by bonjour-lab
  www.bonjour-lab.com
*/
#version 150
#ifdef GL_ES
precision highp float;
precision highp vec4;
precision highp vec3;
precision highp vec2;
precision highp int;
#endif

uniform mat4 projectionMatrix;
uniform mat4 modelviewMatrix;
uniform mat4 texMatrix;

uniform vec4 viewport;
uniform int perspective; 

//constants elements
const vec4 efactor = vec4(1.0, 255.0, 65025.0, 16581375.0);
const vec4 dfactor = vec4(1.0/1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0);
const float mask = 1.0/256.0;

//uniforms binded data
uniform sampler2D posImage;
uniform vec2 textureResolution;
uniform vec2 edgeX;
uniform vec2 edgeY;
uniform vec2 edgeZ;
uniform vec4 state;

in vec4 position;
in vec4 uv;
in vec4 color;
in vec2 offset;

out vec4 vertColor;

struct UV3D{
	vec2 uvx;
	vec2 uvy;
	vec2 uvz;
};

vec4 encodeRGBA32(float v){
  vec4 rgba = v * efactor.rgba;
  rgba.gba = fract(rgba.gba);
  rgba.rgb -= rgba.gba * mask;
  return rgba;
}

vec4 encodeRGBA24(float v){
  vec3 rgb = v * efactor.rgb;
  rgb.gb = fract(rgb.gb);
  rgb.rg -= rgb.gb * mask;
  return vec4(rgb, 1.0);
}

float decodeRGBA32(vec4 rgba){
  return dot(rgba, dfactor.rgba);
}

float decodeRGBA24(vec3 rgb){
  return dot(rgb, dfactor.rgb);
}



UV3D getUVFrom(vec2 position, vec2 textureResolution){
  vec2 texel = vec2(1.0) / textureResolution;
  vec2 texPosition = position.xy * textureResolution;

  // ivec2 iTextureResolution = ivec2(textureResolution);
  // ivec2 iTexPosition = ivec2(position.xy * iTextureResolution);
  
  float i0 = round(texPosition.x + texPosition.y * textureResolution.x);
  float i1 = (i0 + 1.0);
  float i2 = (i0 + 2.0);
  
  float ux = round(mod(i0, textureResolution.x));
  float vx = round((i0 - ux) / textureResolution.x);

  float uy = round(mod(i1, textureResolution.x));
  float vy = round((i1 - uy) / textureResolution.x);

  float uz = round(mod(i2, textureResolution.x));
  float vz = round((i2 - uz) / textureResolution.x);

  vec2 uvx = vec2(ux, vx) / (textureResolution - vec2(1.0));
  vec2 uvy = vec2(uy, vy) / (textureResolution - vec2(1.0));
  vec2 uvz = vec2(uz, vz) / (textureResolution - vec2(1.0));

  UV3D uv3d = UV3D(
        uvx,
        uvy,
        uvz
  );

  return uv3d;
}

void main() {
  vec4 rgba = texture(posImage, position.xy);

  //used the position to store us on texture 
  UV3D uv3d = getUVFrom(position.xy, textureResolution);

  vec3 rgbaX = texture(posImage, uv3d.uvx).rgb;
  vec3 rgbaY = texture(posImage, uv3d.uvy).rgb;
  vec3 rgbaZ = texture(posImage, uv3d.uvz).rgb;

  float nx = decodeRGBA24(rgbaX);
  float ny = decodeRGBA24(rgbaY);
  float nz = decodeRGBA24(rgbaZ);

  float x = mix(edgeX.x, edgeX.y, nx);
  float y = mix(edgeY.x, edgeY.y, ny);
  float z = mix(edgeZ.x, edgeZ.y, nz);

  vec4 vpos = vec4(x, y, z, 1.0);

  vec4 clip = projectionMatrix * modelviewMatrix * mix(position * vec4(textureResolution, 1.0, 1.0), vpos, vec4(state));

  // Perspective ---
  // convert from world to clip by multiplying with projection scaling factor
  // invert Y, projections in Processing invert Y
  vec2 perspScale = (projectionMatrix * vec4(1, -1, 0, 0)).xy;

  // formula to convert from clip space (range -1..1) to screen space (range 0..[width or height])
  // screen_p = (p.xy/p.w + <1,1>) * 0.5 * viewport.zw

  // No Perspective ---
  // multiply by W (to cancel out division by W later in the pipeline) and
  // convert from screen to clip (derived from clip to screen above)
  vec2 noPerspScale = clip.w / (0.5 * viewport.zw);

  gl_Position.xy = clip.xy + offset.xy * mix(noPerspScale, perspScale, float(perspective > 0));
  gl_Position.zw = clip.zw;  

  
  vertColor = vec4(nx, ny, nz, 1.0);
}