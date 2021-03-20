//Add smooth shadow support to ray marching from Inogo Quilez :
//see more on Inigo Quliez Website : https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
#ifdef GL_ES
#extension GL_OES_standard_derivatives : enable
precision highp float;
#endif
#define PI 3.1415926535897932384

uniform vec2 u_resolution; // size of the preview
uniform vec2 u_mouse; // cursor in normalized coordinates [0, 1]
uniform float u_time; // clock in seconds
uniform sampler2D albedo; //texturesModel/Terrazzo07_col.jpg
uniform sampler2D specMap; //texturesModel/Terrazzo07_rgh.jpg
uniform sampler2D norMap; //texturesModel/Terrazzo07_nrm.jpg
#define GAMMA 2.2

#define MAX_STEPS 32 //max iteration on the marching loop
#define MAX_STEPS_SHADOW 16 //max iteration on the marching loop for shadow
#define MAX_DIST 50. //maximum distance from camera
#define MAX_DIST_SHADOW 50.
#define SURFACE_DIST 0.001 // minimum distance for a Hit

//rotation
mat2 rotate2D(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s,
              s,  c);
}

float random(float x){
  return fract(sin(x) * 43758.5453123);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*43758.5453123);
}

//noise algorithme from Morgan McGuire
//https://www.shadertoy.com/view/4dS3Wd
float noise(vec2 st){
  vec2 ist = floor(st);
  vec2 fst = fract(st);

  //get 4 corners of the pixel
  float bl = random(ist);
  float br = random(ist + vec2(1.0, 0.0));
  float tl = random(ist + vec2(0.0, 1.0));
  float tr = random(ist + vec2(1.0, 1.0));

  //smooth interpolation using cubic function
  vec2 si = fst * fst * (3.0 - 2.0 * fst);

  //mix the four corner to get a noise value
  return mix(bl, br, si.x) +
         (tl - bl) * si.y * (1.0 - si.x) +
         (tr - br) * si.x * si.y;
}

