// Based of D.Shiffman tutorial : https://www.youtube.com/watch?v=alhpH6ECFvQ&list=WL&index=7&t=0s
// Check all the sources in video description

import fpstracker.core.*;

PerfTracker pt;

final int N = 128;
final int scale = 7;
final int iter = 30;

boolean isLoop;
Fluid fluid;

int margin = 100;

void settings() {
  size(N * scale + margin, N * scale + margin, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);

  fluid = new Fluid(0.5, 0.75, 0.000001);

  //addRandomTurb(N*N);
}

void draw() {
  background(0);
  pushMatrix();
  translate(margin * 0.5, margin * 0.5);
  /*
  int cx = int(.5*width/scale);
   int cy = int(.5*height/scale);
   fluid.addDensity(cx, cy, 500);
   
   float t = millis() * 0.01;
   float angle = noise(t) * TWO_PI * 4;
   PVector v = PVector.fromAngle(angle);
   v.mult(0.75);
   
   fluid.addVelocity(cx, cy, v.x, v.y);
   */

  float mt = 4.0;
  float t = millis()/1000;
  float modt = t % mt;
  float normt = modt/mt;

  if (normt < 0.1) {
    if (!isLoop) {
      int rand = floor(random(N*N));
      addRandomTurb(1);//rand);
      isLoop = true;
    }
  } else {
    isLoop = false;
  }


  fluid.step();
  //fluid.renderDensity();
  //fluid.fadeDensity(1.0);
  //fluid.renderVelocity(0.01, 300.);
  fluid.renderVelocity(30.);
  fill(255);
  //text(modt, 20, 80);
  popMatrix();
  pt.display(0, 0);
}

void addRandomTurb(int nbTurb) {
  for (int i=0; i<nbTurb; i++) {
    int cx = int(random(width) / scale);
    int cy = int(random(height)/scale);
    fluid.addDensity(cx, cy, 500);

    float angle = random(TWO_PI);
    PVector v = PVector.fromAngle(angle);
    v.mult(0.75);

    fluid.addVelocity(cx, cy, v.x, v.y);
  }
}

void mousePressed() {
  // addRandomTurb(N*N);
}
/*
void mouseDragged() {
 fluid.addDensity(mouseX/scale, mouseY/scale, 100);
 float amtX = mouseX - pmouseX;
 float amtY = mouseY - pmouseY;
 fluid.addVelocity(mouseX/scale, mouseY/scale, amtX, amtY);
 }*/
