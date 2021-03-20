import fpstracker.core.*;
import com.walker.devolay.Devolay;
import com.walker.devolay.DevolayFrameFourCCType;
import com.walker.devolay.DevolaySender;
import com.walker.devolay.DevolayVideoFrame;
import java.awt.image.BufferedImage;
import java.nio.*;
import java.nio.ByteOrder;

PerfTracker pt; //tracker de performance

DevolaySender sender;
DevolayVideoFrame videoFrame;
long startTime;
int frameCounter;
long fpsPeriod;
ByteBuffer data;
IntBuffer intBuffer;
IntBuffer pixelBuffer;

PGraphics test;
PGraphics buffer3D;

PGL pgl;
Texture tex;
int[] pxls = new int[3840 * 2160];

void settings() {
  size(1280, 720, P3D);
}

void setup() {
  pt = new PerfTracker(this, 120);

  Devolay.loadLibraries();

  // Create the sender using the default settings, other than setting a name for the source.
  sender = new DevolaySender("My NDI Sender");
  test = createGraphics(3840, 2160, P3D);
  // test.loadPixels();
  
  
  // BGRX has a pixel depth of 4
  data = ByteBuffer.allocateDirect(test.width * test.height * 4);
  intBuffer = data.order(ByteOrder.LITTLE_ENDIAN).asIntBuffer();
  pixelBuffer = IntBuffer.allocate(test.width * test.height * 4);

  // Create a video frame
  videoFrame = new DevolayVideoFrame();
  videoFrame.setResolution(test.width, test.height);
  videoFrame.setFourCCType(DevolayFrameFourCCType.BGRA);
  videoFrame.setFormatType(DevolayFrameFormatType.PROGRESSIVE);
  videoFrame.setData(data);
  videoFrame.setFrameRate(60, 1);

  startTime = System.currentTimeMillis();

  frameCounter = 0;
  fpsPeriod = System.currentTimeMillis();
  loadPixels();
  frameRate(300);

   test.beginDraw();
    test.background(0, 255);
    test.endDraw();
    pgl = test.beginPGL();
    test.endPGL();
}

void draw() {

  test.beginDraw();
  test.background(0, 255);
  test.pushMatrix();
  test.translate(test.width/2, test.height/2, -200);
  test.rotate(frameCount * 0.01, 0.5, 0.5, 0.0);
  //test.lights();
  test.fill(127);
  test.stroke(20);
  test.box(150);
  test.rectMode(CENTER);
  test.rect(0, 0, 200, 200);
  test.popMatrix();
  
  test.fill(255);
  test.textSize(40);
  test.textAlign(CENTER);
  test.text("time: "+round(millis()/1000.0)+"s Frame: "+test, test.width/2, test.height/2);
  test.endDraw();
  
  try {
		//pgl = ((PGraphicsOpenGL)test).pgl;
    intBuffer.rewind();
    pgl.readPixels(0, 0, test.width, test.height, PGL.RGBA, PGL.UNSIGNED_BYTE, intBuffer);
  //  pixelBuffer.get(pxls, 0, pxls.length);
    //convertToARGB(pxls);
		// pgl = (PGM) this.g;
    // tex = pgl.getTexture(test);
    // tex.get(pxls);
    // // tex.getBufferPixels(pixels);
    
    // intBuffer.rewind();
    // ByteBuffer imageBuffer = ByteBuffer.allocateDirect(test.width * test.height * 4);
    // tex.copyBufferFromSource(null, imageBuffer, 3840, 2160);
    // intBuffer = imageBuffer.asIntBuffer();

    // //  test.loadPixels();
    //  intBuffer.rewind();
    //  intBuffer.put(pxls);

    //byte[] array = data.array();
  }
  catch(Exception e) {
  }
  sender.sendVideoFrameAsync(videoFrame);

  image(test, 0, 0, width, height);
  pt.display(0, 0);

}


@Override void exit() {
  // Destroy the references to each. Not necessary, but can free up the memory faster than Java's GC by itself
  videoFrame.close();
  sender.close();
  super.exit();
}

void convertToARGB(int[] pixels) {
    int t = 0;
    int p = 0;
    if (  ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN) {
      // RGBA to ARGB conversion: shifting RGB 8 bits to the right,
      // and placing A 24 bits to the left.
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          int pixel = pixels[p++];
          pixels[t++] = (pixel >>> 8) | ((pixel << 24) & 0xFF000000);
        }
      }
    } else {
      // We have to convert ABGR into ARGB, so R and B must be swapped,
      // A and G just brought back in.
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          int pixel = pixels[p++];
          pixels[t++] = ((pixel & 0xFF) << 16) | ((pixel & 0xFF0000) >> 16) |
                          (pixel & 0xFF00FF00);
        }
      }
    }
  }
