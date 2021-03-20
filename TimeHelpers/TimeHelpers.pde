boolean pause;

void setup() {
  size(500, 500);
}

void draw() {
  background(0);
  Time.update(this, pause);

  float dt = Time.deltaTime;
  float t = Time.time;
  
  float maxTime = 4.0;
  float time = floor(t / 1000.0);
  float modTime = time % maxTime;
  float normTime = ((t / 1000.0) % maxTime) / maxTime;
  float timeLoop = floor(time /maxTime);
  

  textAlign(CENTER, CENTER);
  text("Millis(): "+millis(), width/2, height/2 - 20);
  text("Time.time(): "+t, width/2, height/2 + 20);
  text("Time.deltaTime(): "+dt, width/2, height/2 + 40);
  
  text("modTime: "+modTime, width/2, height/2 + 60);
  text("normTime: "+normTime, width/2, height/2 + 80);
  text("timeLoop: "+timeLoop, width/2, height/2 + 100);
}

void keyPressed() {
  pause = !pause;
}
