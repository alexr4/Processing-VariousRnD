import gpuimage.core.*;
import gpuimage.utils.*;
import javax.imageio.*;
import java.awt.image.*; 
import java.net.*;
import java.io.*;

// This is the port we are sending to
int clientPort = 9100; 
// This is our object that sends UDP out
DatagramSocket ds; 

FloatPacking fp;
PImage argb;
int w = 512;
int s = 1;
float m;

void settings() {
  size(w * s, w * s, P2D);
}

void setup() {
  size(320, 240);
 // frameRate(60);
  m = millis();
  // Setting up the DatagramSocket, requires try/catch
  try {
    ds = new DatagramSocket();
  } 
  catch (SocketException e) {
    e.printStackTrace();
  }

  fp = new FloatPacking(this);
  argb = new PImage(w, w, ARGB);

  //disable display filtering
  ((PGraphicsOpenGL)g).textureSampling(2);
}



void draw() {
  //data[1 + 1 * w] = (double) noise(frameCount * 0.01);
  double[] data = new double[w * w];
  for (int i=0; i<data.length; i++) {
    data[i] = (double) noise(frameCount * 0.01);
  }
  m = millis();
  argb = fp.encodeARGB32Double(data);

  broadcast(argb);

  background(204);
  image(argb, 0, 0, width, height);
}


// Function to broadcast a PImage over UDP
// Special thanks to: http://ubaa.net/shared/processing/udp/
// (This example doesn't use the library, but you can!)
void broadcast(PImage img) {

  // We need a buffered image to do the JPG encoding
  BufferedImage bimg = new BufferedImage( img.width, img.height, BufferedImage.TYPE_INT_ARGB );

  // Transfer pixels from localFrame to the BufferedImage
  img.loadPixels();
  bimg.setRGB( 0, 0, img.width, img.height, img.pixels, 0, img.width);

  // Need these output streams to get image as bytes for UDP communication
  ByteArrayOutputStream baStream	= new ByteArrayOutputStream();
  BufferedOutputStream bos		= new BufferedOutputStream(baStream);

  // Turn the BufferedImage into a JPG and put it in the BufferedOutputStream
  // Requires try/catch
  try {
    ImageIO.write(bimg, "png", bos);
  } 
  catch (IOException e) {
    e.printStackTrace();
  }

  // Get the byte array, which we will send out via UDP!
  byte[] packet = baStream.toByteArray();

  // Send JPEG data as a datagram
  println("Sending datagram with " + packet.length + " bytes");
  try {
    ds.send(new DatagramPacket(packet, packet.length, InetAddress.getByName("127.0.0.1"), clientPort));
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}
