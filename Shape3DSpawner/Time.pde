static class Time {
  static private float deltaTime;
  static private float lastTime = 0;
  static private float time;
  static private boolean pause;

  static private void update(PApplet context_, boolean pause_) {
    pause = pause_;
    float actualTime = context_.millis();
    if (!pause) deltaTime = actualTime - lastTime;
    lastTime = actualTime;
    if (!pause) time += deltaTime;
  }
}

boolean inout;
boolean hasPassed;
void modTime(float modTarget) {
  int nTime = ((int)Time.time/1000);
  int nModTarget = ((int)modTarget/1000);
  int modTime = nTime % nModTarget;
  if (modTime == 0) {
    if (hasPassed == false) {
      hasPassed = true;
      if (inout) {
        initNode();
      }
      inout = !inout;
    }
  } else {
    hasPassed = false;
  }
}
