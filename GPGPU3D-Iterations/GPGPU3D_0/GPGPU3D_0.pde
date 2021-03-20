/*
 * This example shows how to use FloatPacking in order to create a full GPU 3D particles physics system.
 * Particles are emitted from a mesh
 * See shaders code for more detail on GPU side
 *
 * Iteration 0:
 * - Load shape and encode x,y,z position into 3 buffers.
 * - Decode into CPU and create a shape with retreived datas
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

//Perf and control
PerfTracker pft;
boolean pause;
boolean debug;
boolean init;
PVector gizmoOrigin = new PVector();
PVector gizmoAngle = new PVector();
float gizmoLen = 100;
int zoom = 1000;
int maxZoom = 2000;
int zoomInc = 100;

void settings() {
  size(1000, 1000, P3D);
}

void setup() {
  pft = new PerfTracker(this, 120);
  frameRate(300);
  background(20);
}

void draw() {
  //display
  background(20);
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

    shape(particles);

    popMatrix();

    if (debug) {
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
      image(posImageX, 0, height-posImageX.height);
      image(posImageY, 0, height-posImageX.height*2);
      image(posImageZ, 0, height-posImageX.height*3);

      //debug obj
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
  obj = loadShape(path+"einstein_Simplify.obj");
  //obj = loadShape("Einstein.obj");
  originalVertList = getVertListFrom3DShape(obj, 1, 200);
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
  
  
  float[] decodedDataX = fp.decodeARGB32Float(posImageX);
  float[] decodedDataY = fp.decodeARGB32Float(posImageY);
  float[] decodedDataZ = fp.decodeARGB32Float(posImageZ);

  particles = createShape();
  particles.beginShape(POINTS);
  particles.noFill();
  particles.stroke(255);
  for (int i=0; i<PIWIDTH * PIHEIGHT; i++) {
    int piu = i % PIWIDTH;
    int piv = (i-piu) / PIWIDTH;
    
    float x = lerp(minX, maxX, decodedDataX[i]);
    float y = lerp(minY, maxY, decodedDataY[i]);
    float z = lerp(minZ, maxZ, decodedDataZ[i]); 
    
    particles.vertex(x, y, z);
  }
  particles.endShape();

  println("GPGPU has been created initialized");
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
  }
}
