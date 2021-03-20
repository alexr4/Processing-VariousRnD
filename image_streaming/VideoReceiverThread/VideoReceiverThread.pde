// Daniel Shiffman
// <http://www.shiffman.net>

// A Thread using receiving UDP to receive images

import java.awt.image.*; 
import javax.imageio.*;
import java.net.*;
import java.io.*;

PImage argb;
ReceiverThread thread;
int w = 3;
int s = 200;

void settings(){
  size(w * s, w * s, P2D);
}

void setup() {
  argb = createImage(w, w, ARGB);
  thread = new ReceiverThread(argb.width,argb.height);
  thread.start();
}

 void draw() {
  if (thread.available()) {
    argb = thread.getImage();
  }

  // Draw the image
  background(0);
  imageMode(CENTER);
  image(argb,width/2,height/2);
}