//smooth min/max
float smin(float a, float b, float k){
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float smax(float a, float b, float k){
  float h = clamp(0.5 - 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) + k * h * (1.0 - h);
}

//simple shapes
float sdSphere(vec3 p, float r){
  return length(p) - r;
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r){
  vec3 ab = b-a;
  vec3 ap = p-a;

  float t = dot(ab, ap) / dot(ab, ab); //project ray on the line between the two sphere of teh capsule to get the distance
  t = clamp(t, 0.0, 1.0);

  vec3 c = a + t * ab; // get the ray a to the ab
  return length(p-c) - r; // get the distance between p and the c
}

float sdTorus(vec3 p, vec2 r){
  float x = length(p.xz) - r.x;
  return length(vec2(x, p.y)) - r.y;
}

float sdBox(vec3 p, vec3 s){
  vec3 d = abs(p) -s;

  return length(max(d, 0.0)) +
          min(max(d.x, max(d.y, d.z)), 0.0); //remove this line for an only partially signed sdf
}

float sdCylinder(vec3 p, vec3 a, vec3 b, float r){
  vec3 ab = b-a;
  vec3 ap = p-a;

  float t = dot(ab, ap) / dot(ab, ab); //project ray on the line between the two sphere of teh capsule to get the distance
  //t = clamp(t, 0.0, 1.0);

  vec3 c = a + t * ab; // get the ray a to the ab

  float x = length(p-c) - r; // get the distance between p and the c
  float y = (abs(t - 0.5) - 0.5) * length(ab);
  float e = length(max(vec2(x, y), 0.0));
  float i = min(max(x, y), 0.0);
  return e + i;
}

float dot2( in vec2 v ) { return dot(v,v);}
float sdCone(vec3 p, float h, float r1, float r2){
    vec2 q = vec2( length(p.xz), p.y );

    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y < 0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return s*sqrt( min(dot2(ca),dot2(cb)) );
}

//operations
float opUnite(float d1, float d2){
  return min(d1, d2);
}

float opSubstract(float d1, float d2){
  return max(-d1, d2);
}

float opIntersect(float d1, float d2){
  return max(d1, d2);
}

float opMorph(float d1, float d2, float offset){
  return mix(d1, d2, offset);
}

float opSmoothUnite(float d1, float d2, float k){
  return smin(d1, d2, k);
}

float opSmoothSubstract(float d1, float d2, float k){
  return smax(-d1, d2, k);
}

float opSmoothIntersect(float d1, float d2, float k){
  return smax(d1, d2, k);
}

vec3 opRepeat(vec3 p, vec3 freqXYZ){
  return (mod(p, freqXYZ) - 0.5 * freqXYZ);
}


//displacement
vec2 displacePattern(vec3 p, vec3 freqXYZ){
  return vec2(sin(freqXYZ.x * p.x) * sin(freqXYZ.y * p.y) * sin(freqXYZ.z * p.z),
              max(max(freqXYZ.x, freqXYZ.y), freqXYZ.z));
}

vec3 deform(vec3 p, vec3 freqXYZ, float inc)
{
  //1.0, 0.5, 0.25
    p.xyz += (freqXYZ.x * sin(2.0 * p.zxy)) * inc;
    p.xyz += (freqXYZ.y * sin(4.0 * p.zxy)) * inc;
    p.xyz += (freqXYZ.z * sin(8.0 * p.zxy)) * inc;
    return p;
}

vec3 opTwist(vec3 p, float k){
  float c = cos(k*p.y);
  float s = sin(k*p.y);
  mat2  m = mat2(c,-s,s,c);
  return vec3(m*p.xz,p.y);
}

vec3 rotation(vec3 point, vec3 axis, float angle){
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    mat4 rot= mat4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,0.0,0.0,1.0);
    return (rot*vec4(point,1.)).xyz;
}


float getDist(vec3 p){
  float planeDist = p.y; //get the distance from the ground

  //shapes
  vec3 np = p - vec3(0.0, 0.0, 0.0);
  // np = rotation(p, vec3(0.0, 1.0, 0.0), u_time);
  float box = sdBox(np, vec3(1.75));
  float npy = (p.y / 2.5) * 0.5 + 0.5;
  float rndOffset = random(floor(u_time + 10.0)) * 0.25 + 0.25;
  float noised = noise(vec2(npy * 10.0 + floor(u_time)));
  npy = np.y + noised * rndOffset;//sin(npy * PI * 8.0 + u_time * 2.0) * 0.25;
  np.y = npy;
  p = np;

  float rndSize  = random(floor(u_time + 20.0)) * 0.5 + 2.0;
  float rndSize2 = random(floor(u_time + 30.0)) + 0.5;
  float rndSize3 = random(floor(u_time + 40.0)) * 0.75 + 0.25;
  float rndSize4 = random(floor(u_time + 50.0)) * 0.25 + 0.25;
  float rndSmooth = random(floor(u_time + 60.0)) * 0.75;
  float rndPos = (random(floor(u_time + 70.0)) * 2.0 - 1.0) * 0.5;

  float sphere = sdSphere(p + vec3(0, rndPos, 0), rndSize);
  float cyd = sdCylinder(p, vec3(0.00, 2.8, 0.), vec3(0.0, 0, 0), rndSize2);
  float cydInner = sdCylinder(p, vec3(0.00, 3.0, 0.), vec3(0.0, 0, 0), rndSize2 - 0.2);
  float cone = sdCone(p + vec3(0, 2.5, 0), 0.25, rndSize3 + rndSize4, rndSize3);

  float d = opSmoothUnite(sphere, cone, rndSmooth);
  d = opSmoothUnite(d, cone, rndSmooth);
  d = opSmoothUnite(d, cyd, rndSmooth);
  d = opSmoothUnite(d, cyd, rndSmooth);
  d = opSmoothSubstract(cydInner, d, 0.15);

  return d;// * (0.065);
}

