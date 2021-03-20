int w = 512;
int h = 512;

PShader lutGen;
PGraphics LUT;

void settings() {
  size(w, h, P2D);
}

void setup() {
  LUT = createGraphics(w, h, P2D);
  lutGen = loadShader("LutGen.glsl");
  lutGen.set("resolution", (float) width, (float) height);
  println(width, height);
}

void draw() {
  LUT.beginDraw();
  LUT.background(0);
  LUT.shader(lutGen);
  LUT.rect(0, 0, width, height);
  LUT.endDraw();
  
  imageMode(CENTER);
  image(LUT, width/2, height/2);
  
}

void keyPressed(){
  if(key == 's'){
    LUT.save("LUT_src.tif");
  }
}