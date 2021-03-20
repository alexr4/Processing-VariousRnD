// Combination of Bouncy Bubbles based on code from Keith Peters
// and the SpoutSender example to create a Processing App
// that calculates object positions and then packs the 32 bit values
// into 4 channels of a regular 8-bit RGBA pixel, which is then 
// sent over Spout to TouchDesigner, where it is unpacked and the data used for drawing.
// This allows you to use the existing physics and simulation libraries within 
// Processing and send the computed data to TouchDesigner. 
/**
important: You can not use bit shit operation in glsl so this method only work for data process outside the GPU
This is why this does not work with gpuimage : https://stackoverflow.com/questions/27548216/colour-bit-wise-shift-in-opengl-shader-glsl
https://www.gamedev.net/forums/topic/442138-packing-a-float-into-a-a8r8g8b8-texture-shader/
https://stackoverflow.com/questions/18453302/how-do-you-pack-one-32bit-int-into-4-8bit-ints-in-glsl-webgl
*/


import fpstracker.core.*;
import gpuimage.utils.*;
PerfTracker pt;
FloatPacking fp;


// PImage keeps alpha channel intact, unlike other drawing methods in Processing
PImage data;

// set simulation variables
int numBalls = 200;
float spring = 0.05;
float gravity = 0.03;
float friction = -0.9;

// because the window is 16x4 for Spout, we need to define our simulation resolution
// separately as variables, since we cant use references to window size
int resX = 1280;
int resY = 720;

// make a bunch of balls
Ball[] balls = new Ball[numBalls];

int row;
int pixel_index;

void settings() {

  // Initial window size
  size(resX, resY, P2D);
}

void setup() {
  pt = new PerfTracker(this, 120);
  
  fp = new FloatPacking(this);
  frameRate(60);

  // init all the balls
  for (int i = 0; i < numBalls; i++) {
    balls[i] = new Ball(random(resX), random(resY), random(30, 70), i, balls);
  }
  println("numBalls: "+numBalls);
  noStroke();
} 

void draw() { 
  background(0);
  // intialize the texture
  data = createImage(numBalls, 4, ARGB);
  data.loadPixels();

  // iterate through the balls and calculate position and collisions
  for (Ball ball : balls) {
    ball.collide();
    ball.move();
    ball.display(g);

    // write the X position into an 8-bit RGBA pixel
    // using the pixelPacker() helper method
    // here we're writing to the first row of pixels in our 16x4 texture
    row = 0;
    pixel_index = row * numBalls + ball.id;
    color ballX = pixelPacker(ball.x);
    //println("encode x: "+ball.x);
    data.pixels[pixel_index] = ballX;


    // write the Y position into an 8-bit RGBA pixel
    // using the pixelPacker() helper method
    // here we're writing to the second row of pixels in our 16x4 texture
    row = 1;
    pixel_index = row * numBalls + ball.id;
    color ballY = pixelPacker(ball.y);
    data.pixels[pixel_index] = ballY;

    // write the radius of each ball into an 8-bit RGBA pixel
    // using the pixelPacker() helper method
    // here we're writing to the third row of pixels in our 16x4 texture
    row = 2;
    pixel_index = row * numBalls + ball.id;
    color ballDiam = pixelPacker(ball.diameter);
    data.pixels[pixel_index] = ballDiam;
  }
  
  //int to bitshift decode
  fill(0, 255, 0, 127);
  for(int i=0; i<numBalls; i++){
    int ix = i;
    int iy = i + 1 * numBalls;
    int id = i + 2 * numBalls;
    
    float x     = pixelUnpacker(data.pixels[ix]);
    float y     = pixelUnpacker(data.pixels[iy]);
    float diam  = pixelUnpacker(data.pixels[id]);
    //println(x, y, diam);
    //println("decode x (bitshift left): "+x);
    ellipse(x, y, diam * 1.1, diam * 1.1);
  }
  
  /**
  //decode with gpu image (does not work)
  float[] datas32 = fp.decodeARGB32Float(data);
  fill(255, 0, 0, 127);
  for(int i=0; i<datas32.length; i+=4){
    float x     = datas32[i] *  resX;
    float y     = datas32[i+1] * resY;
    float diam  = datas32[i+2] * 70;
    //println(x, y, diam);
    //println("decode x (gpuimage): "+x+ " src: "+datas32[i]);
    ellipse(x, y, diam, diam);
  }
  */
  

  // send the texture over Spout
  //spout.sendTexture(data);
  int iw = data.width;
  int ih = data.height;
  int ix = 0;
  int iy = height-data.height;
  imageMode(CORNER);
  rectMode(CORNER);
  fill(127);
  
  rect(ix, iy, iw, ih);
  image(data, ix, iy, iw, ih);

  pt.display(0, 0);
}

// class for each Ball with attribute and methods for setup, collision, and movement
class Ball {

  float x, y;
  float diameter;
  float vx = 0;
  float vy = 0;
  int id;
  Ball[] others;

  Ball(float xin, float yin, float din, int idin, Ball[] oin) {
    x = xin;
    y = yin;
    diameter = din;
    id = idin;
    others = oin;
  } 

  // calculate distance between all balls and detect collision
  void collide() {
    for (int i = id + 1; i < numBalls; i++) {
      float dx = others[i].x - x;
      float dy = others[i].y - y;
      float distance = sqrt(dx*dx + dy*dy);
      float minDist = others[i].diameter/2 + diameter/2;
      if (distance < minDist) { 
        float angle = atan2(dy, dx);
        float targetX = x + cos(angle) * minDist;
        float targetY = y + sin(angle) * minDist;
        float ax = (targetX - others[i].x) * spring;
        float ay = (targetY - others[i].y) * spring;
        vx -= ax;
        vy -= ay;
        others[i].vx += ax;
        others[i].vy += ay;
      }
    }
  }

  // calculate balls motion
  void move() {
    vy += gravity;
    x += vx;
    y += vy;
    if (x + diameter/2 > resX) {
      x = resX - diameter/2;
      vx *= friction;
    } else if (x - diameter/2 < 0) {
      x = diameter/2;
      vx *= friction;
    }
    if (y + diameter/2 > resY) {
      y = resY - diameter/2;
      vy *= friction;
    } else if (y - diameter/2 < 0) {
      y = diameter/2;
      vy *= friction;
    }
  }

  void display(PGraphics g) {
    noStroke();
    fill(255);
    ellipse(x, y, diameter, diameter);
  }
}

// this helper function uses bit shifting to take a single 32-bit float
// and convert it into four 8-bit values which can then be used for 
// the 4 colors (RGBA) of a regular Processing color
color pixelPacker(float val) {

  // bit shift val into 4 8-bit values
  int num = int(val);
  int b = (num >> 0) & 255;
  int g = (num >> 8) & 255;
  int r = (num >> 16) & 255;
  int a = (num >> 24) & 255;

  // the RGBA chans are used to return a color for the fill
  return color(r, g, b, a);
}

int pixelUnpacker(color val){
  int a = val >> 24 & 0xFF;
  int r = val >> 16 & 0xFF; 
  int g = val >> 8 & 0xFF;
  int b = val & 0xFF;
  int unpack = a << 24 | r << 16 | g << 8 | b;  
  return unpack;
}

void keyPressed(){
  for (int i = 0; i < numBalls; i++) {
    balls[i] = new Ball(random(resX), random(resY), random(30, 70), i, balls);
  }
}
