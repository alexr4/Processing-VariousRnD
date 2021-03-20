import fpstracker.core.*;
import gpuimage.utils.*;
import gpuimage.core.*;

PerfTracker tracker;
int w = 500;
int h = w;
PImage imgSource;

PShader reactionDiffusion;
PShader grayScale;
PingPongBuffer rdbuffer;
Filter filter;
PGraphics debugSource;
int iteration = 100;
float hyp;
float size = 5;
int minElements = 50;
int maxElements = 1000;
int nbElements;


void settings() {
  imgSource = loadImage("stencil.png");
  size(imgSource.width * 3, imgSource.height, P2D);
}

void setup() {
  tracker = new PerfTracker(this, 100);

  //loadshaders
  reactionDiffusion = loadShader("reactionDiffusion.glsl");
  grayScale = loadShader("reactionDiffusionRender.glsl");

  rdbuffer = new PingPongBuffer(this, w, h, P2D);
  rdbuffer.enableTextureMipmaps(false);
  rdbuffer.setFiltering(3);
  rdbuffer.noSmooth();

  filter = new Filter(this, w, h);
  debugSource = createGraphics(w, h, P2D);

  hyp = sqrt(pow(rdbuffer.dst.width, 2) + pow(rdbuffer.dst.height, 2)) * 0.5;
  generate();
  surface.setLocation(0, 0);
}

void draw() {

  int maxTime = 60;
  float modTime = frameCount % maxTime;
  //println(modTime);
  if (modTime == 0) {
    generate();
  }

  for (int i=0; i<iteration; i++) {
    rdbuffer.swap();
    rdbuffer.dst.beginDraw();
    rdbuffer.dst.background(0);
    rdbuffer.dst.shader(reactionDiffusion);
    rdbuffer.dst.image(rdbuffer.getSrcBuffer(), 0, 0);
    rdbuffer.dst.endDraw();
  }


  grayScale.set("offset", 0.5);
  grayScale.set("thickness", 0.1);
  filter.getCustomFilter(rdbuffer.dst, grayScale);
  //filter.getThreshold(filter.getBuffer(), mouseX);


  //for(int i=0; i<1; i++)
  //filter.getDilation(filter.getBuffer());

  image(debugSource, w * 0, 0);
  image(rdbuffer.getDstBuffer(), w * 1, 0);
  image(filter.getBuffer(), w * 2, 0);
  tracker.display(0, 0);
}

void populateFromCenter(PGraphics ctx, int nbElements, float radius, float x, float y, float size)
{
  ctx.beginDraw();
  ctx.background(255);
  //buffer.strokeWeight(10);
  ctx.noStroke();
  ctx.fill(0);
  for (int i=0; i<nbElements; i++)
  {
    float a = norm(i, 0, nbElements) * TWO_PI;
    float rndRadius = random(0, radius);
    float px = cos(a) * rndRadius + x;
    float py = sin(a) * rndRadius + y;
    ctx.ellipse(px, py, size, size);
  }

  ctx.endDraw();
}

void populateAtRandom(PGraphics ctx, int nbElements, float size)
{
  ctx.beginDraw();
  ctx.background(255);
  //buffer.strokeWeight(10);
  ctx.noStroke();
  ctx.fill(0);
  for (int i=0; i<nbElements; i++)
  {
    float px = random(ctx.width);
    float py = random(ctx.height);
    //ctx.ellipse(px, py, size, size);
    int rnd = round(random(1, 10));
    modEllipse(ctx, rnd, px, py, size);
  }

  ctx.endDraw();
}

void modEllipse(PGraphics ctx, int nbElements, float x, float y, float size) {
  for (int i=0; i<nbElements; i++)
  {
    float normi = 1.0 - (float)i/(float)nbElements;
    if (i % 2 == 0) ctx.fill(0);
    else ctx.fill(255);

    ctx.ellipse(x, y, normi * size, normi * size);
  }
}

void saveIntoSource(PGraphics ctx, PGraphics toSave) {
  ctx.beginDraw();
  ctx.background(255);
  ctx.image(toSave, 0, 0, ctx.width, ctx.height); 
  ctx.endDraw();
}

void generateNewVarToShader() {
  float dT= random(0.5, 1.0);
  float dA = random(0.65, 0.98);
  float dB = random(0.1, dA * 0.45);
  float fR = random(0.1, 0.045);
  float kR = random(0.01, 0.1);
  println(dA, dB);
  reactionDiffusion.set("dT", dT);
  //reactionDiffusion.set("dA", dA);
  //reactionDiffusion.set("dB", dB);
  //reactionDiffusion.set("feedRate", fR);
  //reactionDiffusion.set("killRate", kR);
}

void clearBuffer()
{
  rdbuffer.clear();
  filter.clear();
}

void generate() {
  size = random(5, 40);
  nbElements = round(random(minElements, maxElements));
  clearBuffer();
  float rnd = random(1.0);
  if (rnd <= 0.5) {
    //populateFromCenter(rdbuffer.dst, nbElements, hyp, rdbuffer.dst.width * 0.5, rdbuffer.dst.height*0.5, size);
    populateAtRandom(debugSource, nbElements, size);
  } else {
    debugSource.beginDraw();
    debugSource.image(imgSource, 0, 0);
    debugSource.endDraw();
  }

  saveIntoSource(rdbuffer.dst, debugSource);
  generateNewVarToShader();
}

void keyPressed() {
  switch(key) {
  case 'r' : 
    generate();
    break;
  }
}
