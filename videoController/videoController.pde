import fpstracker.core.*;
PerfTracker pt;

MovieController mc;
MCVP5Sim mcvp5;

void settings() {
  size(1280, 720, P2D);
}

void setup() {
  pt = new PerfTracker(this, 100);

  mcvp5 = new MCVP5Sim();

  mc = new MovieController(this, "02_Ready.mp4", 1920, 1080);
  mc.addListener(mcvp5);

  mc.play();
}

void draw() {
  mc.run();
  image(mc, 0, 0, width, height);

  //println(mc.route);
  pt.display(0, 0);
}

void keyPressed() {
  if (key == ' ') {
    mc.computeSnapshot();
  } else if (key == 's') {
    mc.stop();
  } else if (key == 'p') {
    mc.pause();
  } else if (key == 'm') {
    mc.play();
  } else if (key == 'r') {
    mc.replay();
  }
}
