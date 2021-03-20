//based on : https://forum.processing.org/one/topic/how-to-make-perlin-noise-loop

void setup() {
  size(500, 500, P2D);
  smooth(8);
}

void draw() {
  background(220);

  int res = 2;
  int margin = 20;
  int steps = (width - margin * 2) / res;
  float noiseInc = 0.25;
  float timeInc = frameCount * 0.001;
  float minHeight = 0;
  float maxHeight = (height - margin *2) * 0.95;
  
  stroke(20);
  float last = 0;
  float first = 0;
  for (int i=0; i<steps; i++) {
    float animi = (i + frameCount) % steps;
    float ni = (float)animi/(float)steps;
    float eta = TWO_PI * ni;
    float noise = noise(sin(eta) * noiseInc + noiseInc + timeInc,
      cos(eta) * noiseInc + noiseInc + timeInc,
      timeInc
      );
    float y = minHeight + (maxHeight - minHeight) * noise;
    float x = margin + i * res;
    last = (i == steps - 1) ? y : last;
    first = (i == 0) ? y : first;

    line(x, height - margin, x, height - y);
  }
  stroke(255, 0, 0);
  line(margin, height - first, width-margin, height - last);
}
