import fpstracker.core.*;

PerfTracker pt;
PImage img;
PGraphics sdfimg;
PShader sdfshader;
PGraphics gpusdf;
boolean isComputed = false;

void settings() {
  img = loadImage("KinectV2_bodyIndex.png");
  img.resize(1920/3, 1920/3);
  size(img.width * 3, img.height, P2D);
}

void setup() {
  pt = new PerfTracker(this, 100);

  sdfimg = createGraphics(img.width, img.height, P2D);
  sdfimg.beginDraw();
  sdfimg.background(0);
  sdfimg.endDraw();

  sdfshader = loadShader("sdfImage.glsl");
  gpusdf = createGraphics(img.width, img.height, P2D);

  img.loadPixels();
  sdfimg.loadPixels();
  surface.setLocation(0, 0);
  
  frameRate(300);
}

void draw() {
  if (!isComputed) {
    //computed once because it's too slow
    computeSDF(img, sdfimg, 25);
    isComputed = true;
  }
  //computed every frame beacause its 'insanely' fast
  computeGPUSDF(img, gpusdf, 50);
  image(img, 0, 0);
  image(sdfimg, img.width, 0);
  image(gpusdf, img.width * 2, 0);

  fill(255);
  text("source image", 20, height-40);
  fill(0);
  text("SDF CPU computed", img.width * 1 + 20, height-20);
  text("SDF GPU computed", img.width * 2 + 20, height-20);
  if (frameRate < 3) {
    println("WARNING: TOO SLOW");
    exit();
  }

  surface.setTitle("Frame: "+frameCount+" | frameRate: "+frameRate);
  pt.display(0, 0);
}

void keyPressed(){
  gpusdf.save("gpusdf.png");
}


void computeGPUSDF(PImage in, PGraphics out, int searchDistance) {
  sdfshader.set("searchDistance", searchDistance);
  sdfshader.set("resolution", (float) in.width, (float) in.height);
  out.beginDraw();
  out.shader(sdfshader);
  out.image(in, 0, 0);
  out.endDraw();
}

void computeSDF(PImage in, PGraphics out, int searchDistance) {
  float hyp = sqrt(in.width * in.width + in.height * in.height);
  for (int x=0; x<in.width; x++) {
    for (int y=0; y<in.height; y++) {
      int index = x + y * in.width;
      //distance to the closest pixel. Here start with the max distance which is the hypothenuse of the image
      float distance = hyp;

      //search coordinates x/y min/max
      int fxmin = constrain(x - searchDistance, 0, in.width);
      int fxmax = constrain(x + searchDistance, 0, in.width);
      int fymin = constrain(y - searchDistance, 0, in.height);
      int fymax = constrain(y + searchDistance, 0, in.height);

      for (int fx = fxmin; fx<fxmax; fx ++) {
        for (int fy = fymin; fy<fymax; fy ++) {
          //get the pixel
          int neiIndex = fx + fy * in.width;
          int neiRgb = in.pixels[neiIndex];
          int neiRed = (neiRgb >> 16) & 0xFF;


          if (neiRed == 255) {
            //compute the distance
            float xd = x - fx;
            float yd = y - fy;
            float d = sqrt(xd * xd + yd * yd);
            //compare the absolute distance, if smaller then replace with the new one
            if (abs(d) < distance) {
              distance = abs(d);
            }
          }
        }
      }


      distance = distance / searchDistance;
      distance = constrain(distance, 0.0, 1.0);
      out.pixels[index] = color(distance * 255.0);
    }
  }
  out.updatePixels();
}
