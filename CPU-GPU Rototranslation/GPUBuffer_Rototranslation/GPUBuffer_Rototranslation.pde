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
boolean body = true;
boolean play = true;

//GPUpacking
PShader compute;
PGraphics buffer;
IntPacking ip;
FloatPacking fp;
int dataMax;
PImage packedDepth;

//trackers
PerfTracker pt;

float scale = 0.5;
void settings() {
  size(floor(scale * 512.0), floor(424 * 4.0 *  scale + 60), P3D);
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
 

  //packing data
  fp = new FloatPacking(this);
  ip = new IntPacking(this);
  dataMax = 8000 * 1;

  buffer = createGraphics(512, 424*3, P2D);
  ((PGraphicsOpenGL)buffer).textureSampling(2);

  compute = new PShader(this, computeVertSource, computeFragSource);
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

  //update ppb buffer
  this.compute.set("rotationMatrix", new PMatrix3D((float)R[0], (float)R[1], (float)R[2], 0.0, 
    (float)R[3], (float)R[4], (float)R[5], 0.0, 
    (float)R[6], (float)R[7], (float)R[8], 0.0, 
    0.0, 0.0, 0.0, 1.0));
  this.compute.set("translationMatrix", (float)T[0], (float)T[1], (float)T[2], 0.0);
  this.compute.set("intrinsicMatrix", (float)Cx, (float)Cy, (float)Fx, (float)Fy);
  this.compute.set("resolution", (float) imgW, (float) imgH);
  this.compute.set("dataMax", dataMax);
  
  buffer.beginDraw(); 
  buffer.shader(compute);
  buffer.image(packedDepth, 0, 0, buffer.width, buffer.height);
  buffer.endDraw();

  float[] unpackedData = fp.decodeARGB24Float(buffer);
  
  if (play)
    currentDataSetIndex = (currentDataSetIndex+1) % totalDataSets;

  //debug
  image(packedDepth, 0,                              pt.getHeight(), packedDepth.width * scale, packedDepth.height * scale);
  image(     buffer, 0, packedDepth.height * scale + pt.getHeight(),      buffer.width * scale,      buffer.height * scale);
  pt.display(0, 0);
}

void keyPressed() {
  if (key == 'b')
    body = !body;

  if (key == 'p')
    play = !play;
    
    
  if (key == 's')
    saveFrame("GPGPU_Rototransalation.png");
}

public PVector computeDepth3DCoord(PVector pixel, float depth)
{    
  //OPENCV gives elements as meters so we need to convert depth into meters
  depth /= 1000.0;

  //3D Depth Coord - Back projecting pixel depth coord to 3D depth coord
  PVector r = new PVector();
  r.x = (float)((pixel.x - Cx) * depth / Fx);
  r.y = (float)((pixel.y - Cy) * depth / Fy);
  r.z = depth;

  return r;
}

public PVector computeColor3DCoord(PVector pixel)
{
  //transpose 3D depth coord to 3D color coord
  PVector r = new PVector();
  r.x = (float)((pixel.x * R[0] + pixel.y * R[1] + pixel.z * R[2]) + T[0]);
  r.y = (float)((pixel.x * R[3] + pixel.y * R[4] + pixel.z * R[5]) + T[1]);
  r.z = (float)((pixel.x * R[6] + pixel.y * R[7] + pixel.z * R[8]) + T[2]);

  return r;
}
