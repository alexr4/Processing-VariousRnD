import fpstracker.core.*;
import com.walker.devolay.*;
import java.nio.*;
import com.jogamp.opengl.GL2GL3;
PerfTracker pt; //tracker de performance

int scale = 2;
int imgWidth = 1920*scale;
int imgHeight = 1080*scale;
DevolaySender sender;
DevolayVideoFrame videoFrame;
ByteBuffer data;
IntBuffer pixelBuffer;
PGL pgl;
PGraphics test;

void settings() {
  size(1280, 720, P3D);
}

void setup() {
  pt = new PerfTracker(this, 120);
  //smooth(8);
  Devolay.loadLibraries();
  // Create the sender using the default settings, other than setting a name for the source.
  sender = new DevolaySender("My NDI Sender");
  test = createGraphics(imgWidth, imgHeight, P3D);
  test.smooth(8);
  
  
  // Get PGL reference and call the modified loadPixels once
  pgl = ((PGraphicsOpenGL)test).beginPGL();
  
  

  data = ByteBuffer.allocateDirect(imgWidth * imgHeight * 4);
  pixelBuffer = data.asIntBuffer();
  // Create a video frame
  videoFrame = new DevolayVideoFrame();
  videoFrame.setResolution(imgWidth, imgHeight);
  videoFrame.setFourCCType(DevolayFrameFourCCType.BGRA);
  videoFrame.setFormatType(DevolayFrameFormatType.PROGRESSIVE);
  videoFrame.setData(data);
  videoFrame.setFrameRate(300, 1);
  frameRate(1000);
}

void draw() {
  test.beginDraw();
  test.background(0);
  test.scale(1, -1, 1);
  test.translate(0, -test.height);
  test.pushMatrix();
  test.translate(test.width/4, test.height/2, -200);
  test.rotate(frameCount * 0.01 * scale, 0.5, 0.5, 0.0);
  test.fill(255, 0, 0, 127);
  test.stroke(20);
  test.box(150);
  test.rectMode(CENTER);
  test.rect(0, 0, 200, 200);
  test.popMatrix();
  test.pushMatrix();
  test.translate(test.width/2, test.height/2, -200);
  test.rotate(frameCount * 0.01 * scale, 0.5, 0.5, 0.0);
  test.fill(0, 255, 0, 127);
  test.stroke(20);
  test.box(150);
  test.rectMode(CENTER);
  test.rect(0, 0, 200, 200);
  test.popMatrix();
  test.pushMatrix();
  test.translate(test.width/4*3, test.height/2, -200);
  test.rotate(frameCount * 0.01 * scale, 0.5, 0.5, 0.0);
  test.fill(0, 0, 255, 127);
  test.stroke(20);
  test.box(150);
  test.rectMode(CENTER);
  test.rect(0, 0, 200, 200);
  test.popMatrix();
  test.fill(255);
  test.textSize(40);
  test.textAlign(CENTER);
  test.text("time: "+round(millis()/1000.0)+"s Frame: "+frameCount, imgWidth/2, imgHeight/2);
  
  
  // pixelBuffer = IntBuffer.wrap(test.pixels = new int[test.width * test.height]);
  
  pgl = ((PGraphicsOpenGL)test).beginPGL();
  pgl.readPixels(0, 0, imgWidth, imgHeight, GL2GL3.GL_BGRA, PGL.UNSIGNED_BYTE, pixelBuffer);
  test.endPGL();
  test.endDraw();


  sender.sendVideoFrameAsync(videoFrame);
  pixelBuffer.rewind();
  // background(255, 0, 0);
  image(test, 0, 0, width, height);
  // ellipse(width/2, height/2, 100, 100);
  
  pt.display(0, 0);
}

@Override public void exit() {
  // Destroy the references to each. Not necessary, but can free up the memory faster than Java's GC by itself
  videoFrame.close();
  sender.close();
  super.exit();
}