float rayMarch(vec3 ro, vec3 rd){
  float dO = 0.0; //distance to origin
  for(int i=0; i<MAX_STEPS; i++){
    vec3 p = ro + rd * dO; //current marching location on the ray
    float dS = getDist(p); // distance to the scene
    if(dO > MAX_DIST || dS < SURFACE_DIST) break; //hit
    dO += dS;
  }
  return dO;
}

float perfMarch(vec3 ro, vec3 rd){
  float dO = 0.0; //distance to origin
  vec3 minSample = vec3(1.0, 0.0, 0.0);
  vec3 maxSample = vec3(0.0, 0.0, 1.0);
  for(int i=0; i<MAX_STEPS; i++){
    vec3 p = ro + rd * dO; //current marching location on the ray
    float dS = getDist(p); // distance to the scene
    if(dO > MAX_DIST || dS < SURFACE_DIST){
      return float(i)/float(MAX_STEPS); // return the the step / max which is the number of iteration between 0 (0) and 1 (MAX_STEPS)
    }; //hit
    dO += dS;
  }
}


float softShadow(vec3 ro, vec3 rd, float k)
{
    float res = 1.0;
    float ph = 1e20;
    float dO = 0.0; //distance to origin
    for(int i=0; i<MAX_STEPS_SHADOW; i++){
      vec3 p = ro + rd * dO; //current marching location on the ray
      float dS = getDist(p); // distance to the scene
      res = min(res, 10.0 * dS/dO);
      dO += dS;
      if(dO > MAX_DIST_SHADOW || res < 0.0001) break; //hit
    }
    return clamp(res, 0.0, 1.0);
}

float softShadowImproved(vec3 ro, vec3 rd, float k)
{
    float res = 1.0;
    float ph = 1e20;
    float dO = 0.0; //distance to origin
    for(int i=0; i<MAX_STEPS_SHADOW; i++){
      vec3 p = ro + rd * dO; //current marching location on the ray
      float dS = getDist(p); // distance to the scene
      float y = dS*dS/(2.0*ph);
        float d = sqrt(dS*dS-y*y);
        res = min(res, k*d/max(0.0,dO-y));
        ph = dS;
        dO += dS;
      if(dO > MAX_DIST_SHADOW || res < 0.001) break; //hit
    }
    return clamp(res, 0.0, 1.0);
}


vec3 getNormal(vec3 p){
  float d = getDist(p); // gte the distance at point d
  vec2 e =  vec2(0.25, 0.0);//define an offset vector
  vec3 n = d - vec3(
    getDist(p - e.xyy), //get dist offset on X
    getDist(p - e.yxy), //get dist offset en Y
    getDist(p - e.yyx) // get dist offset on Z
    ); // get the vector next to the point as the normal

  return normalize(n);
}

float ambientOcclusion(vec3 p, vec3 n){
  float occ = 0.0;
  float sca = 1.0;
  #define OCCSTEP 5
  for(int i=0; i<OCCSTEP; i++){
    float h = 0.001 + 0.15 * float(i)/4.0;
    float d = getDist(p + h * n);
    occ += (h-d) * sca;
    sca += 0.95;
  }
  occ /= float(OCCSTEP);
  return clamp(1.0 - 1.5 * occ, 0.0, 1.0);
}
// --------------------------------------------------------
// IQ
// https://www.shadertoy.com/view/ll2GD3
// --------------------------------------------------------

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d));
}

vec3 spectrum(float n) {
       // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
     return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.10,0.20));
     // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,0.7,0.4),vec3(0.0,0.15,0.20));
     // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25));
}

