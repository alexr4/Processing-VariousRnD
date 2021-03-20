import gpuimage.core.*;

Filter filter;
PImage src;
PGraphics imgFiltered;
PShader pixelleak;

void settings() {
  src = loadImage("lena.png");
  //src.resize(int(src.width * 0.15), int(src.height * 0.15));
  size(src.width * 2, src.height, P2D);
}

void setup() {
  pixelleak = loadShader("pixelleakwave.glsl");
  pixelleak.set("resolution", (float) width, (float) height);
  filter = new Filter(this, src.width, src.height);
}

void draw() {
  float maxTime = 4000.0;
  float time = (millis() % maxTime) / maxTime;
  float timeAnimation = millis() / 1000.0;
  pixelleak.set("leaklength", 250.0);//noise(frameCount * 0.01) * 250);
  pixelleak.set("threshold", norm(mouseX, 0, width));//0.75 + noise(frameCount * 0.01) * 0.05);
  pixelleak.set("angle",0.0);
  pixelleak.set("time", timeAnimation);
  imgFiltered = filter.getCustomFilter(src, pixelleak);

  image(src, 0, 0);
  image(imgFiltered, src.width, 0);

  surface.setTitle(round(frameRate) + "FPS");
}
