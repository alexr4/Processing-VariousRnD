void setup() {
  size(500, 500, P2D);
  smooth(8);
  frameRate(60);
  initFFMPEG(g);
}

void draw() {
  float x = noise(millis() * 0.001) * width;
  float y = noise(1000 + millis() * 0.001) * height;
  
  background(0);
  noStroke();
  ellipse(x, y, 100, 100);
  
  exportVideo();
}

void keyPressed() {
  if (key == 'e') {
    startExport();
  }
}
