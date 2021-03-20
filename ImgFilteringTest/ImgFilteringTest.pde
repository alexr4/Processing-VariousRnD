PImage img;
boolean highq = true;

void setup() {
  size(500, 500, P3D);
  img = loadImage("test.png");
}

void draw() {
  translate(0, 0, -100);
  rotateX(QUARTER_PI);
  image(img, 0, 0, width, height);
}

void keyPressed() {
  hint(ENABLE_TEXTURE_MIPMAPS);
  switch(key) {
  case '2' : 
    ((PGraphicsOpenGL)g).textureSampling(2) ;
    break;
  case '3' : 
    ((PGraphicsOpenGL)g).textureSampling(3);
    break;
  case '4' : 
    ((PGraphicsOpenGL)g).textureSampling(4);
    break;
  case '5' : 
    ((PGraphicsOpenGL)g).textureSampling(5);
    break;
  }
  println(key);
}
