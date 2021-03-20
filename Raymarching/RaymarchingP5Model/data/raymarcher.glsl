#ifdef GL_ES
precision highp float;
precision highp int;
#endif

//Defines raymarcher constants
#define PI 3.1415926535897932384626433832795
#define TWOPI (PI * 2.0)

//defines bound informations from p5
uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;
uniform samplerCube envd;
uniform float mipLevel;

//Textures
//uniform sampler2D ramp;
uniform sampler2D albedoMap;
uniform sampler2D normalMap;
uniform sampler2D specularMap;
uniform sampler2D displacementMap;

in vec4 vertTexCoord;
in vec4 color;
out vec4 fragColor;

//Post Process
const float gamma = 2.2;

//RAYMARCHIN CONSTANT
#define FAR 2000.0
#define NEAR 200
#define MAX_STEPS (32 * 8) //max iteration on the marching loop
#define MAX_STEPS_SHADOW (32 * 4) //max iteration on the marching loop for shadow
#define MAX_DIST (FAR * 2.0) //maximum distance from camera //based on near and far
#define SHADOW_DIST_DIV 0.75
#define MAX_DIST_SHADOW (MAX_DIST * SHADOW_DIST_DIV)  //based on near and far
#define SURFACE_DIST 0.001 // minimum distance for a Hit
#define SHADOW_SURFACE_DIST 0.001
#define REFLECTION_COUNT 2
#define REFLECTION_INTENSITY 0.25
#define ENVIRONMENT_INTENSITY 0.75

#define OCTAVE 4 //noise option

struct VoroStruct{
  vec2 dist;
  vec2 indices;
};

/*Time system computation*/
struct Time{
  float time;
  float modTime;
  float normTime;
  float timeLoop;
  float maxTime;
};

/*Time management*/
Time computeTime(float atime, float maxTime){
  float modTime = floor(mod(atime, maxTime));
  float normTime = mod(atime, maxTime) / maxTime;
  float timeLoop = floor(atime / maxTime);
  Time time = Time(
    atime,
    modTime,
    normTime,
    timeLoop,
    maxTime
    );
  return time;
}


//smooth min/max
vec2 smin(vec2 a, vec2 b, float k){
  float h = clamp(0.5 + 0.5 * (b.x - a.x) / k, 0.0, 1.0);
  float d = mix(b.x, a.x, h) - k * h * (1.0 - h);
  // // float index = (a.x < b.x) ? a.y : b.y;//mix(b.y, a.y, h);
  float index = mix(b.y, a.y, h);
  return vec2(d, index);
}

vec2 smax(vec2 a, vec2 b, float k){
  float h = clamp(0.5 - 0.5 * (b.x - a.x) / k, 0.0, 1.0);
  float d = mix(b.x, a.x, h) + k * h * (1.0 - h);
  float index = mix(b.y, a.y, h);
  return vec2(d, index);
}

// IQ's polynomial-based smooth minimum function.
float smin( float a, float b, float k ){

    float h = clamp(.5 + .5*(b - a)/k, 0., 1.);
    return mix(b, a, h) - k*h*(1. - h);
}

// Commutative smooth minimum function. Provided by Tomkh and taken from
// Alex Evans's (aka Statix) talk:
// http://media.lolrus.mediamolecule.com/AlexEvans_SIGGRAPH-2015.pdf
// Credited to Dave Smith @media molecule.
float smin2(float a, float b, float r)
{
   float f = max(0., 1. - abs(b - a)/r);
   return min(a, b) - r*.25*f*f;
}

// IQ's exponential-based smooth minimum function. Unlike the polynomial-based
// smooth minimum, this one is associative and commutative.
float sminExp(float a, float b, float k)
{
    float res = exp(-k*a) + exp(-k*b);
    return -log(res)/k;
}

/*Maths Helpers*/
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


vec3 noise1to3(float x)
{
    float p = floor(x);
    float f = fract(x);
    f = f*f*(3.0-2.0*f);

    // vec3 h1 = fract(sin(vec3(p, p+7.3, p+13.7))*1313.54531);
    // vec3 h2 = fract(sin(vec3((p+1.0), (p+1.0)+7.3, (p+1.0)+13.7))*1313.54531);
    return mix(random3D(vec3(p+0.0)), random3D(vec3(p+1.0)), vec3(f));
    // return mix(h1, h2, f);
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
    mix(dotAA_, dotBB_, suv.x),
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
    mix(dotAA_, dotBB_, suv.x),
    mix(dotCC_, dotDD_, suv.x),
    suv.y);

  float passH1 = mix(
    mix(dotEE_, dotFF_, suv.x),
    mix(dotGG_, dotHH_, suv.x),
    suv.y);

  return mix(passH0, passH1, suv.z);
}

