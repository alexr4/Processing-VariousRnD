/*
Various 1D noise functions from : https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
*/
import fpstracker.core.*;

PerfTracker pt;

void setup() {
  size(250, 60);
  pt = new PerfTracker(this, 120);
}

void draw() {
  background(0);
  pt.display(0, 0);
  
  float noise = noiseMcGuire(millis() * 0.001);
  text(noise, 110, 20);
  
  ellipse(110 + noise * (width - 110), 30, 10, 10);
}

//return fractional part of a number
float fract(float n){
  return abs((int) n - n);
}

//some new RND function
float rand(float n){
  return fract(sin(n) * 43758.5453123);
}

float noiseGeneric(float p){
  float fl = floor(p);
  float fc = fract(p);
  
  float start = rand(fl);
  float end = rand(fl + 1.0);
  return start + (end - start) * fc;
}

float hash(float n) { return fract(sin(n) * 1e4); }


float noiseMcGuire(float x) {
  float i = floor(x);
  float f = fract(x);
  float u = f * f * (3.0 - 2.0 * f);
  float start = hash(i);
  float end = hash(i + 1.0);
  return start + (end - start) * u;
}
