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
uniform sampler2D textureX;
uniform sampler2D textureY;
uniform sampler2D textureZ;
uniform vec2 edgeX;
uniform vec2 edgeY;
uniform vec2 edgeZ;
uniform vec4 state;

in vec4 position;
in vec4 color;
in vec2 offset;

out vec4 vertColor;

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

void main() {
  //used the position to store us on texture 
  vec4 rgbaX = texture(textureX, position.xy).rgba;
  vec4 rgbaY = texture(textureY, position.xy).rgba;
  vec4 rgbaZ = texture(textureZ, position.xy).rgba;

  float nx = decodeRGBA32(rgbaX);
  float ny = decodeRGBA32(rgbaY);
  float nz = decodeRGBA32(rgbaZ);

  float x = mix(edgeX.x, edgeX.y, nx);
  float y = mix(edgeY.x, edgeY.y, ny);
  float z = mix(edgeZ.x, edgeZ.y, nz);

  vec4 vpos = vec4(x, y, z, 1.0);

  vec4 clip = projectionMatrix * modelviewMatrix * mix(position, vpos, vec4(state));

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