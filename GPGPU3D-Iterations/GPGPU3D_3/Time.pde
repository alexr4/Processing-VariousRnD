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
