import peasy.*;

PeasyCam cam0, cam1, cam2;
PGraphics buff0, buff1, buff2;

void setup() {
  size(1500, 500, P3D);
  
  //create 3 camera, each per buffer
  cam0 = new PeasyCam(this, 0, 0, 0, 250);
  cam1 = new PeasyCam(this, 0, 0, 0, 250);
  cam2 = new PeasyCam(this, 0, 0, 0, 250);

  //create 3 buffer
  buff0 = createGraphics(width/3, height, P3D);
  buff1 = createGraphics(width/3, height, P3D);
  buff2 = createGraphics(width/3, height, P3D);
}

void draw() {
   
  //Switch between cam 0, 1, 2 according to mouse position and return the active cam for each buffer
  PeasyCam cam = getActiveCam();

  //apply the matrix to each buffer
  applyMatrix(cam0, cam1, cam2);
  
  //draw each buffer
  drawBuffer(buff0, color(255, 0, 0));
  drawBuffer(buff1, color(0, 255, 0));
  drawBuffer(buff2, color(0, 0, 255));
  
  //display buffer into HUD of active cam
  cam.beginHUD();
  image(buff0, 0, 0);
  image(buff1, buff0.width, 0);
  image(buff2, buff0.width * 2, 0);
  cam.endHUD();
}

PeasyCam getActiveCam() {
   if (mouseX >= 0 && mouseX <= width/3) {
    cam0.setActive(true);
    cam1.setActive(false);
    cam2.setActive(false);
    return cam0;
  } else if (mouseX >=  width/3 && mouseX< width/3 *2) {
    cam0.setActive(false);
    cam1.setActive(true);
    cam2.setActive(false);
    return cam1;
  } else {
    cam0.setActive(false);
    cam1.setActive(false);
    cam2.setActive(true);
    return cam2;
  }
}

void applyMatrix(PeasyCam cam0, PeasyCam cam1, PeasyCam cam2) {
    cam0.getState().apply(buff0);
    cam1.getState().apply(buff1);
    cam2.getState().apply(buff2);
}

void drawBuffer(PGraphics buff, color c) {

  buff.beginDraw();
  buff.background(0);
  buff.lights();
  buff.fill(c);
  buff.box(100);
  buff.endDraw();
}
