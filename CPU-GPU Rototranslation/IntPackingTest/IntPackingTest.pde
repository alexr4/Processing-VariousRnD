import fpstracker.core.*;
import java.nio.*;
import gpuimage.core.*;
import gpuimage.utils.*;


ByteBuffer[] byteBufferDepthArray, byteBufferBodyArray;
int[][] intDepthArray, intBodyArray;
int imgW, imgH, rawDataSize, totalDataSets, currentDataSetIndex;
double Cx, Cy, Fx, Fy;
double[] R, T;
boolean dataLoaded;

//Direct VBO
boolean body = false;
boolean play = false;
VBOInterleaved vbo;

IntPacking ip;
FloatPacking fp;

//trackers
PerfTracker pt;

void setup() {
  size(1280, 720, P3D);
  frameRate(300);
  pt = new PerfTracker(this, 100);

  ip = new IntPacking(this);
  fp = new FloatPacking(this);

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
  int[] intBody = intBodyArray[currentDataSetIndex];
  
  float[] normDepth = new float[intDepth.length];
  for(int i=0; i<intDepth.length; i++){
    normDepth[i] = intDepth[i] / 8000.0;
  }

  PImage packed = ip.encodeARGB(intDepth, 8000);
  int[] data = ip.decodeARGB(packed, 8000);
  
  
  //PImage packed = fp.encodeARGB24Float(normDepth);
  //float[] data = fp.decodeARGB24Float(packed);

  //for each array
  int boundingBox = 500;
  ArrayList<PVector> pcd = new ArrayList<PVector>();
  PVector RT = new PVector();
  for (int i=0; i<intDepth.length; i++) {
    int rd = int(data[i]);// * 8000);
    int rb = intBody[i];
    int x = i % imgW;
    int y = (i-x) / imgW;

    if (body) {
      if (rb != 255) {
        //1 - Back projet 2D point into depth world pos
        PVector BP = computeDepth3DCoord(new PVector(x, y), rd);

        //2 - Rototranslate
        RT = computeColor3DCoord(BP);
      }
    } else {
      //1 - Back projet 2D point into depth world pos
      PVector BP = computeDepth3DCoord(new PVector(x, y), rd);

      //2 - Rototranslate
      RT = computeColor3DCoord(BP);
    }

    RT.mult(boundingBox);

    pcd.add(RT);
  }

  //update and display VBO
  updateGeometry(pcd);
  vbo.updateVBO();
  
  pushMatrix();
  translate(width/2, height/2, -boundingBox * 4.0 + mouseX);
  rotateY(millis() * 0.001);
  vbo.draw(g);
  popMatrix();

  if (play)
    currentDataSetIndex = (currentDataSetIndex+1) % totalDataSets;

  pt.display(0, 0);
}

void keyPressed() {
  if (key == 'b')
    body = !body;

  if (key == 'p')
    play = !play;
}

public void updateGeometry(ArrayList<PVector> vertData) {
  for (int i=0; i<vertData.size(); i++) {
    PVector v = vertData.get(i);
    vbo.setVertex(i, v.x, v.y, v.z);
  }
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
