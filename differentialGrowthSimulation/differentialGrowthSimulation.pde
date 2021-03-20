import fpstracker.core.*;
import processing.svg.*;

PerfTracker pt;

Rectangle aabb;
QuadTree quadtree;

PGraphics dataBuffer;
float resScreen= 50.0 / 70.0; 
boolean isComputed;
boolean debug = true;

//DIFFERENTIAL GROWTH SIMULATION
ArrayList<DGS> dgsdays;


void settings() {
  float res = 1.0;
  int w = 700;
  int h = floor(w / resScreen);
  size(w, h, P2D);
  smooth(8);
}

void setup() {
  pt = new PerfTracker(this, 100);
  int w = width;
  dataBuffer = createGraphics(w, floor(w/resScreen), P2D);
  dataBuffer.smooth();
  dataBuffer.beginDraw();
  dataBuffer.colorMode(HSB, 1.0, 1.0, 1.0, 1.0);
  dataBuffer.background(0.1);
  dataBuffer.endDraw();
  
  colorMode(HSB, 1.0, 1.0, 1.0, 1.0);

  aabb = new Rectangle(dataBuffer.width * 0.5, dataBuffer.height * 0.5, dataBuffer.width * 0.5, dataBuffer.height * 0.5);
  quadtree = new QuadTree(aabb, 8);

  dgsdays = new ArrayList<DGS>();
  int nbDay = 7;
  float x = width*0.5;
  float res = height/nbDay;
  for (int i=0; i<nbDay; i++) {
    DGS dgs = new DGS(quadtree);
    dgs.initAsLine(x, res * i, x, res * (i+1));

    dgsdays.add(dgs);
  }

  frameRate(300);
  background(0.1);
  surface.setLocation(10, 10);
}

void draw() {
  background(0.1);

  for (int i=0; i<dgsdays.size(); i++) {
    DGS dgs = dgsdays.get(i);
    float normindex = (float) i / (float) dgsdays.size();
    int nbElement = dgs.getNumberOfNode(); 
    if (nbElement < 1000) {
      dgs.run();
      dgs.addRandomNode();
    }
    
    dgs.displayDebug(g, normindex, 1.0);
  }


  pt.display(0, 0);
}







void keyPressed() {
}
