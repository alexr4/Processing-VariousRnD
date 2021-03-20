
import fpstracker.core.*;
import gpuimage.utils.*;
import gpuimage.core.*;

PerfTracker pt;
PingPongBuffer ppb;
PShader dla;

//design
Filter filter;
PGraphics src;
PGraphics dst;
PShader cw;

PImage img;

void settings() {
  //img = loadImage("banksy-1_0.png");
  //img = loadImage("txtStroke_0.png");
  img = loadImage("voronoigraphics.tif");
  img.resize(img.width, img.height);
  size(img.width/4, img.height/4, P2D);
}

void setup() {
  smooth();

  //instanciate PerfTracker object public PerfTracker(PApplet context, int samplingSize)
  pt = new PerfTracker(this, 100);
  dla = loadShader("dla.glsl");
  initBuffer();

  filter = new Filter(this, ppb.dst.width, ppb.dst.height);
  src = createGraphics(img.width, img.height, P2D);
  cw = loadShader("chromawarpmedium.glsl");
  frameRate(120);
  surface.setLocation(0, 0);
}

void draw() {
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

  //float size = 1.0;
  //dst = filter.getChromaWarpMediumImage(src, src.width/2, src.height/2, size * 0.1, (HALF_PI / 50.0) * size);
  //dst = filter.getCustomFilter(src, cw);
  //dst = filter.getGaussianBlurUltraHighImage(src, 1.0);
  //dst = filter.getThresholdImage(dst, 100);
  //dst = filter.getGaussianBlurUltraHighImage(dst, 1.0);

  //dst = filter.getGaussianBlurUltraHighImage(src, 5.0);
  //dst = filter.getThresholdImage(dst, 150);
  // dst = filter.getGaussianBlurUltraHighImage(dst, 1.0);
  image(ppb.dst, 0, 0, width, height);

  pt.display(0, 0);
}

void keyPressed() {
  if (key == 'r') {
    initBuffer();
  } else if (key == 's') {
    ppb.dst.save("img.tif");
  }
}

public void initBuffer() {
  ppb = new PingPongBuffer(this, int(img.width * 1.0), int(img.height * 1.0), 8, P2D); //define the width and height of the PPB
  ppb.setFiltering(3);
  ppb.enableTextureMipmaps(false);

  ppb.dst.beginDraw(); 
  ppb.dst.background(0);
  ppb.dst.strokeWeight(1);
  ppb.dst.image(img, 0, 0, ppb.dst.width, ppb.dst.height);
  /*
  for (int i=0; i<ppb.dst.width*ppb.dst.height; i++) {
   float ratio = random(1);
   if (ratio <= 0.001) {
   float x = i % ppb.dst.width;
   float y = (i - x) / ppb.dst.width;
   ppb.dst.stroke(255);
   ppb.dst.point(x, y);
   }
   }
   */
  //ppb.dst.noStroke();
  //ppb.dst.fill(255);
  //ppb.dst.ellipse(ppb.dst.width/2, ppb.dst.height/2, ppb.dst.width*.25, ppb.dst.width*.25);
  // ppb.dst.stroke(255);
  // ppb.dst.strokeWeight(2);
  //ppb.dst.point(ppb.dst.width/2, ppb.dst.height/2);
  ppb.dst.endDraw();

  dla.set("randomRatio", (float) second());
}
