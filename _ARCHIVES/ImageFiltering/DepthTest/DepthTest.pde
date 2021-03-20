

PImage tex;
PImage texClone;
PImage kinectBodyOutImg;
PGraphics buffer;
PShader threshold;
PShader denoise;

void settings() {
  size(512 * 4, 424, P3D);
}

void setup() {

  tex = loadImage("test.jpg");
  tex.loadPixels();

  kinectBodyOutImg = new PImage(512/3, 424/3, ARGB);
  kinectBodyOutImg.loadPixels();

  buffer = createGraphics(512, 424, P2D);
  threshold = loadShader("PP_ColorThreshold.glsl");
  buffer.loadPixels();

}

void draw() {
  background(0);


  PImage clone = new PImage();
  try {
    clone = (PImage) tex.clone();
    clone.resize(tex.width / 3, tex.height/3);
    //clone.loadPixels();
  }
  catch(Exception e) {
  }
  int[] dataCloud = new int[clone.pixels.length];
  System.arraycopy( clone.pixels, 0, dataCloud, 0, clone.pixels.length );

  this.kinectBodyOutImg.pixels = new int[dataCloud.length];

  //fastblur(rawData, 512, 424, 6);
  //fastblur(rawBodyData, 512, 424, 4);
  fastblur(dataCloud, clone.width, clone.height, 2);
  int[] dataCloudComplete = getComplete(dataCloud, clone.width, clone.height, 2);
  fastblur(dataCloudComplete, clone.width, clone.height, 2);

  for (int i = 0; i < dataCloud.length; i++) {
    int cb = dataCloudComplete[i];
    this.kinectBodyOutImg.pixels[i] = cb;
  }
  this.kinectBodyOutImg.updatePixels();

  threshold.set("threshold", 0.9);


  buffer.beginDraw();
  buffer.background(0);
  buffer.shader(threshold);
  buffer.image(kinectBodyOutImg, 0, 0, buffer.width, buffer.height);
  buffer.endDraw();


  image(tex, 0, 0);
  image(kinectBodyOutImg, 512 * 1, 0);
  image(buffer, 512 * 2, 0);


  noStroke();
  fill(255);
  text(frameRate, 50, height - 50);
}