//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //  x0 = x0 - 0. + 0.0 * C 
  vec3 x1 = x0 - i1 + 1.0 * C.xxx;
  vec3 x2 = x0 - i2 + 2.0 * C.xxx;
  vec3 x3 = x0 - 1. + 3.0 * C.xxx;

// Permutations
  i = mod(i, 289.0 ); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients
// ( N*N points uniformly over a square, mapped onto an octahedron.)
  float n_ = 1.0/7.0; // N=7
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                dot(p2,x2), dot(p3,x3) ) );
}



VoroStruct voronoiDistance(vec2 st, vec2 colsrows, float seed, float minRound, float maxRound)
{
	vec2 nuv = st * colsrows;
	vec2 iuv = floor(nuv);
	vec2 fuv = fract(nuv);

    vec2 nearestNeighborsIndex;
    vec2 nearestDiff;
    vec2 cellindex;

    //compute voronoi
    float dist = 8.0;
    for( int j=-1; j<=1; j++ ){
    	for( int i=-1; i<=1; i++ )
    	{
    		//neightbor
        	vec2 neighbor = vec2(i, j);

        	//randomPoint
        	vec2 point = random2D(iuv + neighbor);

        	//animation
        	point = 0.5 + 0.5* sin(seed + TWOPI * point);

        	//define the vector between the pixel and the point
        	vec2  diff = neighbor + point - fuv;

        	//Compute the Dot product
        	float d = dot(diff,diff);

    	    if(d < dist)
    	    {
    	        dist = d;
    	        nearestDiff = diff;
    	        nearestNeighborsIndex = neighbor;
    	        cellindex = (iuv + vec2(i, j)) / colsrows;
    	    }
    	}
	}
	float basedVoronoi = dist;

  //compute distance
  dist = 8.0;
  float sdist = 8.0;
  for( int j=-2; j<=2; j++ ){
  	for( int i=-2; i<=2; i++ )
  	{
  		//neightbor
  	    vec2 neighbor = nearestNeighborsIndex + vec2(i, j);

  	    //randomPoint
  	    vec2 point = random2D(iuv + neighbor);

      	//animation
      	point = 0.5 + 0.5* sin(seed + TWOPI * point);

      	//define the vector between the pixel and the point
  	    vec2  diff = neighbor + point - fuv;

      	//Compute the Dot product to get the distance
  	    float d = dot(0.5 * (nearestDiff + diff), normalize(diff - nearestDiff));


  	   //rounded voronoi distance from https://www.shadertoy.com/view/lsSfz1
  	   //Skip the same cell
  	    if( dot(diff-nearestDiff, diff-nearestDiff)>.00001){
  	   		 // Abje's addition. Border distance using a smooth minimum. Insightful, and simple.
         		 // On a side note, IQ reminded me that the order in which the polynomial-based smooth
         		 // minimum is applied effects the result. However, the exponentional-based smooth
         		 // minimum is associative and commutative, so is more correct. In this particular case,
         		 // the effects appear to be negligible, so I'm sticking with the cheaper polynomial-based
         		 // smooth minimum, but it's something you should keep in mind. By the way, feel free to
         		 // uncomment the exponential one and try it out to see if you notice a difference.
         		 //
         		 // // Polynomial-based smooth minimum.
             float round = mix(minRound, maxRound, noise(cellindex * 100.0));
         		sdist = smin(sdist, d, round);


          	// Exponential-based smooth minimum. By the way, this is here to provide a visual reference
          	// only, and is definitely not the most efficient way to apply it. To see the minor
          	// adjustments necessary, refer to Tomkh's example here: Rounded Voronoi Edges Analysis -
          	// https://www.shadertoy.com/view/MdSfzD
          	//sdist = sminExp(sdist, d, 20.);
      	}
  	    //voronoi distance
  	    dist = min(dist, d);
      }
    }

    VoroStruct vs = VoroStruct(
        vec2(sdist, dist),
        cellindex
      );

    return vs;
}

