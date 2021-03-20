import fpstracker.core.*;
import com.walker.devolay.Devolay;
import com.walker.devolay.DevolayFrameFourCCType;
import com.walker.devolay.DevolaySender;
import com.walker.devolay.DevolayVideoFrame;
import java.awt.image.BufferedImage;
import java.nio.ByteBuffer;
import java.io.ByteArrayOutputStream;
import javax.imageio.ImageIO;

PerfTracker pt; //tracker de performance

DevolaySender sender;
DevolayVideoFrame videoFrame;
long startTime;
int frameCounter;
long fpsPeriod;
ByteBuffer data;

void settings() {
  size(1280, 720, P2D);
}

void setup() {
  pt = new PerfTracker(this, 120);

  Devolay.loadLibraries();

  // Create the sender using the default settings, other than setting a name for the source.
  sender = new DevolaySender("Devolay Example Video");

  // BGRX has a pixel depth of 4
  data = ByteBuffer.allocateDirect(width * height * 4);

  // Create a video frame
  videoFrame = new DevolayVideoFrame();
  videoFrame.setResolution(width, height);
  videoFrame.setFourCCType(DevolayFrameFourCCType.BGRX);
  videoFrame.setData(data);
  videoFrame.setFrameRate(60, 1);


  startTime = System.currentTimeMillis();

  frameCounter = 0;
  fpsPeriod = System.currentTimeMillis();
  loadPixels();
  frameRate(300);
}

void draw() {

  // Run for ten minutes
  if (System.currentTimeMillis() - startTime < 1000 * 60 * 10) {

    //Fill in the buffer for one frame.
    fillFrame(width, height, frameCounter, data);

    // Submit the frame. This is clocked by default, so it will be submitted at <= 60 fps.
    sender.sendVideoFrame(videoFrame);

    // Give an FPS message every 30 frames submitted
    if (frameCounter % 30 == 29) {
      long timeSpent = System.currentTimeMillis() - fpsPeriod;
      System.out.println("Sent 30 frames. Average FPS: " + 30f / (timeSpent / 1000f));
      fpsPeriod = System.currentTimeMillis();
    }
  } else {
    println("end");
    startTime = System.currentTimeMillis();
    //exit();
  }

  pt.display(0, 0);

  frameCounter++;
}

private void fillFrame(int width, int height, int frameCounter, ByteBuffer data) {
  data.position(0);
  double frameOffset = Math.sin(frameCounter / 120d);
  for (int i = 0; i < width * height; i++) {
    double xCoord = i % width;
    double yCoord = i / (double)width;

    double convertedX = xCoord/width;
    double convertedY = yCoord/height;

    double xWithFrameOffset = convertedX + frameOffset;
    double xWithScreenOffset = xWithFrameOffset - 1;
    double yWithScreenOffset = convertedY + 1;

    double squaredX = xWithFrameOffset * xWithFrameOffset;
    double offsetSquaredX = xWithScreenOffset * xWithScreenOffset;
    double squaredY = convertedY * convertedY;
    double offsetSquaredY = yWithScreenOffset * yWithScreenOffset;

    byte r = (byte) (Math.min(255 * Math.sqrt(squaredX + squaredY), 255));
    byte g = (byte) (Math.min(255 * Math.sqrt(offsetSquaredX + squaredY), 255));
    byte b = (byte) (Math.min(255 * Math.sqrt(squaredX + offsetSquaredY), 255));
    
    pixels[i] = color((int) Math.min(255 * Math.sqrt(squaredX + squaredY), 255),
                      (int) Math.min(255 * Math.sqrt(offsetSquaredX + squaredY), 255),
                      (int) Math.min(255 * Math.sqrt(squaredX + offsetSquaredY), 255));
    data.put(b).put(g).put(r).put((byte)255);
  }
  data.flip();
  updatePixels();
}

@Override void exit() {
  // Destroy the references to each. Not necessary, but can free up the memory faster than Java's GC by itself
  videoFrame.close();
  sender.close();
  super.exit();
}
