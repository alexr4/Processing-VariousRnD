/*
 * This example shows how to use FloatPacking in order to create a full GPU 3D particles physics system.
 * Particles are emitted from a mesh
 * See shaders code for more detail on GPU side
 *
 * Iteration 0:
 * - Load shape and encode x,y,z position into 1 interleaved buffers.
 * - Decode data into GPU and retreive particles position into shader
 */

import gpuimage.core.*;
import gpuimage.utils.*;
import fpstracker.core.*;

//Elements
String path = "E:/_DEV/_RnD/GPGPU3D-Iterations/_OBJ/";
PShape obj;
ArrayList<PVector> originalVertList;

//GPGPU
static final int VERT_CMP_COUNT = 3;
FloatPacking fp;
PImage posImage;
PImage velImage;
PImage massImage;
PImage maxVelImage;
PingPongBuffer posBuffer, velBuffer;
PShape particles;
PShader pshader;
PShader posFrag, velFrag;

//World variables here
float WORLDWIDTH, WORLDHEIGHT, WORLDDEPTH;

//Perf and control
PerfTracker pft;
boolean pause;
boolean debug = true;
boolean init;
boolean state = true;
PVector gizmoOrigin = new PVector();
PVector gizmoAngle = new PVector();
float gizmoLen = 100;
int zoom = 1000;
int maxZoom = 4000;
int zoomInc = 100;
PShader oshader;

void settings() {
  size(1000, 1000, P3D);
  PJOGL.profile = 4;
}

void setup() {
  pft = new PerfTracker(this, 120);
  frameRate(300);
  background(20);
  //surface.setLocation(0, 0);
}

void draw() {
  //display
  background(20);
  //ortho();
  if (!init) {
    fill(255);
    noStroke();
    textAlign(CENTER);
    text("Initialization", width*0.5, height*0.5);
    init();
    init = true;
  } else {
    compute();

    pushMatrix();
    translate(gizmoOrigin.x, gizmoOrigin.y, gizmoOrigin.z);
    rotateX(gizmoAngle.x);
    rotateY(gizmoAngle.y);

    shader(pshader);
    shape(particles);

    popMatrix();

    if (debug) {
      resetShader();
      //debug UI and Control
      pft.display(0, 0);
      pushStyle();
      fill(255);
      noStroke();
      textAlign(LEFT);
      text("Pause: "+pause+"\nTime: "+Time.time+
        "\n"+"Number of particles: "+originalVertList.size()+
        "\n"+"Zoom: "+zoom, 120, 20);
      popStyle();

      //debug GPGPU
      float margin = 4;
      float targetWidth = (width/6);
      float res = (float)posImage.width/(float)posImage.height;
      float targetHeight = targetWidth/res;

      image(posBuffer.dst, 0, height-targetHeight, targetWidth, targetHeight);
      image(velBuffer.dst, 0, height-(targetHeight+margin)*2, targetWidth, targetHeight);
      image(maxVelImage, 0, height-(targetHeight+margin)*3, targetWidth, targetHeight);
      image(massImage, 0, height-(targetHeight+margin)*4, targetWidth, targetHeight);

      image(posBuffer.getSrcBuffer(), targetWidth, height-targetHeight, targetWidth, targetHeight);
      image(velBuffer.getSrcBuffer(), targetWidth, height-(targetHeight+margin)*2, targetWidth, targetHeight);

      //debug obj
      pushMatrix();
      translate(gizmoOrigin.x, gizmoOrigin.y, gizmoOrigin.z);
      rotateX(gizmoAngle.x);
      rotateY(gizmoAngle.y);
      stroke(255);
      noFill();
      box(WORLDWIDTH*2.0, WORLDHEIGHT*2.0, WORLDDEPTH*2.0);
      stroke(255, 0, 0);
      line(0, 0, 0, gizmoLen, 0, 0);
      stroke(0, 255, 0);
      line(0, 0, 0, 0, gizmoLen, 0);
      stroke(0, 0, 255);
      line(0, 0, 0, 0, 0, gizmoLen);
      popMatrix();
    } else {
      pft.displayOnTopBar("GPGPU3D — Time: "+Time.time);
    }
  }
}

