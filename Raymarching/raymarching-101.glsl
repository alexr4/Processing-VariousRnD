//Tutorial from The Art of Code: https://www.youtube.com/watch?v=PGtv-dBi2wE
#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution; // size of the preview
uniform vec2 u_mouse; // cursor in normalized coordinates [0, 1]
uniform float u_time; // clock in seconds

#define MAX_STEPS 100 //max iteration on the marching loop
#define MAX_DIST 100. //maximum distance from camera
#define SURFACE_DIST 0.01 // minimum distance for a Hit

float getDist(vec3 p){
  vec4 s = vec4(0, 1, 6, 1); //sphere X,Y,Z,R

  float sphereDist = length(p - s.xyz) - s.w; //get the distance frome the sphere
  float planeDist = p.y; //get the distance from the ground

  float d = min(sphereDist, planeDist); //get only the min dist between the sphere dist and the plane dist (for aligned axis plane only)
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

void main(){
  vec2 uv =  (gl_FragCoord.xy-0.5 * u_resolution.x) / u_resolution.y;
  // The above line is a quicker way to set the uv origin at the center of the screen (like the line below)
  // vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  // uv -= 0.5;
  vec3 color = vec3(0);

  vec3 ro = vec3(0.0, 1.0, 0.0); //camera position (Ray Origin)
  vec3 rd = normalize(vec3(uv.x, uv.y, 1.0)); //Ray Direction

  float d = rayMarch(ro, rd); //get the distance from the sphere
  vec3 p = ro + rd * d; //get the intersection point position

  float diff = getLight(p); //diffuse

  //d /= 6.0; //the distance return as an unnormalized distance so we divied by a far plane distance
  color = vec3(diff);

//  color = getNormal(p); debug normal
  gl_FragColor = vec4(color, 1.0);
}
