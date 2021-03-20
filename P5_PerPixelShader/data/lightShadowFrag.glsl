/*
  Porcessing pixel shader by bonjour-lab
  www.bonjour-lab.com
*/
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform bool textureMode;

//constant
const float zero_float = 0.0;
const float one_float = 1.0;
const vec3 zero_vec3 = vec3(0.0);
const vec3 minus_one_vec3 = vec3(0.0-1.0);

//Light component (max 8)
uniform int lightCount;
uniform vec4 lightPosition[8];
uniform vec3 lightNormal[8];
uniform vec3 lightAmbient[8];
uniform vec3 lightDiffuse[8];
uniform vec3 lightSpecular[8];
uniform vec3 lightFalloff[8];
uniform vec2 lightSpot[8];

//Shadow component
uniform mat4 shadowTransform; 
uniform vec3 lightDirection;
uniform sampler2D shadowMap;
uniform float shadowInc = 1.0;
const vec2 poissonDisk[9] = vec2[] (
vec2(0.95581, -0.18159), vec2(0.50147, -0.35807), vec2(0.69607, 0.35559),
vec2(-0.0036825, -0.59150), vec2(0.15930, 0.089750), vec2(-0.65031, 0.058189),
vec2(0.11915, 0.78449), vec2(-0.34296, 0.51575), vec2(-0.60380, -0.41527) 
);



uniform sampler2D texture;
uniform vec2 texOffset;

in vec4 vertColor;
in vec4 backVertColor;
in vec4 vertTexCoord;
in vec3 ecNormal;
in vec4 ecVertex;

//Material attribute
in vec4 vambient;
in vec4 vspecular;
in vec4 vemissive;
in float vshininess;


out vec4 fragColor;


    // Unpack the 16bit depth float from the first two 8bit channels of the rgba vector
float unpackDepth(vec4 color) { 
 return color.r + color.g / 255.0; 
} 

float fallOffFactor(vec3 lightPos, vec3 ecVertex, vec3 coeff){
  vec3 lpv = lightPos - ecVertex;
  vec3 dist = vec3(one_float);
  dist.z = dot(lpv, lpv);
  dist.y = sqrt(dist.z);
  return one_float / dot(dist, coeff);
}

float spotFactor(vec3 lightPos, vec3 ecVertex, vec3 lightNormal, float minCos, float spotExp){
  vec3 lpv = normalize(lightPos - ecVertex);
  vec3 nln = minus_one_vec3 * lightNormal;
  float spotCos = dot(nln, lpv);
  return spotCos <= minCos ? zero_float : pow(spotCos, spotExp);

}

float diffuseFactor(vec3 lightDir, vec3 ecNormal){
  vec3 s = normalize(lightDir);
  vec3 n = normalize(ecNormal);
  return max(0.0, dot(s, n));
}

float specularFactor(vec3 lightDir, vec3 ecVertex, vec3 ecNormal, float shininess){
  vec3 s = normalize(lightDir);
  vec3 n = normalize(ecNormal);
  vec3 v = normalize(-ecVertex);
  vec3 r = reflect(-s, n);
  return pow(max(dot(r, v), 0.0), shininess);
}

/*-------------------- SHADOW MAPPING COMPUTATION ---------------------------*/
vec4 shadowCoord(vec4 ecVertex, vec3 ecNormal){
  vec4 sc = shadowTransform * (ecVertex + vec4(ecNormal, 0.0));
  return sc;
}

vec3 shadowCoordProj(vec4 ecVertex, vec3 ecNormal){
  vec4 sc = shadowCoord(ecVertex, ecNormal);
  return vec3(sc.xyz / sc.w);
}

float lightIntensity(vec3 lightDir, vec3 ecNormal){
  return 0.5 + dot(lightDir, ecNormal) * 0.5;
}

vec4 shadow(vec4 ecVertex, vec3 ecNormal, float shadowInc){
  float shadowRatio = 1.0;
  vec3 shadowCoordProjected = shadowCoordProj(ecVertex, ecNormal);
  float lightInt = lightIntensity(lightDirection, ecNormal);
  if(lightInt > 0.35){
    float visibility = poissonDisk.length();
    for(int n=0; n<poissonDisk.length(); n++){
      int index = n;
      int mod1 = 12;
      //index = int(float(mod1) * random(gl_FragCoord.xyy, n)) % mod1;
      visibility += step(shadowCoordProjected.z, unpackDepth(texture(shadowMap, shadowCoordProjected.xy + poissonDisk[index] / 1024))); 
    }
    shadowRatio = min(visibility * 0.0556, lightInt);
  }else{
    shadowRatio = lightInt;
  }
  shadowRatio = pow(shadowRatio, shadowInc);

  return vec4(vec3(shadowRatio), 1.0);
}