void init() {
  println("Initialization");

  //get position from obj
  //obj = loadShape("einstein_Simplify.obj");
  obj = loadShape(path+"Einstein.obj");
  originalVertList = getVertListFrom3DShape(obj, 2, 15);
  println("originalVertList has: "+originalVertList.size());

  //Check the boundaries of the shape
  float minX = 0;
  float maxX = 0;
  float minY = 0;
  float maxY = 0;
  float minZ = 0;
  float maxZ = 0;

  for (PVector v : originalVertList) {
    maxX = max(v.x, maxX);
    maxY = max(v.y, maxY);
    maxZ = max(v.z, maxZ);

    minX = min(v.x, minX);
    minY = min(v.y, minY);
    minZ = min(v.z, minZ);
  }
  println("Debug shape has been created");
  println("\tminX: "+minX+"\tmaxX: "+maxX);
  println("\tminY: "+minY+"\tmaxY: "+maxY);
  println("\tminZ: "+minZ+"\tmaxZ: "+maxZ);

  //take the max absolute value of each edge and extends it by a scaler
  WORLDWIDTH = WORLDHEIGHT = WORLDDEPTH = getAbsoluteMax(minX, maxX, minY, maxY, minZ, maxZ) * 1.25;

  //Init GPGPU
  fp = new FloatPacking(this);

  //Feed the initial list
  float[] poslist      = new float[originalVertList.size() * VERT_CMP_COUNT];
  float[] velList      = new float[originalVertList.size() * VERT_CMP_COUNT];
  float[] maxVelList   = new float[originalVertList.size() * VERT_CMP_COUNT];
  float[] massList     = new float[originalVertList.size()];

  println("Position buffer size: " + poslist.length);
  for (int i=0; i<originalVertList.size(); i++) {
    PVector vertex = originalVertList.get(i);

    //feed the interleaved poslist with data from mesh
    poslist[i * VERT_CMP_COUNT + 0] = norm(vertex.x, -WORLDWIDTH, WORLDWIDTH);
    poslist[i * VERT_CMP_COUNT + 1] = norm(vertex.y, -WORLDHEIGHT, WORLDHEIGHT);
    poslist[i * VERT_CMP_COUNT + 2] = norm(vertex.z, -WORLDDEPTH, WORLDDEPTH);

    //feed the interleaved vellist with a vel.xyz of 0.0 (velocity are passed from -1/1.0 to 0.0/1.0 so 0.5 = 0.0 once remapped)
    velList[i * VERT_CMP_COUNT + 0] = 0.5;
    velList[i * VERT_CMP_COUNT + 1] = 0.5;
    velList[i * VERT_CMP_COUNT + 2] = 0.5;

    //feed the interleaved vellist with a vel.xyz of 1.0
    maxVelList[i * VERT_CMP_COUNT + 0] = 1.0;
    maxVelList[i * VERT_CMP_COUNT + 1] = 1.0;
    maxVelList[i * VERT_CMP_COUNT + 2] = 1.0;

    //feed the interleaved masslist with a mass of 1.0
    massList[i] = 1.0;
  }

  //Encode datas
  posImage    = fp.encodeARGB24Float(poslist);
  velImage    = fp.encodeARGB24Float(velList);
  maxVelImage = fp.encodeARGB24Float(maxVelList);
  massImage   = fp.encodeARGB24Float(massList);

  int PIWIDTH = posImage.width;
  int PIHEIGHT = posImage.height;

  //save datas
  posImage.save("posImage.png");
  velImage.save("velImage.png");
  maxVelImage.save("maxVelImage.png");
  massImage.save("massImage.png");

  //Create the PingPongBuffer for GPGPU computation
  posBuffer = new PingPongBuffer(this, PIWIDTH, PIHEIGHT, P2D);
  velBuffer = new PingPongBuffer(this, PIWIDTH, PIHEIGHT, P2D);
  disableMipmapAndSetFiltering(posBuffer, GPUImageInterface.NEAREST , false, CLAMP);
  disableMipmapAndSetFiltering(velBuffer, GPUImageInterface.NEAREST , false, CLAMP);

  println(posBuffer.dst.width, posBuffer.dst.height);

  drawTextureIntoPingPongBuffer(posBuffer, posImage);
  drawTextureIntoPingPongBuffer(velBuffer, velImage);

  //Create the particles shape
  //Remember to disable texture Mimaping and texture set texture sampling to LINEAR
  ((PGraphicsOpenGL)g).textureSampling(2);
  hint(DISABLE_TEXTURE_MIPMAPS);

  particles = createShape();
  particles.beginShape(POINTS);
  particles.noFill();
  particles.stroke(255);
  particles.strokeWeight(2);
  //particles.texture(posImageX);
  for (int i=0; i<PIWIDTH * PIHEIGHT; i+=VERT_CMP_COUNT) {
    int piu = i % PIWIDTH;
    int piv = (i-piu) / PIWIDTH;

    float[] uvx = getUVAt(i, PIWIDTH, PIHEIGHT);
    //float[] uvy = getUVAt(i+1, PIWIDTH, PIHEIGHT);
    //float[] uvz = getUVAt(i+2, PIWIDTH, PIHEIGHT);

    particles.stroke(255);
    //particles.attrib("uv", uvy[0], uvy[1], uvz[0], uvz[1]);//it does not seams to work
    particles.vertex(uvx[0], uvx[1], 0.0);
  }
  particles.endShape();
  println("GPGPU has been initialized.\tTexture sizes: "+posImage.width+"×"+posImage.height);

  //load shaders
  velFrag = loadShader("velFrag.glsl");
  posFrag = loadShader("posFrag.glsl");
  pshader = loadShader("frag.glsl", "vert.glsl");

  //Feed the shaders
  float maxSpeed = 25.0;
  
  velFrag.set("textureResolution", (float)PIWIDTH, (float) PIHEIGHT);
  velFrag.set("worldResolution", WORLDWIDTH, WORLDHEIGHT, WORLDDEPTH);
  velFrag.set("maxSpeed", maxSpeed); 
  velFrag.set("force", 5.0, 0.0, 0.0);

  posFrag.set("textureResolution", (float)PIWIDTH, (float) PIHEIGHT);
  posFrag.set("worldResolution", WORLDWIDTH, WORLDHEIGHT, WORLDDEPTH);
  posFrag.set("maxSpeed", maxSpeed);

  pshader.set("posImage", posBuffer.dst);
  pshader.set("textureResolution", (float)PIWIDTH, (float) PIHEIGHT);
  pshader.set("edgeX", -WORLDWIDTH, WORLDWIDTH);
  pshader.set("edgeY", -WORLDHEIGHT, WORLDHEIGHT);
  pshader.set("edgeZ", -WORLDDEPTH, WORLDDEPTH);
  pshader.set("state", 1.0, 1.0, 1.0, 1.0);
  println("Shader has been initialized");
}

