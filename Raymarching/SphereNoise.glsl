//Add smooth shadow support to ray marching from Inogo Quilez :
//see more on Inigo Quliez Website : https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
#ifdef GL_ES
precision highp float;
#endif
#define PI 3.1415926535897932384

uniform vec2 u_resolution; // size of the preview
uniform vec2 u_mouse; // cursor in normalized coordinates [0, 1]
uniform float u_time; // clock in seconds

#define MAX_STEPS 64 * 2 //max iteration on the marching loop
#define MAX_STEPS_SHADOW 64 //max iteration on the marching loop for shadow
#define MAX_DIST 100. //maximum distance from camera
#define MAX_DIST_SHADOW 32.
#define SURFACE_DIST 0.01 // minimum distance for a Hit
#define OCTAVE 6

//rotation
mat2 rotate2D(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s,
              s,  c);
}

float random(float value){
	return fract(sin(value) * 43758.5453123);
}

float random(vec2 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xy, vec2(12.9898, 78.233))) * 43758.5453123);//43758.5453123);
}

float random(vec3 tex){
	//return fract(sin(x) * offset);
	return fract(sin(dot(tex.xyz, vec3(12.9898, 78.233, 12.9898))) * 43758.5453123);//43758.5453123);
}

vec2 random2D(vec2 uv){
	uv = vec2(dot(uv, vec2(127.1, 311.7)), dot(uv, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

vec3 random3D(vec3 uv){
	uv = vec3(dot(uv, vec3(127.1, 311.7, 120.9898)), dot(uv, vec3(269.5, 183.3, 150.457)), dot(uv, vec3(380.5, 182.3, 170.457)));
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}


float cubicCurve(float value){
	return value * value * (3.0 - 2.0 * value); // custom cubic curve
}

vec2 cubicCurve(vec2 value){
	return value * value * (3.0 - 2.0 * value); // custom cubic curve
}

vec3 cubicCurve(vec3 value){
	return value * value * (3.0 - 2.0 * value); // custom cubic curve
}

float noise(vec2 uv){
	vec2 iuv = floor(uv);
	vec2 fuv = fract(uv);
	vec2 suv = cubicCurve(fuv);

	float dotAA_ = dot(random2D(iuv + vec2(0.0)), fuv - vec2(0.0));
	float dotBB_ = dot(random2D(iuv + vec2(1.0, 0.0)), fuv - vec2(1.0, 0.0));
	float dotCC_ = dot(random2D(iuv + vec2(0.0, 1.0)), fuv - vec2(0.0, 1.0));
	float dotDD_ = dot(random2D(iuv + vec2(1.0, 1.0)), fuv - vec2(1.0, 1.0));

	return mix(
		mix(dotAA_, dotBB_,	suv.x),
		mix(dotCC_, dotDD_, suv.x),
		suv.y);
}

float noise(vec3 uv){
	vec3 iuv = floor(uv);
	vec3 fuv = fract(uv);
	vec3 suv = cubicCurve(fuv);

	float dotAA_ = dot(random3D(iuv + vec3(0.0)), fuv - vec3(0.0));
	float dotBB_ = dot(random3D(iuv + vec3(1.0, 0.0, 0.0)), fuv - vec3(1.0, 0.0, 0.0));
	float dotCC_ = dot(random3D(iuv + vec3(0.0, 1.0, 0.0)), fuv - vec3(0.0, 1.0, 0.0));
	float dotDD_ = dot(random3D(iuv + vec3(1.0, 1.0, 0.0)), fuv - vec3(1.0, 1.0, 0.0));

	float dotEE_ = dot(random3D(iuv + vec3(0.0, 0.0, 1.0)), fuv - vec3(0.0, 0.0, 1.0));
	float dotFF_ = dot(random3D(iuv + vec3(1.0, 0.0, 1.0)), fuv - vec3(1.0, 0.0, 1.0));
	float dotGG_ = dot(random3D(iuv + vec3(0.0, 1.0, 1.0)), fuv - vec3(0.0, 1.0, 1.0));
	float dotHH_ = dot(random3D(iuv + vec3(1.0, 1.0, 1.0)), fuv - vec3(1.0, 1.0, 1.0));

	float passH0 = mix(
		mix(dotAA_, dotBB_,	suv.x),
		mix(dotCC_, dotDD_, suv.x),
		suv.y);

	float passH1 = mix(
		mix(dotEE_, dotFF_,	suv.x),
		mix(dotGG_, dotHH_, suv.x),
		suv.y);

	return mix(passH0, passH1, suv.z);
}

float fbm(vec3 st, float amp, float freq, float lac, float gain){
	//initial value
	float fbm = 0.0;

	for(int i = 0; i < OCTAVE; i++){
		fbm += amp * noise(st * freq);
		freq *= lac;
		amp *= gain;
	}

	return fbm;
}
 /*
float fbm(vec2 st, float amp, float freq, float lac, float gain){
	return fbm(st.xy, amp, freq, lac, gain);
}
*/

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
  vec3 np = p - vec3(0.0, 2.5, 0.0);

  //vec2 uv =  gl_FragCoord.xy / u_resolution;

  //rotate and move
  float depth = sdSphere(np, 3.25);

  float fbm1 = fbm(p + u_time * 0.1, .15, .5, 2., .5);
  float test = smoothstep(0., .25, fbm1);

  float depth2 = (test * 4. + depth);
  // d = clamp(d, 0.0, 1.0);

  return depth2;// * (0.065);
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
     //return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
     return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.10,0.20));
     // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,0.7,0.4),vec3(0.0,0.15,0.20));
     // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25));
}

