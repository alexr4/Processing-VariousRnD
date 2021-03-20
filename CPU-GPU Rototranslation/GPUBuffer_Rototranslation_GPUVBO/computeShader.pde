String[] computeVertSource = { 
  "#version 410", 
  "uniform mat4 transformMatrix;", 
  "uniform mat4 texMatrix;", 

  "in vec4 position;", 
  "in vec4 color;", 
  "in vec2 texCoord;", 

  "out vec4 vertColor;", 
  "out vec4 vertTexCoord;", 

  "void main() {", 
  "gl_Position = transformMatrix * position;", 

  "vertColor = color;", 
  "vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);", 
  "} "
};

String[] computeFragSource = { 
  "#version 410",
  "#ifdef GL_ES", 
  "precision highp float;", 
  "precision highp vec4;", 
  "precision highp vec3;", 
  "precision highp vec2;", 
  "precision highp int;", 
  "#endif", 

  //constants elements
  "const vec4 efactor = vec4(1.0, 255.0, 65025.0, 16581375.0);", 
  "const vec4 dfactor = vec4(1.0/1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0);", 
  "const float mask = 1.0/256.0;", 

  "uniform sampler2D texture;", 
  "uniform float dataMax = 8000.0;", 
  "uniform mat4 rotationMatrix = mat4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); ", 
  "uniform vec4 translationMatrix = vec4(0, 0, 0, 0); ", 
  "uniform vec4 intrinsicMatrix = vec4(1, 1, 1, 1); ", 
  "uniform vec2 resolution = vec2(512.0, 424.0);", 

  "in vec4 vertTexCoord;", 
  "in vec4 vertColor;", 

  "out vec4 fragColor;", 

  "float decodeRGBAMod(vec4 rgba, float edge) {", 
  "float divider = float(edge) / 256.0;", 
  "float index = round(rgba.b * divider);", 

  "return rgba.r * 255.0 + 255.0 * index;", 
  "}", 

  "vec4 encodeRGBA24(float v) {", 
  "vec3 rgb = v * efactor.rgb;", 
  "rgb.gb = fract(rgb.gb);", 
  "rgb.rg -= rgb.gb * mask;", 
  "return vec4(rgb, 1.0);", 
  "}", 

  "vec4 backProject(vec2 pixel, float depth) { ", 
  "float x = (pixel.x - intrinsicMatrix.x) * depth / intrinsicMatrix.z;", 
  "float y = (pixel.y - intrinsicMatrix.y) * depth / intrinsicMatrix.w;", 
  "return vec4(x, y, depth, 1.0);", 
  "}", 

  "vec4 computeNewPosition(vec4 pos, mat4 R, vec4 T) { ", 
  "return (R * pos) + T;", 
  "};", 

  "void main() {", 
  "vec2 uv = vertTexCoord.xy;", 

  //defin 3 rows
  "vec2 colrow =  vec2(1.0, 3.0);", 
  "vec2 nuv = uv * colrow;", 
  "vec2 fuv = fract(nuv);", 
  "vec2 iuv = floor(nuv);", 

  "float isX = 1.0 - step(1.0, iuv.y);", 
  "float isZ = step(2.0, iuv.y);", 
  "float isY = 1.0 - (isX + isZ);", 
  
   "vec4 rgba = texture2D(texture, fuv);", 

  //get the depth
  "float depth = decodeRGBAMod(rgba, dataMax);// / dataMax;", 
  
  //remap uv into right space
  "vec2 pixel = fuv * resolution;",
  "pixel.y *= (colrow.x / colrow.y);",
  //back project
  "vec4 backproj = backProject(pixel, depth);", 

  //rototranslate
  "vec4 position = computeNewPosition(backproj, rotationMatrix, translationMatrix);", 
  //normalize position
  "position.xyz = position.xyz / dataMax;", 
  //normalize position
  "position.xyz = position.xyz * 0.5 + 0.5;", 

  //encode data
  "vec4 encodedData = encodeRGBA24(position.x) * isX +", 
  "encodeRGBA24(position.y) * isY +", 
  "encodeRGBA24(position.z) * isZ;", 

  "fragColor = encodedData;",
  "}"
};
