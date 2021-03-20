import fpstracker.core.*;
import gpuimage.core.*;

PerfTracker ptt;

int nbCol = 3;
float colWidth;

PGraphics backBuffer;
Filter sdfBackground;
Filter blur;
PGraphics shadowBuffer;
PGraphics finalBuffer;
PShader lighting;
int bufferWidth = 500;
int bufferHeight = 500;
float hypothenuse;

boolean created;
int seed;
ArrayList<Ray> rayList;


void settings() {
  size(bufferWidth * nbCol, bufferHeight, P2D);
  colWidth = (width/(float)nbCol);
  smooth(8);
}

void setup() {
  ptt = new PerfTracker(this, 100);
  // sdfBackground = new Filter(this, bufferWidth, bufferHeight);
  blur = new Filter(this, bufferWidth, bufferHeight);

  backBuffer = createGraphics(500, 500, P2D);
  shadowBuffer = createGraphics(500, 500, P2D);
  finalBuffer = createGraphics(500, 500, P2D); 
  lighting = loadShader("lighting.glsl");
  backBuffer.smooth(8);
  shadowBuffer.smooth(8);

  generateBackground(backBuffer, seed);
  backBuffer.loadPixels();

  //sdfBackground.getSignedDistanceField(backBuffer, 5);
  //sdfBackground.getBuffer().loadPixels();

  colorMode(HSB, 360, 100, 100, 100);
  rayList = new ArrayList<Ray>();
  int nbRay = 500;
  float eta = TWO_PI/nbRay;
  hypothenuse = sqrt(bufferWidth * bufferWidth + bufferHeight * bufferHeight);
  for (int i=0; i<nbRay; i++) {
    PVector dir = PVector.fromAngle(i * eta);
    Ray ray = new Ray(new PVector(), dir, hypothenuse, new PVector(bufferWidth, bufferHeight));
    rayList.add(ray);
  }


  lighting.set("resolution", (float)width, (float)height);
  lighting.set("shadowMap", shadowBuffer);
}

void draw() {
  background(240);

  generateBackground(backBuffer, seed);
  backBuffer.loadPixels();
  //sdfBackground.getSignedDistanceField(backBuffer, 5);
  //sdfBackground.getBuffer().loadPixels();

  //computation
  //PVector loc = new PVector(mouseX % colWidth, mouseY);

  float eta = frameCount * 0.01;
  float radius = backBuffer.width * 0.25;
  PVector loc = new PVector(cos(eta) * radius + backBuffer.width * 0.5, sin(eta) * radius + backBuffer.height * 0.5);


  int skipper = 10;
  for (int i=0; i<=rayList.size(); i++) { 
    int index = i % (rayList.size());
    int previous = rayList.size()-1;
    if (i>skipper) {
      previous = (i-skipper) % (rayList.size());
    } else {
      previous = (rayList.size()+i+skipper) % (rayList.size());
    }
    int next = (i+skipper) % (rayList.size());

    Ray r = rayList.get(index);
    Ray p = rayList.get(previous);
    Ray n = rayList.get(next);

    r.updateRay(loc);
    r.projectToFindCollision(backBuffer, 100);
    r.defineSkipped(p, n);
  }

  //get unskippedRay Only
  ArrayList<Ray> frayList = new ArrayList<Ray>();
  for (Ray ray : rayList) {
    if (!ray.skipped) {
      frayList.add(ray);
    }
  }

  //compute sahdow buffer
  shadowBuffer.beginDraw();
  shadowBuffer.background(0);
  shadowBuffer.noStroke();
  shadowBuffer.fill(255);
  shadowBuffer.beginShape(TRIANGLE_FAN);
  shadowBuffer.vertex(loc.x, loc.y);
  for (int i=0; i<=frayList.size(); i++) {
    int index = i % (frayList.size());
    Ray r = frayList.get(index);
    shadowBuffer.vertex(r.ray.x, r.ray.y);
  }
  shadowBuffer.endShape(CLOSE);
  shadowBuffer.endDraw();

  //filter the shadowmap
  blur.getGaussianBlurHigh(shadowBuffer, 2.0);

  //compute lighted final buffer
  lighting.set("light", loc.x/(float)finalBuffer.width, loc.y/(float)finalBuffer.height);
  lighting.set("shadowMap", blur.getBuffer());
  lighting.set("intensity", noise(frameCount * 0.25) * 0.5 + 0.5);
  finalBuffer.beginDraw();
  finalBuffer.background(0);
  finalBuffer.shader(lighting);
  finalBuffer.image(backBuffer, 0, 0);
  finalBuffer.endDraw();

  image(backBuffer, 0, 0);
  image(blur.getBuffer(), colWidth * 1.0, 0);
  image(finalBuffer, colWidth * 2.0, 0);

  //display ray;
  displayPoint(g, loc, 10, 1);
  ptt.display(0, 0);
}

void keyPressed() {
  switch(key) {
  case 'g' : 
    seed = frameCount;
    generateBackground(backBuffer, seed);
    //sdfBackground.getSignedDistanceField(backBuffer, 25);
    backBuffer.loadPixels();
    //sdfBackground.getBuffer().loadPixels();
    break;
  }
}
