import processing.video.*;
import gpuimage.core.*;
import gpuimage.utils.*;
import fpstracker.core.*;

PerfTracker pt;

Capture cam;

PingPongBuffer ppb;
Filter ofFilters;
PShader of;
int w_, h_;
int w = 1920;
int h = 1080;
float aspectRatio;
int nbTexture = 2;

void settings() {
  aspectRatio = (float)w / (float)h;
  w_ = 480;
  h_ = floor(w_ / aspectRatio);
  size(w_ * nbTexture, h_, P2D);
}

void setup() {
  pt = new PerfTracker(this, 120);
  
  String[] cameras = Capture.list();
  cam = new Capture(this, cameras[161]);
  cam.start();

  ppb = new PingPongBuffer(this, w, h, 8, P2D);
  ofFilters = new Filter(this, w, h);
  of = loadShader("OpticalFlow.glsl");
  of.set("offsetInc", 0.01);
  of.set("lambda", 0.001);
  of.set("scale", 1.5, 1.5);
  
  frameRate(30);
}

void draw() {
  background(127);
  computeOpticalFlow();

  image(cam, 0, 0, w_, h_);
  image(ofFilters.getBuffer(), w_, 0, w_, h_);
  
  pt.display(0, 0);
}

void computeOpticalFlow() {
  ppb.dst.beginDraw();  
  ppb.dst.set(0, 0, cam);
  ppb.dst.endDraw();

  of.set("previousFrame", ppb.getSrcBuffer());
  ofFilters.getCustomFilter(ppb.getDstBuffer(), of);
  ofFilters.getGaussianBlurUltraHigh(ofFilters.getBuffer(), 5.0);

  ppb.swap();//Swap the buffer for the next loop
}

PVector getFlowDirection(color c) {
  int a = c >> 24 & 0xFF; 
  int r = c >> 16 & 0xFF; 
  int g = c >> 8 & 0xFF; 
  int b = c & 0xFF;
  float nr = norm(r, 0, 255);
  float ng = norm(g, 0, 255);
  float nb = norm(b, 0, 255);
  float na = norm(a, 0, 255);
  PVector dir = new PVector();

  float x = nr + ng * -1;
  float y = nb;// + na * -1;
  if (na > 0.9) {
    y = nb * -1;
  }
  //y *= -1.0; //invert y to have proper movement

  dir = new PVector(x, y);
  if (dir.mag() > 0.01) {
    return  dir;
  } else {
    return new PVector();
  }
}

void captureEvent(Capture c) {
  c.read();
}