float fbm(vec3 st, float amp, float freq, float lac, float gain){
	//initial value
	float fbm = 0.0;

	//float rmx = sin(eta);
	//float rmy = cos(eta);
	//float px = 0.0;

	vec3 shift = vec3(1.0);
	for(int i = 0; i < OCTAVE; i++){
		//px = st.x;
		//st.x = st.x * rmx + st.y * rmy;
		//st.y = px * rmy + st.y * rmx;
		fbm += amp * noise(st * freq);
		freq *= lac;
		amp *= gain;
	}

	return fbm;
}


float fbm(vec3 st, float amp, float freq, float lac, float gain, float gamma, float eta){
	//initial value
	float fbm = 0.0;

	//float rmx = sin(eta);
	//float rmy = cos(eta);
	//float px = 0.0;

	vec3 shift = vec3(1.0);
	mat2 rot2 = mat2(cos(-eta), sin(eta), -sin(eta), cos(eta));
	mat3 rot3 = mat3(sin(-gamma) * cos(-eta), cos(gamma) * sin(eta), sin(gamma),
		sin(gamma) * -sin(eta), sin(-gamma) * cos(eta), sin(gamma),
		sin(gamma) * cos(eta), cos(gamma) * sin(eta), sin(gamma)
		);

	for(int i = 0; i < OCTAVE; i++){
		//px = st.x;
		//st.x = st.x * rmx + st.y * rmy;
		//st.y = px * rmy + st.y * rmx;

		fbm += amp * noise(st * freq);
		st = rot3 * st * 2.5 + shift;
		freq *= lac;
		amp *= gain;
	}

	return fbm;
}

float domainWarping(vec3 st, float inc1, float inc2, float amp, float freq, float lac, float gain, float gamma, float eta){
	float tmp = fbm(st, amp, freq, lac, gain, gamma, eta);
	tmp += fbm(st + tmp * inc1, amp, freq, lac, gain, gamma, eta);
	tmp += fbm(st + tmp * inc2, amp, freq, lac, gain, gamma, eta);

	return tmp;
}


/*Camera computation*/
vec3 R(vec2 uv, vec3 p, vec3 o, vec3 axis, float z) { //this function return the ray direction from a non aligned axis camera
    vec3 f = normalize(o-p),
        r = normalize(cross(axis, f)),
        u = cross(f,r),
        c = p+f*z,
        i = c + uv.x*r + uv.y*u,
        d = normalize(i-p);
    return d;
}

/*Screen Space normal mapping*/
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

vec2 topDownUvProjection(vec3 pos, float textureFreq, vec2 offset){
    vec2 uv = textureFreq * (pos.xy + offset);
    uv.x = 1.0 - uv.x;

    return uv;
}


/*Triplanar texture projection*/
vec3 triplanarMap(vec3 pos, vec3 normal, sampler2D texture)
{
    // Take projections along 3 axes, sample texture values from each projection, and stack into a matrix
    mat3 triMapSamples = mat3(
        texture2D(texture, pos.yz).rgb,
        texture2D(texture, pos.xz).rgb,
        texture2D(texture, pos.xy).rgb
        );

    // Weight three samples by absolute value of normal components
    return triMapSamples * abs(normal);
}



/*RayMarcher primitives*/
vec2 sdSphere(vec3 p, float r, float index){
  
  return vec2(length(p) - r, index);
}

vec2 sdCapsule(vec3 p, vec3 a, vec3 b, float r, float index){
  vec3 ab = b-a;
  vec3 ap = p-a;

  float t = dot(ab, ap) / dot(ab, ab); //project ray on the line between the two sphere of teh capsule to get the distance
  t = clamp(t, 0.0, 1.0);

  vec3 c = a + t * ab; // get the ray a to the ab
  return vec2(length(p-c) - r, index); // get the distance between p and the c
}

vec2 sdTorus(vec3 p, vec2 r, float index){
  float x = length(p.xz) - r.x;
  return vec2(length(vec2(x, p.y)) - r.y, index);
}

vec2 sdBox(vec3 p, vec3 s, float index){
  vec3 d = abs(p) -s;

  return vec2(length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0), //remove this line for an only partially signed sdf
              index);
}

vec2 sdCylinder(vec3 p, vec3 a, vec3 b, float r, float index){
  vec3 ab = b-a;
  vec3 ap = p-a;

  float t = dot(ab, ap) / dot(ab, ab); //project ray on the line between the two sphere of teh capsule to get the distance
  //t = clamp(t, 0.0, 1.0);

  vec3 c = a + t * ab; // get the ray a to the ab

  float x = length(p-c) - r; // get the distance between p and the c
  float y = (abs(t - 0.5) - 0.5) * length(ab);
  float e = length(max(vec2(x, y), 0.0));
  float i = min(max(x, y), 0.0);
  return vec2(e + i, index);
}

