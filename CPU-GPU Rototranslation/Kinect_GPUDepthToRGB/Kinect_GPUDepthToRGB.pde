import fpstracker.core.*;
import gpuimage.core.*;
import gpuimage.utils.*;
import KinectPV2.*;

//Global
PerfTracker pft;

//Kinect
KinectPV2 kinect;
double CXD, CYD, FXD, FYD, CXR, CYR, FXR, FYR;
double[] R, T;

//GPUImage
IntPacking intpacking;
PImage packedDepth;

//Buffers
PGraphics buffer, cropped;
PShape pointcloud;
PShader shader;

//Debug
boolean debug = true;
boolean pause;
PImage kinectRGB, kinectDepth;

void settings() {
  size(1280, 720, P3D);
}

void setup() {
  pft = new PerfTracker(this, 120);

  //initKinect
  kinect = new KinectPV2(this);
  kinect.enableColorImg(true);
  kinect.enableBodyTrackImg(true);
  kinect.enableDepthMaskImg(true);
  kinect.init();

  FYD = 366.69341530057096;
  FXD = 370.0948760993126;
  CXD = 271.9082656823498;
  CYD = 194.6951486421905;

  FXR = 719.5892644636745;
  FYR = 726.8691307807098;
  CXR = 450.2598185816999;
  CYR = 320.2470846061833;

  R = new double[] {
    0.99967550361013, 
    0.007974609200101306, 
    -0.024192831374986356, 
    
    -0.00845334990737188,
    0.9997691881896967, 
    -0.01975123342624826, 
    
    0.024029739015986016, 
    0.01994933469116878, 
    0.999512178859369 
  };

  T = new double[] {
    0.05128988276591007, 
    0.001374656963217987, 
    0.021149468453733864
  };

  //init gpu encoding
  intpacking   = new IntPacking(this);
  packedDepth  = createImage(512, 424, ARGB);

  //init target buffer
  shader       = loadShader("pcl_frag.glsl", "pcl_vert.glsl");
  buffer       = createGraphics(864, 720, P3D);
  cropped      = createGraphics(864, 720, P2D);
  buffer.hint(DISABLE_TEXTURE_MIPMAPS);
  ((PGraphicsOpenGL)buffer).textureSampling(2);
  this.shader.set("rotationMatrix", new PMatrix3D((float)R[0], (float)R[1], (float)R[2], 0.0, 
    (float)R[3], (float)R[4], (float)R[5], 0.0, 
    (float)R[6], (float)R[7], (float)R[8], 0.0, 
    0.0, 0.0, 0.0, 1.0));

  this.shader.set("translationMatrix", (float)T[0], (float)T[1], (float)T[2], 0.0);
  this.shader.set("intrinsicMatrixDepth", (float)CXD, (float)CYD, (float)FXD, (float)FYD);
  this.shader.set("intrinsicMatrixRGB", (float)CXR, (float)CYD, (float)FXR, (float)FYR);
  this.shader.set("dataMax", 8000);

  //init point cloud
  pointcloud = createShape();
  pointcloud.beginShape(POINTS);
  pointcloud.noFill();
  pointcloud.stroke(255);
  pointcloud.strokeWeight(1);
  int modInc = 2;
  //particles.texture(posImageX);
  for (int i=0; i<packedDepth.width * packedDepth.height; i++) {
    int piu = i % packedDepth.width;
    int piv = (i-piu) / packedDepth.width;
    int inc = (piv % modInc == 0) ? 0 : 1;
    if (piu % modInc == 0 && piv % modInc == 0)
    {
      float u = (float)piu / (float)packedDepth.width;
      float v = (float)piv / (float)packedDepth.height;

      pointcloud.stroke(u * 255, v * 255, 0.0);
      pointcloud.vertex(u, v, 0);
    }
  }
  pointcloud.endShape();

  //init debug
  kinectRGB   = createImage(1920, 1080, ARGB);
  kinectDepth = createImage(512, 424, ARGB);

  frameRate(300);
}

void draw() {
  Time.update(this, pause);
  compute();

  background(20);
  image(buffer, 0, 0, cropped.width, cropped.height);

  if (debug) {
    String debugUI = "Pause: "+pause+"\n";

    fill(255);
    noStroke();
    text(debugUI, 140, 20);

    float targetWidth      = width * 0.15;
    float rgbAspectRatio   = (float)kinectRGB.width / (float)kinectRGB.height;
    float depthAspectRatio = (float)kinectDepth.width / (float)kinectDepth.height;
    float rgbHeight        = targetWidth / rgbAspectRatio;
    float depthHeight      = targetWidth / depthAspectRatio;

    image(kinectRGB, 0, height - rgbHeight, targetWidth, rgbHeight);
    image(kinectDepth, 0, height - (rgbHeight + depthHeight), targetWidth, depthHeight);
    image(packedDepth, 0, height - (rgbHeight + depthHeight*2), targetWidth, depthHeight);

    pft.display(0, 0);
  } else {
    pft.displayOnTopBar();
  }
}

void compute() {
  if (!pause) {
    //get image for debug
    kinectRGB   = kinect.getColorImage();
    kinectDepth = kinect.getDepth256Image();

    packedDepth = intpacking.encodeARGB(kinect.getRawDepthData(), 8000);

    cropped.beginDraw();
    cropped.clear();
    cropped.background(0);
    cropped.translate(cropped.width/2, cropped.height/2);
    cropped.imageMode(CENTER);
    //if (!this.mirror) {
    //  cropped.rotateX(PI);
    //}
    cropped.image(kinectRGB, 0, 0, kinectRGB.width*float(cropped.height)/float(kinectRGB.height), cropped.height);
    cropped.endDraw();

    try {
      shader       = loadShader("pcl_frag.glsl", "pcl_vert.glsl");
      this.shader.set("rotationMatrix", new PMatrix3D((float)R[0], (float)R[1], (float)R[2], 0.0, 
        (float)R[3], (float)R[4], (float)R[5], 0.0, 
        (float)R[6], (float)R[7], (float)R[8], 0.0, 
        0.0, 0.0, 0.0, 1.0));

      this.shader.set("translationMatrix", (float)T[0], (float)T[1], (float)T[2], 0.0);
      this.shader.set("intrinsicMatrixDepth", (float)CXD, (float)CYD, (float)FXD, (float)FYD);
      this.shader.set("intrinsicMatrixRGB", (float)CXR, (float)CYR, (float)FXR, (float)FYR);
      this.shader.set("dataMax", 8000);
      this.shader.set("datas", packedDepth);
      this.shader.set("rgb", cropped);
      this.shader.set("resolution", buffer.width, buffer.height/2);

      //draw point cloud buffer
      buffer.beginDraw();
      buffer.background(0);
      //buffer.translate(buffer.width/2, buffer.height/2, -10 * mouseX);
      //buffer.rotateY(frameCount * 0.01);
      buffer.shader(shader);
      buffer.shape(pointcloud);
      buffer.endDraw();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
}

void keyPressed() {
  switch(key) {
  case 'p' :
  case 'P' :
    pause = !pause;
    break;
  case 'd' :
  case 'D' :
    debug = !debug;
    break;
  }
}
