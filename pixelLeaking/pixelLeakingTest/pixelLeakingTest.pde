import gpuimage.core.*;
import fpstracker.core.*;

PerfTracker perftracker;
Filter filter;
PImage src;
PGraphics imgFiltered;
PShader pixelleak;
float inc;

void settings() {
  src = loadImage("adult-art-blur-1033797.jpg");
  src.resize(int(src.width * 0.25), int(src.height * 0.25));
  //size(int(src.width * 0.25), int(src.height * 0.25), P2D);
  size(src.width, src.height, P2D);
}

void setup() {
  perftracker = new PerfTracker(this, 100);
  //perftracker.pause(TrackerType.MILLIS);
  //perftracker.pause(TrackerType.MEMORY);

  pixelleak = loadShader("pixelleakwave.glsl");
  pixelleak.set("resolution", (float) src.width, (float) src.height);
  filter = new Filter(this, src.width, src.height);
  frameRate(60);
  surface.setLocation(0, 0);
}

void draw() {
  float maxTime = 4000.0;
  float time = (millis() % maxTime) / maxTime;
  float timeAnimation = millis() / 1000.0;
  pixelleak.set("leaklength", noise(frameCount * 0.0025) * 250);
  pixelleak.set("threshold",noise(millis() * 0.0001, inc, frameCount * 0.001));
  pixelleak.set("thresholdGap", noise(frameCount * 0.001, millis() * 0.0001, inc) * 0.1);
  pixelleak.set("angle",-0.0);
  pixelleak.set("time", timeAnimation);
  pixelleak.set("damping", 0.1);

  imgFiltered = filter.getCustomFilter(src, pixelleak);


  image(imgFiltered, 0, 0, width, height);

  inc += 0.0025;

  perftracker.display(0, 0);
  //perftracker.displayAll(width - perftracker.getWidth(), 0);
  perftracker.displayOnTopBar("GLSL Pixel Leaking");
  fill(50);
  text(perftracker.toString(), width - 220, 20, 200, 500);
  text(perftracker.toStringMinify(), width - 220 * 2.15, 20, 200, 500);

  if (frameCount == 5) {
    imgFiltered.save("test.jpg");
  }
}
