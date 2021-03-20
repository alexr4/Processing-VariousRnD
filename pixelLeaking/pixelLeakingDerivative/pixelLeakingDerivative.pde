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

  pixelleak = loadShader("pixelLeaking.glsl");
  pixelleak.set("resolution", (float) 1920.0, (float) 1080.0);
  filter = new Filter(this, 1920, 1080);

  movie.loop();
}

void draw() {
  if (movie.available() == true) {
    movie.read();
    
    filter.getCustomFilter(movie, pixelleak);

    image(filter.getBuffer(), 0, 0, width, height);

    surface.setTitle(round(frameRate) + "FPS");
    inc += 0.0025;
  }



  //if(frameCount == 5)
  // imgFiltered.save("pixelleak.png");
}