float shadowFactor(vec4 ecVertex, vec3 ecNormal, float shadowInc){
  float shadowRatio = 1.0;
  vec3 shadowCoordProjected = shadowCoordProj(ecVertex, ecNormal);
  float lightInt = lightIntensity(lightDirection, ecNormal);
  if(lightInt > 0.35){
    float visibility = poissonDisk.length();
    for(int n=0; n<poissonDisk.length(); n++){
      int index = n;
      int mod1 = 16;
      //index = int(float(mod1) * random(gl_FragCoord.xyy, n)) % mod1;
      visibility += step(shadowCoordProjected.z, unpackDepth(texture(shadowMap, shadowCoordProjected.xy + poissonDisk[index] / 1024))); 
    }
    shadowRatio = min(visibility * .0556, lightInt); //0.0556
  }else{
    shadowRatio = lightInt;
  }
  shadowRatio = pow(shadowRatio, shadowInc);

  return shadowRatio;
}


void main() {
  //PREPROCESSOR TEST FOR TEXTURE TEST → Check if P5 can write a define
  vec4 texColor = vec4(1.0);
  if(textureMode){
    texColor = texture(texture, vertTexCoord.st);
  }



  //Light computation
  vec3 totalAmbient = vec3(1.0);
  vec3 totalFrontDiffuse = vec3(0.0);
  vec3 totalBackDiffuse = vec3(0.0);
  vec3 totalFrontSpecular = vec3(0.0);
  vec3 totalBackSpecular = vec3(0.0);

  for(int i=0; i<8; i++){
    if(i == lightCount) break;
    vec3 lightPos = lightPosition[i].xyz;
    bool isDir = lightPosition[i].w < one_float;
    float spotCos = lightSpot[i].x;
    float spotExp = lightSpot[i].y;

    vec3 lightDir;
    float fallOff;
    float spotf;

    if(isDir){
      fallOff = one_float;
      lightDir = minus_one_vec3 * lightNormal[i];
    }else{
      fallOff = fallOffFactor(lightPos, ecVertex.xyz, lightFalloff[i]);
      lightDir = normalize(lightPos - ecVertex.xyz);
    }

    spotf = spotExp > zero_float ? spotFactor(lightPos, ecVertex.xyz, lightNormal[i], spotCos, spotExp) : one_float;
    
    //define Ambient
    if(any(greaterThan(lightAmbient[i], zero_vec3))){
      totalAmbient = lightAmbient[i] * fallOff;
      //totalAmbient += lightAmbient[i] * fallOff;
    }

    //Define Diffuse
    if(any(greaterThan(lightDiffuse[i], zero_vec3))){
      totalFrontDiffuse += lightDiffuse[i] * fallOff * spotf * diffuseFactor(lightDir, ecNormal);
      totalBackDiffuse += lightDiffuse[i] * fallOff * spotf * diffuseFactor(lightDir, ecNormal * minus_one_vec3);
    }
    
    //Define Specular
    if(any(greaterThan(lightSpecular[i], zero_vec3))){
      totalFrontSpecular += lightSpecular[i] * fallOff * spotf * specularFactor(lightDir, ecVertex.xyz, ecNormal, vshininess);
      totalBackSpecular += lightSpecular[i] * fallOff * spotf * specularFactor(lightDir, ecVertex.xyz, ecNormal * minus_one_vec3, vshininess);
    }
  }

  vec4 AlbedoFront = vec4(totalAmbient, 0.0) * vambient +
                     vec4(totalFrontDiffuse, 0.0) * vertColor +
                     vec4(totalFrontSpecular, 1.0) * vspecular +
                     vec4(vemissive.rgb, 0.0);

  vec4 AlbedoBack = vec4(totalAmbient, 0.0) * vambient +
                    vec4(totalBackDiffuse, 1.0) * vertColor +
                    vec4(totalBackSpecular, 0.0) * vspecular +
                    vec4(vemissive.rgb, 0.0);

  //shadow
 float shadowFactor = shadowFactor(ecVertex, ecNormal, shadowInc);
  float colorInc = 0.05;
 AlbedoFront = mix(vec4(vec3(0.0, 0.65, 1.00) * colorInc, 1.0), AlbedoFront, vec4(shadowFactor));
 // AlbedoBack = mix(vec4(vec3(0.0, 0.65, 1.00) * colorInc, 1.0), AlbedoBack, vec4(shadowFactor));



  fragColor = texColor * (gl_FrontFacing ? AlbedoFront : AlbedoBack);
}