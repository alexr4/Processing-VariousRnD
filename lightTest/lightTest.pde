/* READ ME
 this skecth is a Lights class implementation. 
 The main goeal is to creat lights object derivated from processing with debuger capabilities
 
 LIGHTS TYPE :
 X  → ambientLight(R, G, B, X, Y, Z) Ambient light is global ,illumination of the scene (X, Y, Z) is not necessary
 X  → lights() default P5 light environmentr using :
 ambientLight(128, 128, 128), 
 directionalLight(128, 128, 128, 0, 0, -1)
 lightFalloff(1, 0, 0)
 lightSpecular(0, 0, 0)
 X  → pointLight(R, G, B, X, Y, Z)
 → spotLight(R, G, B, X, Y, Z, DirX, dirY, dirZ, angle, concentration)
 X  → directionalLight(R, G, B, DirX, dirY, dirZ)
 
 //Light component
 lightSpecular(R, G, B) set the RGB of the specular of the light
 lightFalloff(constant, linear, quadratic) falloff rate of the light (point, dir and spot) d = distance from light position to vertex position
 falloff = 1 / (CONSTANT + d * LINEAR + (d*d) * QUADRATIC);
 */


import peasy.*;

PeasyCam c;

Axis3D a;
Light light;
PointLight pointlight;
AmbientLight ambientlight;
DirectionLight dirlight;
SpotLight spotlight;

ArrayList<Light> lightList;

void setup() {
  size(500, 500, P3D);
  c = new PeasyCam(this, 0, 0, 0, 150);
  a = new Axis3D(100);
  initLight();

  lightList = new ArrayList<Light>();
  lightList.add(light);
  lightList.add(pointlight);
  lightList.add(ambientlight);
  lightList.add(dirlight);
  lightList.add(spotlight);
}

void initLight() {
  light = new Light();
  pointlight = new PointLight(new PVector(25, -25, 25), color(255, 0, 0), color(255, 240, 240));
  ambientlight = new AmbientLight(color(0, 0, 75));
  dirlight = new DirectionLight(new PVector(random(1), random(1), random(1)), color(0, 255, 0), color(200, 255, 200));
  spotlight = new SpotLight(new PVector(0, 0, 100), PVector.sub(new PVector(), new PVector(0, 0, -1)), color(255), color(255));
}

void keyPressed() {
  initLight();
}

void draw() {
  background(20);

  for (Light l : lightList) {
    l.displayLight();
    if (l.KIND == DIRECTIONNALLIGHT) {
      pushMatrix();
      translate(0, -50, 50);
      l.showDebugLight();
      popMatrix();
    } else {
      l.showDebugLight();
    }
    println(l.getClassType());
  }


  a.drawAxis("RVB");
  noStroke();
  sphere(25);
}