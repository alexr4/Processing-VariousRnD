class MCVP5Sim implements MovieEvent {

  MCVP5Sim() {
  }

  @Override void playEvent() {
    println("MCVP5Sim on play");
  }

  @Override void pauseEvent() {
    println("MCVP5Sim on pause");
  }

  @Override void stopEvent() {
    println("MCVP5Sim on stop");
  }
}