// http://www.thetenthplanet.de/archives/1180
mat3 cotangent_frame(vec3 N, vec3 p, vec2 uv)
{
    // récupère les vecteurs du triangle composant le pixel
    vec3 dp1 = dFdx( p );
    vec3 dp2 = dFdy( p );
    vec2 duv1 = dFdx( uv );
    vec2 duv2 = dFdy( uv );

    // résout le système linéaire
    vec3 dp2perp = cross( dp2, N );
    vec3 dp1perp = cross( N, dp1 );
    vec3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    vec3 B = dp2perp * duv1.y + dp1perp * duv2.y;

    // construit une trame invariante à l'échelle
    float invmax = inversesqrt( max( dot(T,T), dot(B,B) ) );
    return mat3( T * invmax, B * invmax, N );
}

vec3 perturb_normal( vec3 N, vec3 V, vec2 texcoord, sampler2D normalMap)
{
    // N, la normale interpolée et
    // V, le vecteur vue (vertex dirigé vers l'œil)
    vec3 map = texture2D(normalMap, texcoord).xyz;
    map = map * 255./127. - 128./127.;
    mat3 TBN = cotangent_frame(N, -V, texcoord);
    return normalize(TBN * map);
}

vec3 triplanarMap(vec3 surfacePos, vec3 normal, sampler2D texture)
{
    // Take projections along 3 axes, sample texture values from each projection, and stack into a matrix
    mat3 triMapSamples = mat3(
        texture2D(texture, surfacePos.yz).rgb,
        texture2D(texture, surfacePos.xz).rgb,
        texture2D(texture, surfacePos.xy).rgb
        );

    // Weight three samples by absolute value of normal components
    return triMapSamples * abs(normal);
}

vec3 render(vec3 ro, vec3 rd){
  vec3 col = vec3(0.0);
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float centerDist = length(vec2(0.5) - uv);
  centerDist = pow(centerDist, 2.0);
  float rad = 0.15;
  float thick = 0.25;
  centerDist = smoothstep(rad - thick * 0.5, rad + thick * 0.5, centerDist);

  vec3 bg = vec3(0.0) / 255.0;

  float d = rayMarch(ro, rd);
  if(d > 0.0){
    vec3 pos = ro + rd * d;
    vec3 nor = getNormal(pos);
    vec3 eye = normalize(ro);
    vec3 view = normalize(-rd);


    //keyLight
    vec3 lightColor = vec3(1.0);
    vec3 lightPos = vec3(0, 100.0 * -0.75, 0.0);
    float lightRadius = 100.0;
    float lightSpeed = 1.0;

    lightPos.xz = vec2(cos(u_time * lightSpeed) * lightRadius, sin(u_time * lightSpeed) * lightRadius);


    //material
    vec3 mat = vec3(127.0) / 255.0;

    //texture projections
    float textureFreq = 0.15;
    // vec3 p = rotation(pos, vec3(0.0, 1.0, 0.0), u_time * 0.5);
    vec2 uv = textureFreq * (pos.xy + 3.5);
    uv.x = 1.0 - uv.x;

    //normal
    vec3 normalval = mix(nor, perturb_normal(nor, normalize(view), uv, norMap), 0.25);

    vec3 surfaceCol = texture2D(albedo, uv).xyz;
    vec3 specval = texture2D(specMap, uv).xyz;

    //triplanar texture projection
     //surfaceCol = triplanarMap((pos.xyz + vec3(2.5, 2.5, 2.5)) * textureFreq, normalval, albedo);

    // sample texture
    mat = surfaceCol;


    //iridescence from : https://www.shadertoy.com/view/llcXWM

    vec3 lig = normalize(lightPos);
    vec3 hal = normalize(lig - rd);
    float diff = clamp(dot(normalval, lig), 0.0, 1.0) *
                    softShadowImproved(pos, lig, 40.0);
                    // softShadow(pos, lig, 10.0);


    float NdotHL = clamp(dot(normalval, hal), 0., 1.);
    float HLdotRD = clamp(1.0+dot(hal, rd),0.0,1.0);
    float speItensity = 100.0;
    float speDiff = 100.0;//1000.0 * u_mouse.y;
    float specular = pow(NdotHL, speDiff) *
                   diff * (0.04 + .96*pow(HLdotRD, 5.0));



    float rimPower = 0.05;
    float rim = 1.0 - max(dot(view, normalval), 0.0);
    rim = smoothstep(0.5, 2.0, rim);

    col += mat * diff * lightColor + rim * rimPower * mat * lightColor;
    col += (mat * speItensity * specular * lightColor) * specval;


    //ambient
    float occ = ambientOcclusion(pos, normalval);
    float amb = clamp(0.5 + 0.5 * normalval.y, 0.0, 1.0);
    // col += mat * amb * occ * vec3(0.025);
    col += (mat * amb) * 0.0025;
    col *= mat * occ * 1.0;

    //fog exp
    // col *= exp(-0.0005 * pow(d, 2.5));
    //fog of war
    float middle = 10.0;
    float far = middle + 10.0;
    float near =  middle - 10.5;
    float fog = (d-near) / (far - near);
    fog = clamp(fog, 0., 1.);
    col = mix(col, bg, fog);
  }
  return clamp(col, vec3(0.0), vec3(1.0));
}


