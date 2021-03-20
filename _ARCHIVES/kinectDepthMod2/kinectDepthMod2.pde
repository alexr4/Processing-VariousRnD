PGraphics buffer;
float scale = 1.5;
int row = 3;


void settings() {
  int w = ceil(512.0 / scale);
  int h = ceil((424.0 / scale) * row);
  size(w, h, P3D);
}

void setup() {
}


void draw() {
  background(0);
  int w = 512;
  int h = 424;
  PVector center = new PVector(w/2, h/2);
  float hyp = sqrt(w * w + h + h);


  int[] rawData = new int[w*h];
  float divider = 8000.0 / 256;

  PImage rawDepth256Image = createImage(w, h, ARGB);
  PImage rawDepthModImage = createImage(w, h, ARGB);
  PImage rawDepth256ImageRetreived = createImage(w, h, ARGB);
  
  float counter = millis() * 0.001;
  //encode
  for (int i =0; i<rawData.length; i++) {
    float x = i % w;
    float y = (i - x) / w;
    PVector loc = new PVector(x, y);
    PVector toCenter = PVector.sub(center, loc);
    float normDepth = (toCenter.mag() + noise(x * 0.1 + counter, y * 0.1 + counter, counter) * w/10) / hyp;
    //normDepth *= 10.0;
    //normDepth %= 1.0;
    int depth = int(normDepth * 4500);
    //println(i, depth, normDepth);

    //rawData[i] = round(((float)i / (float)rawData.length) * 4500);//round(random(4500));
    rawData[i] = depth;

    int debugColor = ceil((depth / 4500.0) * 255);
    rawDepth256Image.pixels[i] = (255 << 24) | (debugColor << 16) | (debugColor << 8) | debugColor;

    int modDatai = rawData[i] % 255; 
    int modIndex = rawData[i] / 255;
    int modIndexAsAlpha = ceil(((float)modIndex / (float)divider) * 255);

    rawDepthModImage.pixels[i] = (modIndexAsAlpha << 24) | (modDatai << 16) | (modDatai << 8) | modDatai;
  }


  rawDepthModImage.loadPixels();

  //decode
  for (int i=0; i<rawDepth256ImageRetreived.pixels.length; i++) {
    int a = rawDepthModImage.pixels[i] >> 24 & 0xFF;
    int r = rawDepthModImage.pixels[i] >> 16 & 0xFF;
    //println(i, a, r);

    int modIndexRetreived = int(((float)a / 255.0) * divider);
    int retrievedData = (r + 255 * modIndexRetreived);
    int retreiveMod = ceil((retrievedData / 4500.0) * 255);
    /*
    println("i: "+i, 
     "rawData: "+rawData[i], 
     "a: "+a, 
     "r: "+r, 
     "modIR: "+modIndexRetreived, 
     "rD: "+retrievedData);
*/
    rawDepth256ImageRetreived.pixels[i] = (255 << 24) | (retreiveMod << 16) | (retreiveMod << 8) | retreiveMod;
  }



  image(rawDepth256Image, 0, height / 3 * 0, w / scale, h / scale);
  image(rawDepthModImage, 0, height / 3 * 1, w / scale, h / scale);
  image(rawDepth256ImageRetreived, 0, height / 3 * 2, w / scale, h / scale);


  fill(255, 255, 0);
  text("Raw data from 0 to 4500", 20, 20 +  h / scale * 0);
  text("Mod data from 0 to 255\nand Mod index as alpha from 0 to 255", 20, 20 +  h / scale * 1);
  text("Raw data from 0 to 4500 retreived from Mod data\nand Mod index stocked as alpha value", 20, 20 +  h / scale * 2);


  surface.setTitle("FPS : "+round(frameRate));
  //noLoop();
  if (frameCount == 1) {
    rawDepth256Image.save("rawDepth256Image.png");
    rawDepthModImage.save("rawDepthModImage.png");
    rawDepth256ImageRetreived.save("rawDepth256ImageRetreived.png");
  }
}
