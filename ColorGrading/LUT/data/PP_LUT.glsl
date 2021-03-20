uniform vec2 resolution;
uniform sampler2D texture; //img/Lena.png
uniform sampler2D lut; //img/lookup_amatorka.png
uniform float clicked;

in vec4 vertTexCoord;
out vec4 fragColor;

float colsrows = 8;
float lutres = 512;

//based on Matt DesLauriers implementation → https://github.com/mattdesl/glsl-lut
vec4 lookup(in vec4 textureColor, in sampler2D lookupTable) {
    textureColor = clamp(textureColor, 0.0, 1.0 - 0.125); // this clamp is an hack to avoir over 1.0 in the red channel

    mediump float blueColor = textureColor.b * (colsrows * colsrows);

    mediump vec2 quad1;
    quad1.y = floor(floor(blueColor) / colsrows);
    quad1.x = floor(blueColor) - (quad1.y * colsrows);

    mediump vec2 quad2;
    quad2.y = floor(ceil(blueColor) / colsrows);
    quad2.x = ceil(blueColor) - (quad2.y * colsrows);

    highp vec2 texPos1;
    texPos1.x = (quad1.x * 0.125) + (0.5/lutres) + (0.125 - 1.0/lutres) * textureColor.r;
    texPos1.y = (quad1.y * 0.125) + (0.5/lutres) + (0.125 - 1.0/lutres) * textureColor.g;

    highp vec2 texPos2;
    texPos2.x = (quad2.x * 0.125) + (0.5/lutres) + (0.125 - 1.0/lutres) * textureColor.r;
    texPos2.y = (quad2.y * 0.125) + (0.5/lutres) + (0.125 - 1.0/lutres) * textureColor.g;

    lowp vec4 newColor1 = texture2D(lookupTable, texPos1);
    lowp vec4 newColor2 = texture2D(lookupTable, texPos2 + vec2(0.001, 0.0));

    lowp vec4 newColor = mix(newColor1, newColor2, fract(blueColor));
    return newColor;
}

vec4 lookupSimple(vec4 col, sampler2D lookupTable){
  vec2 tiles    = vec2(8.0, 8.0);
  vec2 tileSize = vec2(64.0);

  float index     = col.b * (tiles.x * tiles.y - 1.0);
  float index_min = min(62.0, floor(index));
  float index_max = index_min + 1.0;

  vec2 tileIndex_min;
  tileIndex_min.y = floor(index_min / tiles.x);
  tileIndex_min.x = floor(index_min - tileIndex_min.y * tiles.x);
  vec2 tileIndex_max;
  tileIndex_max.y = floor(index_max / tiles.x);
  tileIndex_max.x = floor(index_max - tileIndex_max.y * tiles.x);

  vec2 tileUV = mix(0.5/tileSize, (tileSize-0.5)/tileSize, col.rg);

  vec2 tableUV_1 = tileIndex_min / tiles + tileUV / tiles;
  vec2 tableUV_2 = tileIndex_max / tiles + tileUV / tiles;

  vec4 lookUpColor_1 = texture(lookupTable, tableUV_1);
  vec4 lookUpColor_2 = texture(lookupTable, tableUV_2);
  return mix(lookUpColor_1, lookUpColor_2, index-index_min); 
}

void main(){
  //compute the normalize screen coordinate
  vec2 uv = gl_FragCoord.xy/resolution.xy;

  vec4 rgba = texture2D(texture, vertTexCoord.xy);
  vec4 final = lookupSimple(rgba, lut);

  vec3 debug = vec3(rgba) * clicked + vec3(final) * (1.0 - clicked);
  //draw everything
  fragColor = vec4(debug, 1.0);
}
