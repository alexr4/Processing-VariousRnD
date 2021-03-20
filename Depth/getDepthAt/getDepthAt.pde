import java.nio.*;
import peasy.*;
PeasyCam cam;
PGraphics b;

void settings () {
  size(500 * 1, 500, P3D);
}

void setup() {
  b = createGraphics(width, height, P3D);
  b.hint(ENABLE_BUFFER_READING);//enable this to get buffer reading for multisample buffers
  
}

void draw() {
  b.beginDraw();
  b.background(0);
  b.lights();
  b.translate(width/2, height/2);
  b.rotateY(millis() * 0.001);
  b.noStroke();
  b.fill(255);
  b.box(100);
  float d = getDepthValue(b, mouseX, mouseY); //get the depth before the end draw if you want valid data
  b.endDraw(); 
  image(b, 0, 0);
  
  
  println("depth at "+mouseX+","+mouseY+" : "+d);
  stroke(255, 0, 0);
  noFill();
  rectMode(CENTER);
  rect(mouseX, mouseY, 20, 20);
  noStroke();
  rectMode(CENTER);
  fill(d * 255);
  rect(0, 0, 100, 100);
}

public float getDepthValue(PGraphics b, int scrX, int scrY) {
    PGL pgl = ((PGraphicsOpenGL)b).beginPGL();
    FloatBuffer depthBuffer = ByteBuffer.allocateDirect(1 << 2).order(ByteOrder.nativeOrder()).asFloatBuffer();
    pgl.readPixels(scrX, b.height - scrY - 1, 1, 1, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);
    float depthValue = depthBuffer.get(0);
    println(depthValue);
    depthBuffer.clear();
    b.endPGL();
    return depthValue;
}
