import java.nio.*;

void settings () {
  size(500 * 1, 500, P3D);
}

void setup() {
}

void draw() {
  
  
  background(0);
  lights();
  translate(width/2, height/2);
  rotateY(millis() * 0.001);
  noStroke();
  fill(255);
  box(100);
  
  float d = getDepthValue(mouseX, mouseY);
  println("depth at "+mouseX+","+mouseY+" : "+d);
}

public float getDepthValue(int scrX, int scrY) {
    PGL pgl = beginPGL();
    FloatBuffer depthBuffer = ByteBuffer.allocateDirect(1 << 2).order(ByteOrder.nativeOrder()).asFloatBuffer();
    pgl.readPixels(scrX, height - scrY - 1, 1, 1, PGL.DEPTH_COMPONENT, PGL.FLOAT, depthBuffer);
    float depthValue = depthBuffer.get(0);
    println(depthValue);
    depthBuffer.clear();
    endPGL();
    return depthValue;
}