vec3 render(vec3 ro, vec3 rd){
  vec3 col = vec3(0.0);
  vec2 uv = gl_FragCoord.xy / u_resolution;
  float centerDist = length(vec2(0.5) - uv);
  centerDist = pow(centerDist, 2.0);
  float rad = 0.15;
  float thick = 0.25;
  centerDist = smoothstep(rad - thick * 0.5, rad + thick * 0.5, centerDist);

  vec3 bg = vec3( 141, 213, 242) / 255.0;
  bg *= 0.75;
  vec3 bgLight = bg * 1.25;
  bg = mix(bgLight, bg, centerDist);

  float d = rayMarch(ro, rd);
  if(d > 0.0){
    vec3 pos = ro + rd * d;
    vec3 nor = getNormal(pos);
    vec3 dome = vec3(0,1,0);

    //keyLight
    vec3 lightColor = vec3(1.0);
    vec3 lightPos = vec3(5, 10.0, 50.0);
    float lightRadius = 50.0;
    float lightSpeed = 1.0;
    // lightPos.xz = vec2(cos(u_time * lightSpeed) * lightRadius, sin(u_time * lightSpeed) * lightRadius);

    vec3 lig = normalize(lightPos);
    vec3 hal = normalize(lig - rd);

    //material
    vec3 mat = vec3(20.0, 83.0, 204.0) / 255.0;

    //iridescence from : https://www.shadertoy.com/view/llcXWM
    vec3 eye = normalize(ro);
    vec3 refl = reflect(rd, nor);
    // vec3 perturb = sin(pos * 10.0);
    vec3 perturb = vec3(
      sin(noise(pos.zy * 8.0)),
      sin(noise(pos.yx * 2.0)),
      sin(noise(pos.xz * 4.0))
      ) * 2.0;

    // vec3 perturb = pos;
    vec3 spec = spectrum(dot(nor + perturb * 0.075, eye) * 1.75 + u_time * 0.5);

    float specular = clamp(dot(refl, lig), 0., 1.);
    float speItensity = 0.1;
    float speDiff = 10.0;
    specular += pow((sin(specular * 4. - 0.) * .5 + 0.5) + 0.0001, speDiff) * specular;
    specular *= .25;
    specular += pow(clamp(dot(refl, lig), 0., 1.) + .3, speDiff) * 0.1;


    float diff = clamp(dot(nor, lig), 0.0, 1.0) *
                softShadowImproved(pos, lig, 10.0);
                // softShadow(pos, lig, 10.0);
    col += mat * diff * lightColor;
    col += speItensity * specular * lightColor + spec * .2;


    //ambient
    float occ = ambientOcclusion(pos, nor);
    float amb = clamp(0.5 + 0.5 * nor.y, 0.0, 1.0);
    col += pow(amb * occ, 10.0);

    //fog exp
    // col *= exp(-0.0005 * pow(d, 2.5));
    //fog of war
    float middle = 8.0;
    float far = middle + 5.0;
    float near =  middle - 1.5;
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
  vec3 ro = vec3(0, 8.0, 8.0);
  // ro.yz *= rotate2D(-u_mouse.y+.4);
  //ro.xz *= rotate2D(u_mouse.x * PI * 2.0);
  //ro.y = (u_mouse.y * 2.0 - 1.0) * 10.0;
  vec3 rd = R(uv, ro, vec3(0,2,0), 0.65);

  // depth (only used for debug here)
//  float d = rayMarch(ro, rd); //get the distance
  //float far = 20.0;
  //vec3 depth = vec3(d / far); //the distance return as an unnormalized distance so we divied by a far plane distance

  //color debug
   //vec3 p = ro + rd * d;
   //vec3 normal = getNormal(p) * (1.0 - step(MAX_DIST, d)); //debug normal

  //performance debug
  //vec3 perf = vec3(perfMarch(ro, rd));

  //rend with material
  color = render(ro, rd); //diffuse


  gl_FragColor = vec4(color, 1.0);
}
