//--sketch=D:/_DEV/RnD-Various/Depth/getDepthBuffer --output=D:/_DEV/RnD-Various/Depth/getDepthBuffer\_OUT  --force --present

import java.nio.*;
import peasy.*;

PeasyCam cam;
PGraphics b;
PImage depth;
FloatBuffer depthBuffer;
int scaler = 2;

void settings () {
  int scale = 3;
  size(1920/scale, 1080/scale * 2, P3D);
}

void setup() {
  cam = new PeasyCam(this, 500);

  b = createGraphics(1920, 1080, P3D);
  b.smooth(8);
  b.hint(ENABLE_BUFFER_READING);//enable this to get buffer reading for multisample buffers
  depth = createImage(b.width/scaler, b.height/scaler, RGB);
  depth.loadPixels();

  depthBuffer = ByteBuffer.allocateDirect(b.width * b.height * 4).order(ByteOrder.nativeOrder()).asFloatBuffer();
}  

void draw() {
  b.beginDraw();
  b.background(0);
  b.lights();
  b.rotateY(millis() * 0.001);
  b.noStroke();
  b.fill(255);
  b.box(100);
  getDepthValue(b); //get the depth before the end draw if you want valid data
  b.endDraw(); 

  cam.getState().apply(b);

  cam.beginHUD();
  image(b, 0, height/2, width, height/2);
  image(depth, 0, 0, width, height/2);
  cam.endHUD();

  surface.setTitle("FPS: "+frameRate);
}

void getDepthValue(PGraphics b) {
  PGL pgl = ((PGraphicsOpenGL)b).beginPGL();

  pgl.readPixels(0, 0, b.width, b.height, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);

  int di = 0;
  for (int y=0; y<b.height; y +=scaler) {
    for (int x=0; x<b.width; x +=scaler) {
      //println(x, y);
      int si = x + y * b.width;
      depth.pixels[di] = color(depthBuffer.get(si) * 255);
      di++;
      //println(depthValue);
    }
  }
  depth.updatePixels();
  depthBuffer.clear();
  b.endPGL();
}
