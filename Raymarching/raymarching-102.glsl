//Tutorial from The Art of Code: https://www.youtube.com/watch?v=Ff0jJyyiVyw
//see more on Inigo Quliez Website : https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution; // size of the preview
uniform vec2 u_mouse; // cursor in normalized coordinates [0, 1]
uniform float u_time; // clock in seconds

#define MAX_STEPS 100 //max iteration on the marching loop
#define MAX_DIST 100. //maximum distance from camera
#define SURFACE_DIST 0.01 // minimum distance for a Hit


//rotation
mat2 rotate2D(float angle){
  float s = sin(angle);
  float c = cos(angle);
  return mat2(c, -s,
              s,  c);
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

float sdRoundBox(vec3 p, vec3 s, float r){
  vec3 d = abs(p) -s;

  return length(max(d, 0.0)) - r +
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



float getDist(vec3 p){
  float planeDist = p.y; //get the distance from the ground

  vec3 np = p - vec3(0.0, 1.0, 0);
  float sd = sdSphere(np - vec3(0.0, 1, 0.0),0.75); //get the distance from a sphere
  float td = sdTorus(np, vec2(1.75, 0.15));
  float bd = sdBox(np - vec3(0.0, 2.5, 0.0), vec3(0.5));
  float cd = sdCapsule(p, vec3(0.0, 4.5, -0.75), vec3(0.0, 4.5, 0.75), 0.2); //get Distance from a capsule
  float cyd = sdCylinder(p, vec3(-0.75, 4.5, 0.), vec3(0.75, 4.5, 0), 0.2);
  float rbd = sdRoundBox(np - vec3(0.0, 4.5, 0), vec3(0.5), 0.1);
  float coned = sdCone(p, 1.0, 3.5, 0.5);

  float d = min(sd, planeDist); //get only the min dist between the sphere dist and the plane dist (for aligned axis plane only)
  d = min(d, cd);
  d = min(d, td);
  d = min(d, bd);
  d = min(d, cyd);
  d = min(d, rbd);
  d = min(d, coned);

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
  vec3 lightPos = vec3(0, 5, 6);
  lightPos.xz += vec2(sin(u_time), cos(u_time)) * 4.0;

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

  // vec3 ro = vec3(0.0, 2.0, 0.0); //camera position (Ray Origin)
  // vec3 rd = normalize(vec3(uv.x, uv.y - 0.2, 1.0)); //Ray Direction
  //complexe camera
  vec3 ro = vec3(0, 2.5, -8);
  ro.yz *= rotate2D(-u_mouse.y+2.0 - 1.0);
  ro.xz *= rotate2D(u_time * 0.25 - u_mouse.x*6.0);
  vec3 rd = R(uv, ro, vec3(0, 2.5, 0), 0.65);

  float d = rayMarch(ro, rd); //get the distance from the sphere

  vec3 p = ro + rd * d; //get the intersection point position

  float diff = getLight(p); //diffuse

  float far = 20.0;
  d /= far; //the distance return as an unnormalized distance so we divied by a far plane distance
  color = vec3(diff);

//  color = getNormal(p); debug normal
  gl_FragColor = vec4(color, 1.0);
}
