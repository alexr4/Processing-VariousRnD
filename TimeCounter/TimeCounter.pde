boolean pause;

void setup() {
  size(500, 500);
}

void draw() {
  background(0);
  Time.update(this, pause);

  float dt = Time.deltaTime;
  float t = Time.time;

  textAlign(CENTER, CENTER);
  text("Millis() : "+millis(), width/2, height/2 - 20);
  text("Time.time() : "+t, width/2, height/2 + 20);
  text("Time.deltaTime() : "+dt, width/2, height/2 + 40);
}

void keyPressed() {
  pause = !pause;
}