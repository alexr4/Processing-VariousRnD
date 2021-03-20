//import java.io.File;
//import java.io.IOException;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
//import javax.imageio.ImageIO;


BufferedImage image;
int[] imagePixelData;
PImage t;

PImage getRandomImage(PApplet context, int w, int h) {
  image = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
  imagePixelData = ((DataBufferInt)image.getRaster().getDataBuffer()).getData();
  
  for (int wh = 0; wh<w*h; wh++) {
    int r = (int)(Math.random() * 255);
    int g = (int)(Math.random() * 255);
    int b = (int)(Math.random() * 255);
    int a = (int)(Math.random() * 255);
    imagePixelData[wh] = a<< 24 | r<<16 | g <<8 | b;
    //imagePixelData[wh] = (int) 255 << 24 | 255 <<16 | 0  <<8 | (int) 0 ;
  }

  PImage img = new PImage(image);
  img.parent = context;
  return img;
}

PImage getRandomPImage(PApplet context, int w, int h) {
  PImage img = context.createImage(w, h, ARGB);
  img.loadPixels();
  
  for (int wh = 0; wh<w*h; wh++) {
    int r = (int)(Math.random() * 255);
    int g = (int)(Math.random() * 255);
    int b = (int)(Math.random() * 255);
    int a = (int)(Math.random() * 255);
    img.pixels[wh] = a<< 24 | r<<16 | g <<8 | b;
    //imagePixelData[wh] = (int) 255 << 24 | 255 <<16 | 0  <<8 | (int) 0 ;
  }

  return img;
}


void setup() {
  size(512, 424, P2D);
  t = getRandomImage(this, width, height);
  t.save("test.png");
}

void draw() {
  background(0);
  t = getRandomImage(this, width, height);
  
  //t = getRandomPImage(this, width, height);
  image(t, 0, 0);
  surface.setTitle("fps : "+round(frameRate));
}
