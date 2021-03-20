import fpstracker.core.*;
import gpuimage.core.*;

PerfTracker pt;
void setup() {
  size(1024, 1024, P2D);
  //instanciate PerfTracker object public PerfTracker(PApplet context, int samplingSize)
  pt = new PerfTracker(this, 100);

  PImage in = loadImage("in.png");
  PImage out = loadImage("out.png");

  Fader.setIn(this, in);
  Fader.setOut(this, out);
}

void draw() {

  float t = millis() / 1000.0;
  float nt = (t % 4.0) / 4.0;
  float nmx = 0.0;
  float margin = 50;
  if (mouseX > margin && mouseX < width-margin) {
    nmx = norm(mouseX, margin, width - margin);
  } else if (mouseX > width-margin) {
    nmx = 1.0;
  }

  Fader.glitch(this, nmx);

  image(Fader.getBuffer(), 0, 0);
}


static class Fader {
  static PGraphics in, out;
  static Filter filter;

  static public void glitch(PApplet ctx, float transition) {
    try {
      if (filter ==  null) {
        filter = new Filter(ctx, in.width, in.height);
      }
      float switchIntenisty = transition *2.0 - 1.0;
      float normIntensity = 1.0 - (abs(switchIntenisty));
      float intensity = normIntensity;// * 100.0;
      float time = ctx.millis() * 0.001;
      PGraphics tmpstart = (switchIntenisty > 0.0) ? out : in;

      filter.getGlitchInvert(tmpstart, intensity * 0.05, time, 2.0, 8.0, 0.15, 1.0, 0.25, 0.9, 0.75);
      filter.getGlitchDisplaceRGB(filter.getBuffer(), intensity * 0.25, time, 4.0, 15.0, 0.45, 0.75, 0.35, 0.154, 0.025, 0.005, 0.0);
      filter.getGlitchShiftRGB(filter.getBuffer(), intensity * 0.75, time, 1.0, 3.0, 0.65, 1.0, 0.35, 0.0, 0.005, 0.01, 0.0, 0.0, 0.015, 0.015, 0.0);
      filter.getGlitchDisplaceLuma(filter.getBuffer(), intensity, time, 2.0, 8.0, 0.5, 1.0, 0.25, 0.037, 0.01, 0.025, 0.005);
      filter.getGlitchShuffleRGB(filter.getBuffer(), intensity * 0.015, time, 2.0, 6.0, 0.4, 1.0, 0.25, 0.204, 0.06, 1.5);
      filter.getGlitchPixelated(filter.getBuffer(), intensity, time, 2.0, 8.0, 0.85, 1.0, 0.25, 0.0, 0.0, 100.0);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }

  static public void setIn(PApplet ctx, PImage src) {
    if (in == null) {
      in = ctx.createGraphics(src.width, src.height, P2D);
    }
    set(in, src);
  }

  static public void setOut(PApplet ctx, PImage src) {
    if (out == null) {
      out = ctx.createGraphics(src.width, src.height, P2D);
    }
    set(out, src);
  }

  static private void set(PGraphics buffer, PImage src) {
    buffer.beginDraw();
    buffer.image(src, 0, 0);
    buffer.endDraw();
  }


  static public PGraphics getBuffer() {
    return filter.getBuffer();
  }
}
