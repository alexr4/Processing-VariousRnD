//Add smooth shadow support to ray marching from Inogo Quilez :
//see more on Inigo Quliez Website : https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution; // size of the preview
uniform vec2 u_mouse; // cursor in normalized coordinates [0, 1]
uniform float u_time; // clock in seconds

#define MAX_STEPS 100 //max iteration on the marching loop
#define MAX_STEPS_SHADOW 64 //max iteration on the marching loop for shadow
#define MAX_DIST 100. //maximum distance from camera
#define MAX_DIST_SHADOW 32.
#define SURFACE_DIST 0.01 // minimum distance for a Hit

//rotation
mat2 rotate2D(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s,
              s,  c);
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


float getDist(vec3 p){
  float planeDist = p.y; //get the distance from the ground

  //shapes
  vec3 np = p - vec3(0.0, 2.0, 0.0);

  //rotate and move
  vec3 bp = np;
  vec3 spA = np;
  vec3 spB = np;
  spA.x += sin(u_time * 2.0) * 2.5;
  spA.xy *= rotate2D(u_time);
  spA.x += 1.5;


  float sdA = sdSphere(spA, 1.25);
  float sdB = sdSphere(spB, 0.75);

  float sdAB = opSmoothUnite(sdA, sdB, 0.75);

  float d = opUnite(sdAB, planeDist);


  return d;
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
      if(dO > MAX_DIST_SHADOW || res < 0.0001) break; //hit
    }
    return clamp(res, 0.0, 1.0);
}


vec3 getNormal(vec3 p){
  float d = getDist(p); // gte the distance at point d
  vec2 e =  vec2(0.01, 0.0);//define an offset vector
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
  for(int i=0; i<5; i++){
    float h = 0.001 + 0.15 * float(i)/4.0;
    float d = getDist(p + h * n);
    occ += (h-d) * sca;
    sca += 0.95;
  }
  return clamp(1.0 - 1.5 * occ, 0.0, 1.0);
}

vec3 render(vec3 ro, vec3 rd){
  vec3 col = vec3(0.0);
  float d = rayMarch(ro, rd);
  if(d > -0.5){
    vec3 pos = ro + rd * d;
    vec3 nor = getNormal(pos);

    //material
    vec3 mat = vec3(0.3);

    //keyLight
    vec3 lightColor = vec3(1.0);
    vec3 lightPos = vec3(0.0, 4.0, 0.0);
    float lightRadius = 6.0;
    float lightSpeed = 1.0;
    lightPos.xz = vec2(cos(u_time * lightSpeed) * lightRadius, sin(u_time * lightSpeed) * lightRadius);

    vec3 lig = normalize(lightPos);
    vec3 hal = normalize(lig - rd);
    float diff = clamp(dot(nor, lig), 0.0, 1.0) *
                softShadowImproved(pos, lig, 10.0);


    float speItensity = 25.0;
    float speDiff = 100.0;
    float spe = pow( clamp( dot( nor, hal ), 0.0, 1.0 ), speDiff) *
                    diff * (0.04 + .96*pow( clamp(1.0+dot(hal,rd),0.0,1.0), 5.0 ));

    col = mat * 4.0 * diff * lightColor;
    col += speItensity * spe * lightColor;

    //ambient
    float occ = ambientOcclusion(pos, nor);
    float amb = clamp(0.5 + 0.5 * nor.y, 0.0, 1.0);
    col += mat * amb * occ * vec3(0.25);
    //fog
    col *= exp(-0.0005 * pow(d, 3.0));
  }
  return col;
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


void main(){
  vec2 uv =  (gl_FragCoord.xy-0.5 * u_resolution.x) / u_resolution.y;
  // The above line is a quicker way to set the uv origin at the center of the screen (like the line below)
  // vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  // uv -= 0.5;
  vec3 color = vec3(0);

  //vec3 ro = vec3(0.0, 5.0, -10.0); //camera position (Ray Origin)
  //vec3 rd = normalize(vec3(uv.x, uv.y - 0.35, 1.0)); //Ray Direction
  //complexe camera
  vec3 ro = vec3(0, 1, 5);
  // ro.yz *= rotate2D(-u_mouse.y+.4);
  // ro.xz *= rotate2D(u_time * 0.25 - u_mouse.x*6.14);
  vec3 rd = R(uv, ro, vec3(0,2,0), 0.65);

  //depth (only used for debug here)
  float d = rayMarch(ro, rd); //get the distance
  float far = 20.0;
  d /= far; //the distance return as an unnormalized distance so we divied by a far plane distance

  //rend with material
  color = render(ro, rd); //diffuse

  //color debug
   vec3 p = ro + rd * d;
   vec3 normal = getNormal(p); //debug normal

  //screen
  vec2 st = uv * 0.5 + 0.5;
  vec3 final = (st.x > 0.5) ? vec3(d) : color;
  gl_FragColor = vec4(final, 1.0);
}
