import javax.imageio.*;
import java.awt.image.*; 
import java.nio.*;
import java.net.*;

// This is the port we are sending to
int clientPort = 9100; 
// This is our object that sends UDP out
DatagramSocket ds; 

int w = 100;
int s = 1;
float m;

void settings() {
  size(w * s, w * s, P2D);
}

void setup() {
  // frameRate(60);
  // Setting up the DatagramSocket, requires try/catch
  try {
    ds = new DatagramSocket();
  } 
  catch (SocketException e) {
    e.printStackTrace();
  }


  //disable display filtering
  ((PGraphicsOpenGL)g).textureSampling(2);
}



void draw() {
  //data[1 + 1 * w] = (double) noise(frameCount * 0.01);
  short[] data = new short[(512*424) / 10];
  for (int i=0; i<data.length; i++) {
    data[i] = (short) (noise(i, frameCount * 0.01) * 8000);
  }

  broadcast(data);

  background(204);
  textAlign(CENTER, CENTER);
  fill(0);
  text(frameRate, width/2, height/2);
  surface.setTitle("fps "+frameRate);
}


// Function to broadcast a PImage over UDP
// Special thanks to: http://ubaa.net/shared/processing/udp/
// (This example doesn't use the library, but you can!)
void broadcast(short[] data) {

  ByteBuffer byteBuffer = ByteBuffer.allocate(data.length * 2);        
  ShortBuffer shortBuffer = byteBuffer.asShortBuffer();
  shortBuffer.put(data);

  byte[] packet = byteBuffer.array();


  // Send JPEG data as a datagram
  println("Sending datagram with " + packet.length + " bytes");
  try {
    ds.send(new DatagramPacket(packet, packet.length, InetAddress.getByName("127.0.0.1"), clientPort));
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}
