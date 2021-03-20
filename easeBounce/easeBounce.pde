import fpstracker.core.*;

PerfTracker pt;
boolean pause = false;

void setup() {
  size(1280, 720, P2D);
  smooth(8);

  Time.setStartTime(this);
  pt = new PerfTracker(this, 120);
}

void draw() {
  float maxTime = 1000;
  Time.update(this, pause);
  Time.computeTimeAnimation(Time.time, maxTime);
  
  float eased = easeOutElastic(Time.normTime, 25, 0.05);
  float size = eased * height * 0.25;
  background(20);
  
  ellipse(width/2, height/2, size, size);

  pt.display(0, 0);
}

float easeInElastic(float t, float bounceLoop, float bounceForce) {
  return abs((bounceForce * t / (--t) * sin(bounceLoop * t)));
}

float easeInElastic(float t) {
  return abs((0.05 * t / (--t) * sin(25 * t)));
}

float easeOutElastic(float t, float bounceLoop, float bounceForce) {
  return abs((bounceForce - bounceForce / t) * sin(bounceLoop * t) + 1);
}

float easeOutElastic(float t) {
  return abs((0.05 - 0.05 / t) * sin(25 * t) + 1);
}

float easeInOutElastic(float t, float bounceLoop, float bounceForce) {
  return (t -= .5) < 0 ? (bounceForce + .01 / t) * sin(bounceLoop * t) : (bounceForce - .01 / t) * sin(bounceLoop * t) + 1;
}
