import gpuimage.core.*;
import processing.video.*;

Movie movie;
Filter filter;
PImage src;
PShader pixelleak;
float inc;

void settings() {
  //src = loadImage("adult-art-blur-1033797.jpg");
  // src.resize(int(src.width * 0.25), int(src.height * 0.25));
  //size(int(src.width * 0.25), int(src.height * 0.25), P2D);
  // size(src.width, src.height, P2D);
  size(1280, 720, P2D);
}

void setup() {
  movie = new Movie(this, "Skate2.mp4");

  pixelleak = loadShader("pixelleak.glsl");
  pixelleak.set("resolution", (float) 1920.0, (float) 1080.0);
  filter = new Filter(this, 1920, 1080);

  movie.loop();
}

void draw() {
  if (movie.available() == true) {
    movie.read();
    float maxTime = 4000.0;
    float time = (millis() % maxTime) / maxTime;
    float timeAnimation = millis() / 1000.0;
    float nMouseX = norm(mouseX, 0, width);
    
    pixelleak.set("leaklength", noise(frameCount * 0.0025) * 500);
    pixelleak.set("threshold", noise(millis() * 0.0001, inc, frameCount * 0.001));
    pixelleak.set("thresholdGap", noise(frameCount * 0.001, millis() * 0.0001, inc) * 0.1);
    pixelleak.set("angle", 0.0);
    pixelleak.set("time", timeAnimation);
    pixelleak.set("damping", 0.15);//nMouseX);

    filter.getCustomFilter(movie, pixelleak);

    image(filter.getBuffer(), 0, 0, width, height);

    surface.setTitle(round(frameRate) + "FPS");
    inc += 0.0025;
  }



  //if(frameCount == 5)
  // imgFiltered.save("pixelleak.png");
}
