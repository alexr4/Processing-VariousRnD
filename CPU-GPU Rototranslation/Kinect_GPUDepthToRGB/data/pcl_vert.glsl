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

//uniforms binded data
uniform sampler2D datas;
uniform mat4 rotationMatrix = mat4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
uniform vec4 translationMatrix = vec4(0, 0, 0, 0);
uniform vec4 intrinsicMatrixDepth = vec4(1, 1, 1, 1);
uniform vec4 intrinsicMatrixRGB = vec4(1, 1, 1, 1);
uniform int dataMax = 8000;
uniform vec2 mouse;

in vec4 position;
in vec4 color;
in vec2 offset;

out vec4 vertColor;

int decodeRGBAMod(vec4 rgba, float edge){
  float divider = (float(edge) / 256.0);
  int index = int(round(rgba.b * divider));
  return int(rgba.r * 255) + index * 255;
}

vec4 backProject(vec2 pixel, float depth){
  float x = (pixel.x - intrinsicMatrixDepth.x) * depth / intrinsicMatrixDepth.z;
  float y = (pixel.y - intrinsicMatrixDepth.y) * depth / intrinsicMatrixDepth.w;
  return vec4(x, y, depth, 1.0);
}

vec2 project(vec4 voxel){
  float x = (voxel.x * intrinsicMatrixRGB.z / voxel.z) + intrinsicMatrixRGB.x;
  float y = (voxel.y * intrinsicMatrixRGB.w / voxel.z) + intrinsicMatrixRGB.y;
  return vec2(x, y);
}


vec4 computeNewPosition(vec4 pos, mat4 R, vec4 T){
  return (R * pos) + T;
}

float inCirc(float time){ 
    time /= 1.0;
    return clamp(-1.0 * (sqrt(1.0 - time * time) - 1.0), 0.0, 1.0);
}

float outCirc(float time){ 
    time /= 1.0;
    time --;
    return clamp(1.0 * sqrt(1 - time * time), 0, 1);
  }

void main() {
  //used the position to store us on texture 
  vec4 vertdata = texture(datas, position.xy).rgba;
  vec2 pos2D    = position.xy * vec2(512.0, 424.0);

 //compute position here
  float depth = float(decodeRGBAMod(vertdata, float(dataMax)));// / dataMax;
  float colorDepth = 1.0 - smoothstep(50, 8000, depth);
  depth /= 1000;
  vec4 backproj = backProject(pos2D.xy, float(depth));
  vec4 pos3D = computeNewPosition(backproj, rotationMatrix, translationMatrix);
  vec4 pos2DRGB = vec4(project(pos3D), 0.01, 1);

  vec4 clip = projectionMatrix * modelviewMatrix * pos3D;
  
  // float scale = outCirc(colorDepth);
  gl_Position = clip + projectionMatrix * vec4(offset.xy * (4.0 * colorDepth), 0, 0);

  vec3 color = vec3(colorDepth);
  vertColor = vec4(1.0);
}