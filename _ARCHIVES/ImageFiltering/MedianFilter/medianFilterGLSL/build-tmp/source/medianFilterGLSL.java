import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class medianFilterGLSL extends PApplet {

PShader medianFilter;
PGraphics buffer;
PImage src;

public void settings() {
  src = loadImage("KinectScreenshot-BodyIndex-09-43-19.png");
  size(src.width * 2, src.height, P2D);
}

public void setup() {
  buffer = createGraphics(src.width, src.height, P2D);
  medianFilter = loadShader("medianFilter5x5Optimized.glsl");
  medianFilter.set("resolution", (float)src.width, (float) src.height);
}

public void draw() {
  //compute median Filter
  filter(buffer, src, medianFilter);

  image(src, 0, 0);
  image(buffer, src.width, 0);

  surface.setTitle("frameRate : "+round(frameRate)+" resolution : "+width+"*"+height);
}

public void filter(PGraphics out, PImage in, PShader filter) {
  out.beginDraw();
  out.shader(filter);
  out.image(in, 0, 0, out.width, out.height);
  out.endDraw();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "medianFilterGLSL" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