vec2 sdRoundBox(vec3 p, vec3 s, float r, float index){
  vec3 d = abs(p) -s;

  return vec2(length(max(d, 0.0)) - r + min(max(d.x, max(d.y, d.z)), 0.0), //remove this line for an only partially signed sdf
              index);
}

float dot2( in vec2 v ) { return dot(v,v);}
vec2 sdCone(vec3 p, float h, float r1, float r2, float index){
    vec2 q = vec2( length(p.xz), p.y );

    vec2 k1 = vec2(r2,h);
    vec2 k2 = vec2(r2-r1,2.0*h);
    vec2 ca = vec2(q.x-min(q.x,(q.y < 0.0)?r1:r2), abs(q.y)-h);
    vec2 cb = q - k1 + k2*clamp( dot(k1-q,k2)/dot2(k2), 0.0, 1.0 );
    float s = (cb.x < 0.0 && ca.y < 0.0) ? -1.0 : 1.0;
    return vec2(s*sqrt(min(dot2(ca),dot2(cb))), index);
}

vec2 sdSegment( vec3 a, vec3 b, vec3 p )
{
	vec3 pa = p - a;
	vec3 ba = b - a;
	float t = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return vec2( length( pa - ba*t ), t );
}

vec2 sdPlane( vec3 p, vec4 n, float index )
{
  // n must be normalized
  return vec2(dot(p,n.xyz) + n.w, index);
}

/*QUADRATIC BEZIER*/
vec2 sdBezier(vec3 A, vec3 B, vec3 C, vec3 pos)
{    
    vec3 a = B - A;
    vec3 b = A - 2.0*B + C;
    vec3 c = a * 2.0;
    vec3 d = A - pos;

    float kk = 1.0 / dot(b,b);
    float kx = kk * dot(a,b);
    float ky = kk * (2.0*dot(a,a)+dot(d,b)) / 3.0;
    float kz = kk * dot(d,a);      

    vec2 res;

    float p = ky - kx*kx;
    float p3 = p*p*p;
    float q = kx*(2.0*kx*kx - 3.0*ky) + kz;
    float h = q*q + 4.0*p3;

    if(h >= 0.0) 
    { 
        h = sqrt(h);
        vec2 x = (vec2(h, -h) - q) / 2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        float t = uv.x + uv.y - kx;
        t = clamp( t, 0.0, 1.0 );

        // 1 root
        vec3 qos = d + (c + b*t)*t;
        res = vec2(length(qos), t);
    }
    else
    {
        float z = sqrt(-p);
        float v = acos( q/(p*z*2.0) ) / 3.0;
        float m = cos(v);
        float n = sin(v)*1.732050808;
        vec3 t = vec3(m + m, -n - m, n - m) * z - kx;
        t = clamp( t, 0.0, 1.0 );

        // 3 roots
        vec3 qos = d + (c + b*t.x)*t.x;
        float dis = dot(qos,qos);
        
        res = vec2(dis,t.x);

        qos = d + (c + b*t.y)*t.y;
        dis = dot(qos,qos);
        if( dis<res.x ) res = vec2(dis,t.y );

        qos = d + (c + b*t.z)*t.z;
        dis = dot(qos,qos);
        if( dis<res.x ) res = vec2(dis,t.z );

        res.x = sqrt( res.x );
    }
    
    return res;
}


/*Raymarcher operator*/
vec2 opUnite(vec2 d1, vec2 d2){
  return (d1.x < d2.x) ? d1 : d2;//min(d1, d2);
}

vec2 opSubstract(vec2 d1, vec2 d2){
  return (-d1.x < d2.x) ? d2 : vec2(-d1.x, d1.y);//max(-d1, d2);
}

vec2 opIntersect(vec2 d1, vec2 d2){
  return (d1.x < d2.x) ? d2 : d1;//max(d1, d2);
}

vec2 opMorph(vec2 d1, vec2 d2, float offset){
  return mix(d1, d2, offset);
}

vec2 opSmoothUnite(vec2 d1, vec2 d2, float k){
  return smin(d1, d2, k);;
}

vec2 opSmoothUniteID(vec2 d1, vec2 d2, float k){
  float h = clamp(0.5 + 0.5 * (d2.x - d1.x) / k, 0.0, 1.0);
  float d = mix(d2.x, d1.x, h) - k * h * (1.0 - h);
  // float index = mix(d2.y, d1.y, h);
  float index = mix(d2.y, d1.y, pow(h, 4.0) * 20.0);
  return vec2(d, index);
}


