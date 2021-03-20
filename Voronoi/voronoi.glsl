#ifdef GL_ES
precision mediump float;
#endif

#define PI 3.1415926535897932384626433832795
#define TWOPI (PI*2.0)


uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

struct VoroStruct{
  vec2 dist;
  vec2 indices;
};

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(10.9898,78.233)))*43758.5453123);
}

vec2 random2D( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
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

VoroStruct voronoiDistance(vec2 st, vec2 colsrows, float seed, float round)
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
         		 //Polynomial-based smooth minimum.
         		sdist = smin(sdist, d, round);


          	// Exponential-based smooth minimum. By the way, this is here to provide a visual reference
          	// only, and is definitely not the most efficient way to apply it. To see the minor
          	// adjustments necessary, refer to Tomkh's example here: Rounded Voronoi Edges Analysis -
          	// https://www.shadertoy.com/view/MdSfzD
          	// sdist = sminExp(sdist, d, u_mouse.x * 20.0);
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


void main(){
  //compute the normalize screen coordinate
  vec2 st = gl_FragCoord.xy/u_resolution.xy;

  vec2 colsrows = vec2(8.0);
  vec2 fuv = fract(st * colsrows);

  VoroStruct voronoi = voronoiDistance(st, colsrows, u_time, st.x * 0.65);

  vec2 index = voronoi.indices;


  float stepy = step(0.5, st.y);
  float stepx = step(0.5, st.x);
  float dist = mix(voronoi.dist.x, voronoi.dist.y, stepy);
  float thickness = 0.01;
  float smoothness = 0.01;
  float stepper = thickness * 1.5 + (st.x * 0.25) * stepy;
  float shape = smoothstep(stepper - smoothness * 0.5, stepper + smoothness * 0.5, dist);
  float line = smoothstep(stepper - thickness * 0.5 - smoothness, stepper - thickness * 0.5, dist) - smoothstep(stepper + thickness * 0.5, stepper + thickness * 0.5 + smoothness, dist);
  float mixer = mix(shape, line, stepx);

  float linerThickness = 0.001;
  float linerSmoothness = 0.00125;
  float liner = smoothstep(0.5 - linerThickness * 0.5 - linerSmoothness, 0.5 - linerThickness * 0.5, st.y) - smoothstep(0.5 + linerThickness * 0.5, 0.5 + linerThickness * 0.5 + linerSmoothness, st.y) +
                 smoothstep(0.5 - linerThickness * 0.5 - linerSmoothness, 0.5 - linerThickness * 0.5, st.x) - smoothstep(0.5 + linerThickness * 0.5, 0.5 + linerThickness * 0.5 + linerSmoothness, st.x);

  vec4 color = vec4(vec3(mixer * index, 0.0), 1.0) + liner;
  gl_FragColor = color;
}
