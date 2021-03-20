import java.awt.image.BufferedImage;
import java.awt.image.DataBufferInt;
import KinectPV2.*;

KinectPV2 kinect;
BufferedImage image;
int[] imagePixelData;
PImage t;

PImage getModImage(PApplet context, int[]datas, int w, int h) {
  image = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
  imagePixelData = ((DataBufferInt)image.getRaster().getDataBuffer()).getData();
  
  for (int wh = 0; wh<datas.length; wh++) {
    int g = datas[wh] % 255;
    imagePixelData[wh] = 255<< 24 | g<<16 | g<<8 | g;
    //imagePixelData[wh] = (int) 255 << 24 | 255 <<16 | 0  <<8 | (int) 0 ;
  }

  PImage img = new PImage(image);
  img.parent = context;
  return img;
}

void settings(){
  size(512 * 3, 424, P2D);
}

void setup() {
  
  kinect = new KinectPV2(this);
  kinect.enableDepthImg(true);
  kinect.init();

}

void draw() {
  background(0);
  int [] datas = kinect.getRawDepthData();
  t = getModImage(this, datas, 512, height);
  
  //t = getRandomPImage(this, width, height);
  
  image(kinect.getDepthImage(), 0, 0);
  image(kinect.getDepth256Image(), 512, 0);
  image(t, 512*2, 0);
  surface.setTitle("fps : "+round(frameRate));
}
