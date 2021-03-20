PShader dilateFilter;
PGraphics buffer;
PGraphics iBuffer;
PImage src;
String shaderName;

int scale, w, h;

void settings() {
  src = loadImage("kinect.png");
  scale = 2;
  w = src.width / scale;
  h = src.height / scale;
  size(w * 2, h, P2D);
}

void setup() {
  shaderName = "dilateFilter3x3Gaps";
  buffer = createGraphics(src.width, src.height, P2D);
  iBuffer = createGraphics(src.width, src.height, P2D);
  dilateFilter = loadShader(shaderName+".glsl");
  dilateFilter.set("resolution", (float)src.width, (float) src.height); 
  dilateFilter.set("ratio", 0.01);
  dilateFilter.set("radius", 5.0);
  //multiple pass 5×5 median filter
  //This is not used in real time because of the copy() which take a long time
  filter(buffer, src, dilateFilter);
  try {
    PImage tmp = (PImage) buffer.clone();
    for (int i=0; i<10; i++) {
      filter(iBuffer, tmp, dilateFilter);
      //swap buffer
      tmp = (PImage) iBuffer.clone();
    }
  }
  catch(Exception e) {
  }
}

void draw() {
  //simple pass 5×5 median filter
  filter(buffer, src, dilateFilter);
/*
  //iterative 5×5 Median Filter using a list of Buffer
    ArrayList<PGraphics> bufferList = new ArrayList<PGraphics>();
   bufferList.add(buffer);
   for (int i=0; i<5; i++) {
   PGraphics nBuffer = createGraphics(src.width, src.height, P2D);
   filter(nBuffer, bufferList.get(i), dilateFilter);
   bufferList.add(nBuffer);
   }
*/
  image(src, 0, 0, src.width / scale, src.height / scale);
  image(buffer, src.width / scale, 0, src.width / scale, src.height / scale);
  //image(iBuffer, (src.width / scale) * 2, 0, src.width / scale, src.height / scale);
 // image(bufferList.get(bufferList.size() - 1), (src.width / scale) * 3, 0, src.width / scale, src.height / scale);
  /*
  int res = 10;
   int w = buffer.width/res;
   int h = buffer.height/res;
   buffer.loadPixels();
   noStroke();
   for (int i=0; i<w; i++) {
   for (int j=0; j<h; j++) {
   int x = buffer.width * 3 + i * res;
   int y = j*res;
   int index = x + y * buffer.width;
   index = constrain(index, 0, buffer.pixels.length - 1);
   color c = buffer.pixels[index];
   fill(c);
   rect(x, y, res, res);
   }
   }*/

  surface.setTitle("frameRate : "+round(frameRate)+" resolution : "+width+"*"+height);
}

void filter(PGraphics out, PImage in, PShader filter) {
  out.beginDraw();
  out.background(0);
  out.shader(filter);
  out.image(in, 0, 0, out.width, out.height);
  out.endDraw();
}

void keyPressed() {
  save(shaderName+"_"+round(frameRate)+"FPS.png");
}