import fpstracker.core.*;
import com.walker.devolay.Devolay;
import com.walker.devolay.DevolayFrameFourCCType;
import com.walker.devolay.DevolaySender;
import com.walker.devolay.DevolayVideoFrame;
import java.awt.image.BufferedImage;
import java.nio.*;
import java.io.*;
import java.awt.image.*;
import javax.imageio.*;
import java.awt.color.*;

PerfTracker pt; //tracker de performance

DevolayReceiver receiver;
DevolayVideoFrame videoFrame;
DevolayPerformanceData performanceData;
ByteBuffer data;
IntBuffer intBuffer;

PImage test;

void settings() {
  size(1280, 720, P3D);
}

void setup() {
  pt = new PerfTracker(this, 120);

  Devolay.loadLibraries();

  receiver = new DevolayReceiver();
  DevolayFinder finder = new DevolayFinder();
  performanceData = new DevolayPerformanceData();
  // Create a finder
  try {
    // Query for sources
    DevolaySource[] sources;
    while ((sources = finder.getCurrentSources()).length == 0) {
      // If none found, wait until the list changes
      println("Waiting for sources...");
      finder.waitForSources(5000);
    }

    // Connect to the first source found
    println("Connecting to source: " + sources[0].getSourceName());
    receiver.connect(sources[0]);

    videoFrame = new DevolayVideoFrame();

    test = createGraphics(width, height, P3D);
  }
  catch(Exception e) {
    e.printStackTrace();
  }


  // BGRX has a pixel depth of 4
  //data = ByteBuffer.allocateDirect(width * height * 4);
  //intBuffer = data.asIntBuffer();


  frameRate(300);
}

void draw() {

  receiver.receiveCapture(videoFrame, null, null, 1000/30);
  // println("Video data received (" + videoFrame.getXResolution() + "x" + videoFrame.getYResolution() + ", " +
  //  videoFrame.getFrameRateN() + "/" + videoFrame.getFrameRateD() + ").");
  receiver.queryPerformance(performanceData);
  if (performanceData.getDroppedVideoFrames() > 0) {
    System.out.println("Dropped Video: " + performanceData.getDroppedVideoFrames() + "/" + performanceData.getTotalVideoFrames());
  }

  if(videoFrame.getXResolution() > 0 && videoFrame.getYResolution() > 0 ){
    try {
      ByteBuffer buffer = videoFrame.getData();
      byte[] bytes = new byte[buffer.capacity()];
      buffer.get(bytes);

      
      // println(bytes.length);

      

    }
    catch(Exception e) {
      //println("frame: "+frameCount);
     e.printStackTrace();
    }
  }

  pt.display(0, 0);
}


void keyPressed(){
  if(key == 'e') exit();
}


@Override void exit() {
  // Destroy the references to each. Not necessary, but can free up the memory faster than Java's GC by itself
  videoFrame.close();
  receiver.close();
  super.exit();
}