vec2 opSmoothSubstract(vec2 d1, vec2 d2, float k){
  return smax(vec2(-d1.x, d1.y), d2, k);
}

vec2 opSmoothIntersect(vec2 d1, vec2 d2, float k){
  return smax(d1, d2, k);
}

/*Raymarcher displacement*/
vec3 opRepeat(vec3 p, vec3 freqXYZ){
  return (mod(p, freqXYZ) - 0.5 * freqXYZ);
}

float displace(vec3 p, vec3 freqXYZ, float inc, vec3 time){
  return (sin(freqXYZ.x * p.x + time.x) * cos(freqXYZ.y * p.y + time.y) * sin(freqXYZ.z * p.z + time.z)) * inc;
}


vec3 opRepLim(vec3 p, float c, vec3 l)
{
    return p-c*clamp(round(p/c),-l,l);
}

vec3 deform(vec3 p, vec3 freqXYZ, float inc){
  //1.0, 0.5, 0.25
    p.xyz += (freqXYZ.x * sin(2.0 * p.zxy)) * inc;
    p.xyz += (freqXYZ.y * sin(4.0 * p.zxy)) * inc;
    p.xyz += (freqXYZ.z * sin(8.0 * p.zxy)) * inc;
    return p;
}

vec3 twist(vec3 p, float k){
  float c = cos(k*p.y);
  float s = sin(k*p.y);
  mat2  m = mat2(c,-s,
  			    s,c);
  return vec3(p.xy, m * p.z);
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

mat2 rot( in float a ) {
    vec2 v = sin(vec2(PI*0.5, 0) + a);
    return mat2(v, -v.y, v.x);
}

vec3 getRndAxis(float val){
  float rnd = random(val);
  if(rnd <= 1.0 / 3.0){
    return vec3(1.0, 0, 0);
  }else if(rnd < 2.0/3.0){
    return vec3(0.0, 1, 0);
  }else{
    return vec3(0.0, 0, 1);
  }
}

/*MARCHING SCENE: Where all the shape computation are made*/
vec2 getDist(vec3 p){
  
  vec2 planeH = sdPlane(p + vec3(0, 150, 0), vec4(0, 1, 0.0, 1), 0.0);
  vec2 planeV = sdPlane(p + vec3(500, 0, 0), vec4(1, 0, 0.0, 10), 0.0);
  vec2 scene = planeH;//opSmoothUnite(planeH, planeV, 250);

  float radius = 200;
  float maxTime = 2;
  float nTime = mod(time, maxTime) / maxTime;
 
  #define NBSPHERE 8
  for(int i=0; i<NBSPHERE; i++){
    float ni = float(i) / float(NBSPHERE);
    float eta = ni * TWOPI;
    vec3 sp = vec3(
      cos(eta) * radius,
      sin(nTime * TWOPI + eta * 4.) * 100,
      sin(eta) * radius
    );
    vec2 sphere = sdSphere(p + sp, radius * 0.25, 1.0);
    //vec3 saledpos = (sp + vec3(200))* 0.0025;
   // float displacement = triplanarMap(saledpos, normalize(sp), displacementMap).r;
   // sphere.x -= displacement * 15.0;
    scene = opUnite(scene, sphere);
  }

  return scene;
}

/*MAIN RAYMARCHER FUNCTION*/
vec2 rayMarch(vec3 ro, vec3 rd, int maxSteps, float maxDist, float surfaceDist){
  vec2 dO = vec2(0.0); //distance to origin
  for(int i=0; i<maxSteps; i++){
    vec3 p = ro + rd * dO.x; //current marching location on the ray
    vec2 dS = getDist(p); // distance to the scene
    // if(dO.x > maxDist || dS.x < surfaceDist){
    //   dO.y = dS.y;
    //   hit = true;
    //   break; //hit
    // }

    if(dO.x >= maxDist){
      dO.y = dS.y;
      dO.x = MAX_DIST * 1.1;
      break;
    }

    if(dS.x < surfaceDist){
      dO.y = dS.y;
      break; //hit
    }
    dO.x += dS.x;
  }
  return dO;
}


float rayMarchPerfCheck(vec3 ro, vec3 rd){
  vec2 dO = vec2(0.0); //distance to origin
  for(int i=0; i<MAX_STEPS; i++){
    vec3 p = ro + rd * dO.x; //current marching location on the ray
    vec2 dS = getDist(p); // distance to the scene
    if(dO.x > MAX_DIST || dS.x < SURFACE_DIST){
      return float(i)/float(MAX_STEPS); // return the the step / max which is the number of iteration between 0 (0) and 1 (MAX_STEPS)
    }; //hit
    dO.x += dS.x;
  }
}

/*LIGHTING AND MATERIALS*/
float softShadow(vec3 ro, vec3 rd, float k){
    float res = 1.0;
    float ph = 1e20;
    float dO = 0.0; //distance to origin
    for(int i=0; i<MAX_STEPS_SHADOW; i++){
      vec3 p = ro + rd * dO.x; //current marching location on the ray
      float dS = getDist(p).x; // distance to the scene
      if(dO.x > MAX_DIST_SHADOW || res < SURFACE_DIST) break; //hit

      res = min(res, 10.0 * dS/dO);
      dO += dS;
    }
    return res;//return clamp(res, 0.0, 1.0);
}

float softShadowImproved(vec3 ro, vec3 rd, float mind, float k){
    float res = 1.0;
    float ph = 1e20;
    float dO = mind; //distance to origin
    for(int i=0; i<MAX_STEPS_SHADOW; i++){
      vec3 p = ro + rd * dO; //current marching location on the ray
      float dS = getDist(p).x; // distance to the scene
      if(dS.x < 0.001) return 0.0;
      float y = dS*dS/(2.0*ph);
      float d = sqrt(dS*dS-y*y);
      res = min(res, k*d/max(0.0,dO-y));
      ph = dS;
      if(dO > MAX_DIST_SHADOW || res < SHADOW_SURFACE_DIST) break; //hit
      dO += dS;
    }
    return res;//clamp(res, 0.0, 1.0);
}

float quilezImprovedShadow(in vec3 ro, in vec3 rd, in int it, in float mint, in float tmax, in float k){
	  float res = 1.0;
    float t = mint;
    float ph = 1e20; // big, such that y = 0 on the first iteration
    for( int i=0; i<it; i++ )
    {
		    float h = getDist( ro + rd*t ).x;
        // use this if you are getting artifact on the first iteration, or unroll the
        // first iteration out of the loop
        // float y = (i==0) ? 0.0 : h*h/(2.0*ph); 
        float y = h*h/(2.0*ph);
        float d = sqrt(h*h-y*y);
        res = min( res, k*d/max(0.0,t-y) );
        ph = h;
        t += h;
        if( res<0.0001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}

vec3 getNormal(vec3 p, float offset){
  float d = getDist(p).x;// get the distance at point d
  vec2 e =  vec2(offset, 0.0);//define an offset vector
  vec3 n = d - vec3(
    getDist(p - e.xyy).x, //get dist offset on X
    getDist(p - e.yxy).x, //get dist offset en Y
    getDist(p - e.yyx).x // get dist offset on Z
    ); // get the vector next to the point as the normal

  return normalize(n);
}

float ambientOcclusion(vec3 p, vec3 n, float step, float aoIntensity){
  //based on PeerPlay videos
  float ao = 0.0;
  float dist;
  #define OCCSTEP 4
  for(int i=1; i<=OCCSTEP; i++){
    float dist = step * i;
    ao += max(0.0, (dist - getDist(p + n * dist).x) / dist);
  }
  return clamp(1.0 - ao * aoIntensity, 0.0, 1.0);
}

float RayMarchOut(vec3 ro, vec3 rd, float stepper) 
{
  float dO=0.;   
  for(float i=0.0; i<1.0; i+=stepper) 
  {
      vec3 p = ro + rd*i;
      float dS = getDist(p).x;
      dO += stepper * step(dS, 0.0);
  }
  return exp(-dO * 1.1);
}


/*Post-Processing*/
vec3 toLinear(vec3 v) {
  return pow(v, vec3(gamma));
}

vec4 toLinear(vec4 v) {
  return vec4(toLinear(v.rgb), v.a);
}


vec3 toGamma(vec3 v) {
  return pow(v, vec3(1.0 / gamma));
}

vec4 toGamma(vec4 v) {
  return vec4(toGamma(v.rgb), v.a);
}

// IQ
// https://www.shadertoy.com/view/ll2GD3
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d));
}