//this function return the ray direction from a non aligned axis camera
vec3 R(vec2 uv, vec3 p, vec3 o, float z) {
    vec3 f = normalize(o-p),
        r = normalize(cross(vec3(0,1,0), f)),
        u = cross(f,r),
        c = p+f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i-p);
    return d;
}

vec4 addGrain(vec2 uv, float time, float grainIntensity){
		float grain = random(fract(uv * time)) * grainIntensity;
		return vec4(vec3(grain), 1.0);
}

vec3 toLinear(vec3 rgb){
  return pow(rgb, vec3(GAMMA));
}

vec4 toLinear(vec4 rgba){
  return vec4(toLinear(rgba.rgb), rgba.a);
}

vec3 toGamma(vec3 rgb){
  return pow(rgb, vec3(1.0/GAMMA));
}

vec4 toGamma(vec4 rgba){
  return vec4(toGamma(rgba.rgb), rgba.a);
}

void main(){
  vec2 uv =  (gl_FragCoord.xy-0.5 * u_resolution.x) / u_resolution.y;
  vec2 ouv =  gl_FragCoord.xy / u_resolution;
  // The above line is a quicker way to set the uv origin at the center of the screen (like the line below)
  // vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  // uv -= 0.5;
  vec3 color = vec3(0);

  //vec3 ro = vec3(0.0, 5.0, -10.0); //camera position (Ray Origin)
  //vec3 rd = normalize(vec3(uv.x, uv.y - 0.35, 1.0)); //Ray Direction
  //complexe camera
  vec3 ro = vec3(0, 3.5, 6.0);
  // ro.yz *= rotate2D(-u_mouse.y * PI);
  // ro.xz *= rotate2D(u_mouse.x * PI * 10.0);
 // ro.y = (u_mouse.y * 2.0) * 10.0;
  vec3 rd = R(uv, ro, vec3(0,0,0), 0.65);

  // // depth (only used for debug here)
  // float d = rayMarch(ro, rd); //get the distance
  // float far = 20.0;
  // vec3 depth = vec3(d / far); //the distance return as an unnormalized distance so we divied by a far plane distance
  //
  // //color debug
  //  vec3 p = ro + rd * d;
  //  vec3 normal = getNormal(p) * (1.0 - step(MAX_DIST, d)); //debug normal

  //performance debug
  // vec3 perf = vec3(perfMarch(ro, rd));

  //rend with material
  color = render(ro, rd); //diffuse
  color.rgb = pow(color.rgb, vec3(0.4545));

  //screen
  gl_FragColor = vec4(color, 1.0);
}
