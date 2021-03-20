import java.awt.image.*; 
import javax.imageio.*;
import java.net.*;
import java.io.*;


// Port we are receiving.
int port = 23000; 
DatagramSocket ds; 
// A byte array to read into (max size of 65536, could be smaller)
byte[] buffer = new byte[65536]; 

PImage argb;
int w = 100;
int s = 4;

void settings(){
  size(w * s, w * s, P2D);
}

void setup() {
  try {
    ds = new DatagramSocket(port);
  } catch (SocketException e) {
    e.printStackTrace();
  } 
  
  argb = createImage(w,w, ARGB);
  
  //disable display filtering
  ((PGraphicsOpenGL)g).textureSampling(2);
}

 void draw() {
  // checkForImage() is blocking, stay tuned for threaded example!
  checkForImage();

  // Draw the image
  background(204);
  image(argb, 0, 0, width, height);
}

void checkForImage() {
  DatagramPacket p = new DatagramPacket(buffer, buffer.length); 
  try {
    ds.receive(p);
  } catch (IOException e) {
    e.printStackTrace();
  } 
  byte[] data = p.getData();

  println("Received datagram with " + data.length + " bytes." );

  // Read incoming data into a ByteArrayInputStream
  ByteArrayInputStream bais = new ByteArrayInputStream( data );

  // We need to unpack JPG and put it in the PImage video
  argb.loadPixels();
  try {
    // Make a BufferedImage out of the incoming bytes
    BufferedImage img = ImageIO.read(bais);
    // Put the pixels into the video PImage
    img.getRGB(0, 0, argb.width, argb.height, argb.pixels, 0, argb.width);
  } catch (Exception e) {
    e.printStackTrace();
  }
  // Update the PImage pixels
  argb.updatePixels();
}