vec3 spectrum(float n) {
       return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
     // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.10,0.20));
     // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,0.7,0.4),vec3(0.0,0.15,0.20));
     // return palette(n, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25));
}

float rectangleSDF(vec2 st, vec2 thickness){
  //remap st coordinate from 0.0 to 1.0 to -1.0, 1.0
  st = st * 2.0 - 1.0;
  float edgeX = abs(st.x / thickness.x);
  float edgeY = abs(st.y / thickness.y);
  return max(edgeX, edgeY);
}

/*RENDER SCENE: Where all material computation are done*/
vec4 render(in vec2 depth, in vec3 ro, in vec3 rd, inout vec3 pos, inout vec3 nor){
  vec3 col = vec3(0.0);

  if(depth.x > 0.0){
    // normalizeddepth = depth.x/(far - near);//compute depthmap (useful for debug only
    
    pos = ro + rd * depth.x;
    nor = getNormal(pos, 0.01);
    vec3 eye = normalize(ro);
    vec3 view = normalize(-rd);
    
    
    float isGround = (depth.y <= 0.0) ? 1.0 : 0.0;
    //texturing
    vec2 uv = topDownUvProjection(pos, 0.0005, vec2(100));
    // uv = fract(uv * 3.5);

    vec3 perturbNormal    = perturb_normal(nor, normalize(view), uv, normalMap);
    vec3 normalMapping    = mix(nor, perturbNormal, 1.0);
   // vec3 albedoMapping    = texture2D(albedoMap, uv).xyz;
    //vec3 specularMapping  = texture2D(specularMap, uv).xyz;
    
    vec3 saledpos = (pos + vec3(400))* 0.001;
    vec3 albedoMapping = triplanarMap(saledpos, nor, albedoMap);
    vec3 specularMapping  = triplanarMap(saledpos, nor, specularMap);
    nor = nor * isGround + (1.0 - isGround) * normalMapping;
    
    vec3 mat = albedoMapping * (1.0 - isGround) + vec3(0.0) * isGround;

    vec3 uvproj = fract(pos.xyz * 0.015);
    float line = rectangleSDF(uvproj.xz, vec2(1.0));
    float grid = smoothstep(0.95, 1.0, line);
    mat += grid * isGround;

    //lighting
    vec3 specColor;
    vec3 lightColor;
    vec3 lightsPos[3] = vec3[3](
      vec3(cos(TWOPI * 0.05), 0.5, sin(TWOPI * 0.05)),
      vec3(cos(TWOPI * .525), 0.75, sin(TWOPI * .525)),
      vec3(0.15, 0.5, -0.5)
      );
    vec3 lightsColors[3] = vec3[3](
      vec3(0.0588, 0.2784, 1.0) * 1.0,
      vec3(0.9725, 0.9529, 0.8588) * 1.0,
      vec3(0.9725, 0.9529, 0.8588) * 0.15
      );
    
    vec3 SScol = vec3(0.5137, 0.3059, 1.0);
    float density = 1.5;
    float intensity = 2.5;
    float subsurface; //fake Subsurface
    
    for(int i=0; i<lightsPos.length; i++){
      vec3 lp = lightsPos[i];

      float intensity = clamp(dot(nor, lp), 0.0, 1.0);
      float diffM =  clamp(dot(nor, lp), 0.0, 1.0) 
                    * softShadowImproved(pos, lp, 10.0, 50.0);
                  // * softShadow(pos, lp, 25.0);
                  // * quilezImprovedShadow(pos, lp, 10, 10, 2000.0, 1000.0);

      //specularity
      vec3 hal = normalize(lp - rd);
      float NdotHL = clamp(dot(nor, hal), 0., 1.);
      float HLdotRD = clamp(1.0+dot(hal, rd),0.0,1.0);
      float specPower = 50.0 * (1.0 - isGround) + 10 * isGround;
      float gloss = 20.0 * (1.0 - isGround) + 10 * isGround;
      float specMask = pow(specularMapping.r, 1.0) * (1.0 - isGround) + isGround;
      float specM = (pow(NdotHL, specPower) * gloss * diffM * (0.04 + .96*pow(HLdotRD, 5.0))) * specMask;

      specColor += lightsColors[i] * specM;
      lightColor += lightsColors[i] * diffM;

      // float ss = RayMarchOut(ro+rd*(SURFACE_DIST * 4.0 + noise(pos * 100.0) * 4.0), normalize(lp), 0.25);
      // ss = pow(ss * 1.25, density);
      // subsurface += ss;
    }
    lightColor /= float(lightsColors.length);
    specColor /= float(lightsColors.length);
    subsurface /= float(lightsColors.length);
    // subsurface = smoothstep(0.0, 10.0, subsurface) * (1.0 - isGround);


    //rim light
    float rimPower = 0.015;
    float rim = 1.0 - max(dot(view, nor), 0.0);
    rim = smoothstep(0.0, 1.0, rim);

    // material definition
    // col += (SScol * subsurface) * intensity + 
    //        mat * lightColor + specColor + 
    //        (SScol * subsurface) * intensity;//Lambert estimation + BlinnPhong
    col += mat * lightColor + specColor;//Lambert estimation + BlinnPhong 
    col += rim * rimPower;// * specMask;//rim light
    
    //ambient + occlusion
    float occ = ambientOcclusion(pos, nor, 3.0, 0.15);
    float amb = clamp(0.5 + 0.5 * nor.y, 0.0, 1.0);
    col += amb * 0.01;
    col *= occ;
  }

  col = clamp(col, vec3(0.0), vec3(1.0));
  return vec4(col, 1.0);
}