void drawTextureIntoPingPongBuffer(PingPongBuffer ppb, PImage tex) { 
  /**
   * IMPORTANT : pre-multiply alpha is not supported on processing 3.X (based on 3.4)
   * Here we use a trick in order to render our image properly into our pingpong buffer
   * find out more here : https://github.com/processing/processing/issues/3391
   */
  ppb.dst.beginDraw();
  ppb.dst.clear();
  ppb.dst.blendMode(REPLACE);
  ppb.dst.image(tex, 0, 0, ppb.dst.width, ppb.dst.height);
  ppb.dst.endDraw();
}

void updatePingPongBuffer(PingPongBuffer ppb, PShader shader) { 
  /**
   * IMPORTANT : pre-multiply alpha is not supported on processing 3.X (based on 3.4)
   * Here we use a trick in order to render our image properly into our pingpong buffer
   * find out more here : https://github.com/processing/processing/issues/3391
   */
  ppb.dst.beginDraw();
  ppb.dst.clear();
  ppb.dst.blendMode(REPLACE);
  ppb.dst.shader(shader);
  ppb.dst.image(ppb.getSrcBuffer(), 0, 0, ppb.dst.width, ppb.dst.height);
  ppb.dst.endDraw();
}

void updateBuffersSimulation() {
  //Swap buffers
  posBuffer.swap();
  velBuffer.swap();
  /*
  → Look to shader : data seams messed up 
  force +X acts like +Y   |  X  |  X  |
  force -X acts like -Y   |  X  |  X  |
  force +Y acts like +Z   |  Y  |  Z  |
  force -Y acts like -Z   |  Y  |  Z  |
  force +Z acts like +X   |  Z  |  X  |
  force -Z acts like -X   |  Z  |  X  |
  */
  float maxForce = 10.0;

  //bind data to vel shader
  velFrag.set("posBuffer", posBuffer.getSrcBuffer());
  velFrag.set("force", maxForce* 0.0, maxForce * 1.0, maxForce * 0.0);

  //update vel buffer
  updatePingPongBuffer(velBuffer, velFrag);

  //bind data to pos buffer
  posFrag.set("velBuffer", velBuffer.getSrcBuffer());
  //posFrag.set("force", maxForce* 1.0, maxForce * 0.0, maxForce * 0.0);

  //update pos buffer
  updatePingPongBuffer(posBuffer, posFrag);
  //drawTextureIntoPingPongBuffer(posBuffer, posImage);
}

void compute() {
  Time.update(this, pause);

  if (!pause) {
    updateBuffersSimulation();
  }

  pshader.set("posImage", posBuffer.dst);
  //Update scene
  gizmoOrigin.x = width/2;
  gizmoOrigin.y = height/2;
  gizmoOrigin.z = -zoom;

  gizmoAngle.y = Time.time * 0.0001;
  //gizmoAngle.x = Time.time * 0.000125;
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
  case '+' : 
    zoom -= zoomInc;
    zoom = (zoom > 0) ? (zoom % maxZoom) : 0;
    break;
  case '-' : 
    zoom += zoomInc;
    zoom = zoom % maxZoom;
    break;
  case 's':
  case 'S' :
    state = ! state;
    break;
  case 'r':
  case 'R':
    drawTextureIntoPingPongBuffer(posBuffer, posImage);
    drawTextureIntoPingPongBuffer(velBuffer, velImage);
  }

  if (state) {
    pshader.set("state", 1.0, 1.0, 1.0, 1.0);
  } else {
    pshader.set("state", .0, .0, .0, .0);
  }
}
