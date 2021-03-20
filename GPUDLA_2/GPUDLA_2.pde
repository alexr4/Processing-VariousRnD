
import fpstracker.core.*;
import gpuimage.utils.*;
import gpuimage.core.*;


PerfTracker pt;
PingPongBuffer ppb;
PShader dla, dlaFixed;
PShader FXAA;
float dslRes = 1.0;

//design
Filter filter;
PGraphics src;
PGraphics dst;
PShader cw;


void settings() {
  size(1080, 1080, P2D);
  //fullScreen(P2D);
}

void setup() {
  smooth();

  //instanciate PerfTracker object public PerfTracker(PApplet context, int samplingSize)
  pt = new PerfTracker(this, 100);
  dla = loadShader("dla.glsl");
  initBuffer(dslRes);

  filter = new Filter(this, ppb.dst.width, ppb.dst.height);

  src = createGraphics(width, height, P2D);
  frameRate(600);
  surface.setLocation(0, 0);

  FXAA = loadShader("fxaa.glsl");
}

void draw() {
  dla.set("randomRatio", 0.9);

  ppb.swap();//Swap the buffer for the next loop
  dla.set("time", (float) millis() / 1000.0);
  ppb.dst.beginDraw(); 
  ppb.dst.clear();
  ppb.dst.blendMode(REPLACE);
  ppb.dst.shader(dla);
  ppb.dst.image(ppb.getSrcBuffer(), 0, 0);
  ppb.dst.endDraw();

  src.beginDraw();
  src.image(ppb.getDstBuffer(), 0, 0, src.width, src.height);
  src.endDraw();

  float size = 0.25;
  //dst = filter.getGaussianBlurUltraHigh(src, .5);
  //dst = filter.getChromaWarpMedium(dst, src.width/2, src.height/2, size * 0.1, (HALF_PI / 50.0) * size);
  
  //int AA = 0;
  //filter.getCustomFilter(src, FXAA);
  //for (int i=1; i<AA; i++) {
  //  filter.getCustomFilter(filter.getBuffer(), FXAA);
  //}

  //image(filter.getBuffer(), 0, 0, width, height);
  image(src, 0, 0, width, height);

  pt.display(0, 0);
}

void keyPressed() {
  if (key == 'r') initBuffer(dslRes);
  if (key == 's') ppb.getDstBuffer().save("dla_"+frameCount+".png");
}

public void initBuffer(float dslRes) {
  ppb = new PingPongBuffer(this, int(width * dslRes), int(height * dslRes), 8, P2D); //define the width and height of the PPB
  ppb.setFiltering(3);
  ppb.enableTextureMipmaps(false);

  ppb.dst.beginDraw(); 
  ppb.dst.background(0);
  ppb.dst.strokeWeight(1);
  /*for (int i=0; i<ppb.dst.width*ppb.dst.height; i++) {
   float ratio = random(1);
   if (ratio <= 0.001) {
   float x = i % ppb.dst.width;
   float y = (i - x) / ppb.dst.width;
   ppb.dst.stroke(255);
   ppb.dst.point(x, y);
   }
   }*/

  ppb.dst.stroke(255);
  ppb.dst.strokeWeight(2);
  ppb.dst.point(ppb.dst.width/2, ppb.dst.height/2);
  ppb.dst.endDraw();
  dla.set("randomDist", random(0.35, 0.55));
}
