/*
This example show a full GPU rototranslation computation into vertex shader using int packing
 key :
 p : play/pause
 r : rotation play/pause
 b : body on/off
 mouseWheel : to zoom in/out
 */



import fpstracker.core.*;
import gpuimage.core.*;
import gpuimage.utils.*;

import java.nio.*;

ByteBuffer[] byteBufferDepthArray, byteBufferBodyArray;
int[][] intDepthArray, intBodyArray;
int imgW, imgH, rawDataSize, totalDataSets, currentDataSetIndex;
double Cx, Cy, Fx, Fy;
double[] R, T;
boolean dataLoaded;

//Direct VBO
boolean body = false;
boolean play = false;
boolean rotate = true;
float camz;
VBOInterleaved vbo;

//GPUpacking
IntPacking ip;
int dataMax;
PImage packedDepth;

//trackers
PerfTracker pt;

void settings() {
  float s = 1.0;
  size(floor(1280 * s), floor(720 * s), P3D);
}

void setup() {
  frameRate(300);
  pt = new PerfTracker(this, 100);

  totalDataSets = 20;

  imgW = 512;
  imgH = 424;
  rawDataSize = imgW*imgH;
  currentDataSetIndex = 0;

  Cx = 254.6148365784062;
  Cy = 208.7003369124855;
  Fx = 361.31211007109204;
  Fy = 362.06211361420674;

  R = new double[] {
    -0.5671929506945774, 
    0.00992497852682809, 
    -0.8235251371291715, 
    -0.03767607931442203, 
    0.9985678576828988, 
    0.03798350497360359, 
    0.8227227174023287, 
    0.05257117464759932, 
    -0.5660067153897553
  };

  T = new double[] {
    1.5592894574335576, 
    -0.08611331384166403, 
    2.723304489544531
  };

  byteBufferDepthArray = new ByteBuffer[totalDataSets];
  byteBufferBodyArray = new ByteBuffer[totalDataSets];
  for (int i=0; i<totalDataSets; i++) {
    byteBufferDepthArray[i] = ByteBuffer.allocateDirect(rawDataSize * Integer.BYTES);
    byteBufferDepthArray[i].order(ByteOrder.LITTLE_ENDIAN);
    byteBufferBodyArray[i] = ByteBuffer.allocateDirect(rawDataSize * Integer.BYTES);
    byteBufferBodyArray[i].order(ByteOrder.LITTLE_ENDIAN);
  }

  intDepthArray = new int[totalDataSets][rawDataSize];
  intBodyArray = new int[totalDataSets][rawDataSize];

  //VBO
  vbo = new VBOInterleaved(this);
  vbo.initVBO(g, rawDataSize);
  //init vbo as simple grid  
  for (int i=0; i<rawDataSize; i++) {
    float x = i % imgW;
    float y = (i - x) / imgW;
    float z = 0;
    float u = x / (float)imgW;
    float v = y / (float)imgH;

    vbo.setVertex(i, x, y, z);
    vbo.setColor(i, 1.0, 1.0, 1.0, 1.0);
    vbo.setVertTexCoord(i, u, v, 0.0, 0.0);
  }
  vbo.updateVBO();

  //packing data
  ip = new IntPacking(this);
  dataMax = 8000 * 1;
}

void init() {
  for (int i=0; i<totalDataSets; i++) {
    // Load data files as ByteBuffers
    byteBufferDepthArray[i].put(loadBytes("data/raw/users-6/depth_int_2_byte_"+i+".dat"));
    byteBufferBodyArray[i].put(loadBytes("data/raw/users-6/body_int_2_byte_"+i+".dat"));

    // Convert to int[] values
    ((ByteBuffer)byteBufferDepthArray[i].rewind()).asIntBuffer().get(intDepthArray[i]); 
    ((ByteBuffer)byteBufferBodyArray[i].rewind()).asIntBuffer().get(intBodyArray[i]);

    println("Data set loaded : "+(i+1)+" / "+totalDataSets);
  }
  println("All data sets loaded !");
}

void draw() {
  background(20);

  if (!dataLoaded) {
    init();
    dataLoaded = true;
  }

  // Après le init() toutes les données sont donc chargées
  // dans les tableau intDepthArray[][] et intBodyArray[][]

  int[] intDepth = intDepthArray[currentDataSetIndex];
  //not we will need to precompute this as real int color
  int[] intBody = intBodyArray[currentDataSetIndex];

  //body on/off
  int[] dataFinal = new int[intDepth.length];
  for (int i=0; i<intDepth.length; i++) {
    if (body) {
      if (intBody[i] == 255) {
        dataFinal[i] = 0;
      }else{
        dataFinal[i] = intDepth[i];
      }
    }else{
        dataFinal[i] = intDepth[i];
    }
  }


  //encode depth data into RGBA Mod
  packedDepth = ip.encodeARGB(dataFinal, dataMax);


  //update and display VBO
  Time.update(this, rotate);
  pushMatrix();
  translate(width/2, height/2, camz);
  rotateY(Time.time * 0.001);
  pushMatrix();
  vbo.draw(g);
  popMatrix();
  popMatrix();

  if (play)
    currentDataSetIndex = (currentDataSetIndex+1) % totalDataSets;

  //debug
  float scale = .25;
  image(packedDepth, width - packedDepth.width * scale, 0, packedDepth.width * scale, packedDepth.height * scale);
  pt.display(0, 0);
}

void keyPressed() {
  if (key == 'b')
    body = !body;

  if (key == 'p')
    play = !play;

  if (key == 'r')
    rotate = !rotate;
    
    
  if (key == 's'){
    saveFrame("GPU_Rototransalation.png");
    saveStrings("vert.glsl", ShaderSource.vertSource);
    saveStrings("frag.glsl", ShaderSource.fragSource);
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  camz += e * 25.0;
}
