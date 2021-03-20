//based on : https://forum.processing.org/one/topic/how-to-make-perlin-noise-loop

void setup() {
  size(500, 500, P2D);
  smooth(8);
  background(220);
}

void draw() {
  fill(220, 10);
  noStroke();
  rect(0, 0, width, height);
  translate(width/2, height/2);
  rotate(millis() * 0.0001);

  float maxRadius  = width * 0.45;
  float minRadius  = width * 0.15;

  int resAngle = 4;
  int steps = 360 / resAngle;
  float noiseInc = 0.5;
  float timeInc = frameCount * 0.005;
  float breath = sin(millis() * 0.001) * 0.5 + 0.5;

  beginShape();
  fill(20);
  noStroke();
  for (int i=0; i<steps; i++) {
    float ni = (float)i/(float)steps;
    float eta = TWO_PI * ni;
    float noise = noise(sin(eta) * noiseInc + noiseInc +  timeInc, 
      cos(eta) * noiseInc + noiseInc +  timeInc, 
      timeInc);
    float rad = minRadius + (maxRadius - minRadius) * (noise * breath);
    float x = cos(eta) * rad;
    float y = sin(eta) * rad;

    vertex(x, y);//, 4, 4);
  }
  endShape(CLOSE);
}
