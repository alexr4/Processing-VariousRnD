/*
 * This example shows how to use FloatPacking in order to create a full GPU 3D particles physics system.
 * Particles are emitted from a mesh
 * See shaders code for more detail on GPU side
 *
 * Iteration 0:
 * - Load shape and encode x,y,z position into 3 buffers.
 * - Decode data into GPU and retreive particles position into shader
 */

import gpuimage.core.*;
import gpuimage.utils.*;
import fpstracker.core.*;

//Elements
String path = "E:/_DEV/_RnD/GPGPU3D-Iterations/_OBJ/";
PShape obj;
PShape originalPCL;
ArrayList<PVector> originalVertList;

//GPGPU
FloatPacking fp;
PImage posImageX;
PImage posImageY;
PImage posImageZ;
PShape particles;
PShader pshader;

//Perf and control
PerfTracker pft;
boolean pause;
boolean debug;
boolean init;
boolean state = true;
PVector gizmoOrigin = new PVector();
PVector gizmoAngle = new PVector();
float gizmoLen = 100;
int zoom = 1000;
int maxZoom = 2000;
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
      float margin = 10;
      float targetWidth = (width/3) - margin * 0.5;
      float res = (float)posImageX.width/(float)posImageX.height;
      float targetHeight = targetWidth/res;

      image(posImageX, 0, height-targetHeight, targetWidth, targetHeight);
      image(posImageY, targetWidth + margin, height-targetHeight, targetWidth, targetHeight);
      image(posImageZ, (targetWidth + margin) * 2, height-targetHeight, targetWidth, targetHeight);

      //debug obj
      shader(oshader);
      pushMatrix();
      translate(gizmoOrigin.x, gizmoOrigin.y, gizmoOrigin.z);
      rotateX(gizmoAngle.x);
      rotateY(gizmoAngle.y);
      shape(originalPCL);
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

void compute() {
  Time.update(this, pause);

  gizmoOrigin.x = width/2;
  gizmoOrigin.y = height/2;
  gizmoOrigin.z = -zoom;

  gizmoAngle.y = Time.time * 0.0001;
  //gizmoAngle.x = Time.time * 0.000125;
}

void init() {
  println("Initialization");

  //get position from obj
  //obj = loadShape("einstein_Simplify.obj");
  obj = loadShape(path+"Einstein.obj");
  originalVertList = getVertListFrom3DShape(obj, 3, 20);
  println("originalVertList has: "+originalVertList.size());

  //construct a PShape PCL from vert list for debug only
  float minX = 0;
  float maxX = 0;
  float minY = 0;
  float maxY = 0;
  float minZ = 0;
  float maxZ = 0;

  originalPCL = createShape();
  originalPCL.beginShape(POINTS);
  originalPCL.noFill();
  originalPCL.stroke(255, 0, 0);
  originalPCL.strokeWeight(4);
  for (PVector v : originalVertList) {

    maxX = max(v.x, maxX);
    maxY = max(v.y, maxY);
    maxZ = max(v.z, maxZ);

    minX = min(v.x, minX);
    minY = min(v.y, minY);
    minZ = min(v.z, minZ);

    originalPCL.vertex(v.x, v.y, v.z);
  }
  originalPCL.endShape();
  println("Debug shape has been created");
  println("\tminX: "+minX+"\tmaxX: "+maxX);
  println("\tminY: "+minY+"\tmaxY: "+maxY);
  println("\tminZ: "+minZ+"\tmaxZ: "+maxZ);

  //Init GPGPU
  fp = new FloatPacking(this);

  float[] xlist = new float[originalVertList.size()];
  float[] ylist = new float[originalVertList.size()];
  float[] zlist = new float[originalVertList.size()];

  for (int i=0; i<originalVertList.size(); i++) {
    PVector vertex = originalVertList.get(i);
    xlist[i] = norm(vertex.x, minX, maxX);
    ylist[i] = norm(vertex.y, minY, maxY);
    zlist[i] = norm(vertex.z, minZ, maxZ);
  }

  posImageX = fp.encodeARGB32Float(xlist);
  posImageY = fp.encodeARGB32Float(ylist);
  posImageZ = fp.encodeARGB32Float(zlist);

  int PIWIDTH = posImageX.width;
  int PIHEIGHT = posImageX.height;

  posImageX.save("posImageX.png");
  posImageY.save("posImageY.png");
  posImageZ.save("posImageZ.png");


  particles = createShape();
  particles.beginShape(POINTS);
  particles.noFill();
  particles.stroke(255);
  particles.strokeWeight(1);
  //particles.texture(posImageX);
  for (int i=0; i<PIWIDTH * PIHEIGHT; i++) {
    int piu = i % PIWIDTH;
    int piv = (i-piu) / PIWIDTH;

    float u = (float)piu / (float)PIWIDTH;
    float v = (float)piv / (float)PIHEIGHT;

    particles.stroke(u * 255, v * 255, 0.0);
    particles.vertex(u, v, 0);
  }
  particles.endShape();
  println("GPGPU has been initialized.\tTexture sizes: "+posImageX.width+"×"+posImageX.height);

  //Remember to disable texture Mimaping and texture set texture sampling to LINEAR
  ((PGraphicsOpenGL)g).textureSampling(2);
  hint(DISABLE_TEXTURE_MIPMAPS);

  pshader = loadShader("frag.glsl", "vert.glsl");
  oshader =  loadShader("frag.glsl", "overt.glsl");
  pshader.set("textureX", posImageX);
  pshader.set("textureY", posImageY);
  pshader.set("textureZ", posImageZ);
  pshader.set("edgeX", minX, maxX);
  pshader.set("edgeY", minY, maxY);
  pshader.set("edgeZ", minZ, maxZ);
  pshader.set("state", 1.0, 1.0, 1.0, 1.0);
  println("Shader has been initialized");
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
    zoom = zoom % maxZoom;
    break;
  case '-' : 
    zoom += zoomInc;
    zoom = zoom % maxZoom;
    break;
  case 's':
  case 'S' :
    state = ! state;
    break;
  }
  
  if(state){
    pshader.set("state", 1.0, 1.0, 1.0, 1.0);
  }else{
    pshader.set("state", .0, .0, .0, .0);
  }
}
