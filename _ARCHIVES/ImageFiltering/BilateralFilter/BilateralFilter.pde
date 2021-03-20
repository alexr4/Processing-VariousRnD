PShader bilateral;
PGraphics buffer;
PImage src;
String shaderName;


void settings() {
  src = loadImage("KinectScreenshot-BodyIndex-09-43-19.png");
  size(src.width * 2, src.height, P2D);
}
void setup() {
  shaderName = "bilateral";
  buffer = createGraphics(src.width, src.height, P2D);
  bilateral = loadShader(shaderName+".glsl");
  bilateral.set("resolution", (float)src.width, (float) src.height);
}

void draw() {
  //compute bilateral Filter
  filter(buffer, src, bilateral);

  image(src, 0, 0);
  image(buffer, src.width, 0);

  surface.setTitle("frameRate : "+round(frameRate)+" resolution : "+width+"*"+height);
}

void filter(PGraphics out, PImage in, PShader filter) {
  out.beginDraw();
  out.shader(filter);
  out.image(in, 0, 0, out.width, out.height);
  out.endDraw();
}

void keyPressed() {
  save(shaderName+"_"+round(frameRate)+"FPS.png");
}