import fpstracker.core.*;
import gpuimage.core.*;

PerfTracker pt;
Filter filter;
PImage source;
PShader FXAA;
boolean livecoding;

void settings() {
  source = loadImage("Beauty_1308.png");
  size(source.width*2, source.height, P2D);
}

void setup() {
  pt = new PerfTracker(this, 120);
  filter = new Filter(this, source.width, source.height);
  FXAA = loadShader("fxaa.glsl");
  livecoding = false;
}

void draw() {
  try {
    if (livecoding) {
      FXAA = loadShader("fxaa.glsl");
    }
    FXAA.set("resolution", (float)source.width, (float)source.height);

    filter.getCustomFilter(source, FXAA);
    for (int i=1; i<4; i++) {
      filter.getCustomFilter(filter.getBuffer(), FXAA);
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }

  background(0);
  image(source, 0, 0);
  image(filter.getBuffer(), width/2, 0);

  pt.display(0, 0);
  pt.displayOnTopBar("livecoding: "+livecoding);
}

void keyPressed() {
  switch(key) {
  case 'L' :
  case 'l' :
    livecoding = !livecoding;
    break;
  }
}
