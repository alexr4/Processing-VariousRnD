//Tutorial from The Art of Code: https://www.shadertoy.com/view/3ssGWj
//see more on Inigo Quliez Website : https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution; // size of the preview
uniform vec2 u_mouse; // cursor in normalized coordinates [0, 1]
uniform float u_time; // clock in seconds

#define MAX_STEPS 100 //max iteration on the marching loop
#define MAX_DIST 1000. //maximum distance from camera
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
  vec3 c = vec3(10.0, 10.0, 10.0);

  //rotate and move
  vec3 bp = np + vec3(0, -2, 0);
   bp.xz *= rotate2D(u_time * 0.1);
   bp.yz *= rotate2D(u_time * 0.1);
  //bp = opRepeat(bp, c); //seams to be a buggy on the distance field
  // vec2 dbp = displacePattern(bp, vec3(abs(sin(u_time) * 4.0) * 0.5 + 0.5));
  //bp = opTwist(bp, 0.5);
//  bp -= vec3(2.0, 2.0, 1.0);
  //float bd = sdBox(bp, vec3(1.5));
  float bd = sdBox(bp, vec3(1.0));// + dbp.x;
  // bd /= dbp.y; //if displace : divide by the max freq


  //scale an object
  // vec3 sp = p;
  // sp -= vec3(0, 2.0, 0);
  // float offset = 1.0 + (sin(u_time * 8.0) * 0.5 + 0.5) * 4.0;
  // sp *= vec3(1.0, offset, 1.0);
  // float sd = sdSphere(sp, 1.0);
  // //if you squash an object you need to divide its depth by the max squashing number in order to keep the distance filed undistorted
  // sd /= offset;
  // float d = min(sd, planeDist); //get only the min dist between the sphere dist and the plane dist (for aligned axis plane only)

  vec3 spA = np;
  vec3 spB = np - vec3(0.25, 0.0, 0);
  spA.x += sin(u_time * 2.0) * 2.5;
  spA.xz *= rotate2D(u_time);
  spA -= vec3(-0.5, 1.5, 0);
  float sdA = sdSphere(spA, 1.0);
  float sdB = sdSphere(spB, 1.0);

  //boolean substraction
  float sds = opSubstract(bd, sdA);
  // sds = opSmoothSubstract(sdA, sdB, 0.5);

  //boolean intersection
  float sdi = opIntersect(sdA, sdB);
  sdi = opSmoothIntersect(sdA, sdB, 0.5);

  //boolean union (metaball)
  float sdu = opUnite(sdA, sdB);
  sdu = opSmoothUnite(sdA, sdB, 0.5);

  //morph
  float sdm = opMorph(bd, sdB, sin(u_time * 4.0) * 0.5 + 0.5);

  float d = min(sds, planeDist);

  return d;
}

float rayMarch(vec3 ro, vec3 rd){
  float dO = 0.0; //distance to origin
  for(int i=0; i<MAX_STEPS; i++){
    vec3 p = ro + rd * dO; //current marching location on the ray
    float dS = getDist(p); // distance to the scene
    dO += dS;
    if(dO > MAX_DIST || dS < SURFACE_DIST) break; //hit
  }
  return dO;
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

float getLight(vec3 p){
  vec3 lightPos = vec3(0, 5, -4.5);
  //lightPos.xz += vec2(sin(u_time), cos(u_time)) * 4.0;

  vec3 l = normalize(lightPos - p); //get the light vector Direction
  vec3 n = getNormal(p); //get the normal direction
  float diff = clamp(dot(n, l), 0.0, 1.0);

  float d = rayMarch(p + n * SURFACE_DIST * 2.0, l);
  if(d<length(lightPos-p)) diff *= 0.1;

  return diff;
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
  vec3 ro = vec3(0, 4, -5);
  ro.yz *= rotate2D(-u_mouse.y+.4);
  ro.xz *= rotate2D(u_time * 0.0 - u_mouse.x*6.2831);
  vec3 rd = R(uv, ro, vec3(0,0,0), 0.65);

  float d = rayMarch(ro, rd); //get the distance from the sphere

  vec3 p = ro + rd * d; //get the intersection point position

  float diff = getLight(p); //diffuse

  float far = 20.0;
  d /= far; //the distance return as an unnormalized distance so we divied by a far plane distance
  color = vec3(diff);

//  color = getNormal(p); debug normal
  gl_FragColor = vec4(color, 1.0);
}
