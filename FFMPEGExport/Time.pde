class ControlledTime {
  public float deltaTime;
  private float lastTime = 0;
  public float startTime = 0;
  public float time;
  private boolean pause;

  public float modTime, normTime, timeLoop;

  ControlledTime(){}

  private void update(boolean pause_) {
    pause = pause_;
    float actualTime = millis() - startTime;
    if(!pause) deltaTime = actualTime - lastTime;
    lastTime = actualTime;
    if(!pause) time += deltaTime;
  }

  public void computeTimeAnimation(float maxTime){
    modTime = floor(time % maxTime);
    normTime = modTime / maxTime;
    timeLoop = floor(time / maxTime);
  }

  public void setStartTime(){
    startTime = millis();
  }

  public void resetTimeForExport(){
    startTime = millis();
    modTime = 0;
    normTime = 0;
    timeLoop = 0;
  }
}
