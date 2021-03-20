PShader medianFilter;
PGraphics buffer;
PGraphics iBuffer;
PImage src;
String shaderName;

void settings() {
  src = loadImage("test.png");
  size(src.width * 4, src.height, P2D);
}

void setup() {
  shaderName = "medianFilter5x5Optimized";
  buffer = createGraphics(src.width, src.height, P2D);
  iBuffer = createGraphics(src.width, src.height, P2D);
  medianFilter = loadShader(shaderName+".glsl");
  medianFilter.set("resolution", (float)src.width, (float) src.height); 

  //multiple pass 5×5 median filter
  //This is not used in real time because of the copy() which take a long time
  filter(buffer, src, medianFilter);
  try {
    PImage tmp = (PImage) buffer.clone();
    for (int i=0; i<200; i++) {
      filter(iBuffer, tmp, medianFilter);
      //swap buffer
      tmp = (PImage) iBuffer.clone();
    }
  }
  catch(Exception e) {
  }
}

void draw() {
  //simple pass 5×5 median filter
  filter(buffer, src, medianFilter);
  
  //iterative 5×5 Median Filter using a list of Buffer
  ArrayList<PGraphics> bufferList = new ArrayList<PGraphics>();
  bufferList.add(buffer);
  for (int i=0; i<10; i++) {
    PGraphics nBuffer = createGraphics(src.width, src.height, P2D);
    filter(nBuffer, bufferList.get(i), medianFilter);
    bufferList.add(nBuffer);
  }

  image(src, 0, 0);
  image(buffer, src.width, 0);
  image(iBuffer, src.width * 2, 0);
  image(bufferList.get(bufferList.size() - 1), src.width * 3, 0);
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
  out.shader(filter);
  out.image(in, 0, 0, out.width, out.height);
  out.endDraw();
}

void keyPressed() {
  save(shaderName+"_"+round(frameRate)+"FPS.png");
}