float DoFValue(in vec3 ro, in float depth, in float minValue, in float maxBlur){
    float ndofLength = (1.0 - length(ro - vec3(0, 0, 0)) / depth);
    ndofLength       = clamp(ndofLength,  0.005, 1.0);
    float coc        =  minValue * ndofLength;
    return max(0.005, min(maxBlur, coc));
}

/*MAIN FUNCTION*/
void main(){
  //define time
  Time stime = computeTime(time, 30.0);

  //define uv and aspect ratio
  float aspectRatio = resolution.x / resolution.y;
  vec2 uv = -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;
  uv.x *= aspectRatio;
  
  float pp = abs(stime.normTime * 2.0 - 1.0);

  //define camera
  vec3 ro, rd;
  ro =  vec3(
  			cos(pp * PI * 0.5 - PI * 0.25) * 600,
  			(1.0 - mouse.y) * 500.00,
  			sin(pp * PI * 0.5 - PI * 0.25) * 600);

  float hyp = sqrt(resolution.x * resolution.x + resolution.y * resolution.y) * 0.5;
  rd = R(uv, ro, vec3(0.0, 0, 0), vec3(0, 1, 0.0), PI * 0.5);
  vec3 oro = ro;

  //raymarch
  float p = rayMarchPerfCheck(ro, rd);
  vec3 perf = mix(vec3(0,0,1), vec3(1, 0, 0), p);
  vec2 d = rayMarch(ro, rd, MAX_STEPS, MAX_DIST, SURFACE_DIST);
  float od = d.x;
  vec4 color;

  // render	shading
  vec3 pos;
  vec3 nor;
  color = render(d, ro, rd, pos, nor);
  
  color.rgb += textureLod(envd, nor, mipLevel).rgb * ENVIRONMENT_INTENSITY;

  if(REFLECTION_COUNT > 0){
      rd = normalize(reflect(rd, nor));
      ro = pos + (rd * 0.01);
      d = rayMarch(ro, rd, MAX_STEPS / 1, MAX_DIST * 0.5, SURFACE_DIST * 1.0);    
      vec4 refl = render(d, ro, rd, pos, nor);
      float isFar = 1.0 - step(MAX_DIST * 0.5, d.x);
      color.rgb += textureLod(envd, nor, mipLevel).rgb * ENVIRONMENT_INTENSITY * REFLECTION_INTENSITY * isFar;
      color.rgb += refl.rgb * REFLECTION_INTENSITY * isFar;
      if(REFLECTION_COUNT > 1){
        rd = normalize(reflect(rd, nor));
        ro = pos + (rd * 0.01);
        d = rayMarch(ro, rd, MAX_STEPS / 4, MAX_DIST * 0.25, SURFACE_DIST);  
        vec4 refl = render(d, ro, rd, pos, nor);
        isFar = 1.0 - step(MAX_DIST * 0.25, d.x);
       // color.rgb += textureLod(envd, nor, mipLevel).rgb * ENVIRONMENT_INTENSITY * REFLECTION_INTENSITY * isFar;
        color.rgb += refl.rgb * REFLECTION_INTENSITY * isFar;
      }
  }
  
  //fog exp
  vec3 bg = vec3(0.001);
  // col *= exp(-0.00000025 * pow(depth.x - 100, 2.5));
  //fog of war
  float fog = (od.x - NEAR) / (FAR - NEAR);
  fog = clamp(fog, 0., 1.0);
  color.rgb = mix(color.rgb, bg, fog);
  

  // gamma
  color.rgb = toGamma(color.rgb);

  //dof 
  color.a = DoFValue(oro, od, 0.25, 0.25);

  fragColor = color;
}