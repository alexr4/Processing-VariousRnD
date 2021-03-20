

PImage tex;
PGraphics buffer;
PShader bilateral;

void settings() {
  size(512 * 2, 424, P3D);
}

void setup() {

  tex = loadImage("KinectScreenshot-BodyIndex-09-43-19.png");
  tex.loadPixels();

  buffer = createGraphics(512, 424, P2D);
  bilateral = loadShader("bilateral.glsl");

}

void draw() {
  background(0);

  

  bilateral.set("sketchSize", (float)buffer.width, (float)buffer.height);


  buffer.beginDraw();
  buffer.background(0);
  buffer.shader(bilateral);
  buffer.image(tex, 0, 0, buffer.width, buffer.height);
  buffer.endDraw();


  image(tex, 0, 0);
  image(buffer, 512 * 1, 0);


  noStroke();
  fill(255);
  text(frameRate, 50, height - 50);
}

void keyPressed(){
  save("bilateral.png");
}
