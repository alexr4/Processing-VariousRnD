import org.processing.wiki.triangulate.*;
import fpstracker.core.*;

PerfTracker perftracker;


//triangulate example

ArrayList triangles = new ArrayList();
ArrayList points = new ArrayList();

PGraphics buffer;

void setup() {
  size(512, 424, P3D);
  smooth(8);
  perftracker = new PerfTracker(this, 100);
  buffer = createGraphics(width, height, P3D);
  //triangulate
  // fill the points Vector with points from a spiral

  float w  = 512.0;
  float h  = 424.0;
  int max = int(w*h);
  float smooth = 5.5;
  int inc = 10;
  for (int x=0; x<w; x+=inc) {
    for (int y=0; y<h; y+=inc) {
      int index = int(x + y / w);
      float n = noise((x / w) * smooth, (y / h) * smooth, ((float) index / (float) max) * smooth) * 150;
      points.add(new PVector(x + width/2 * -1, y + height/2 * -1, n));
    }
  }

  // get the triangulated mesh
  int m = millis();
  triangles = Triangulate.triangulate(points);
  int end = millis() - m;
  println(end);

  println("loaded with "+points.size()+" points");
}

void draw() {
  //triangles = Triangulate.triangulate(points);


  buffer.beginDraw();
  buffer.background(0, 0, 0);
  buffer.lights();
  buffer.translate(width/2, height/2, -200);
  buffer.rotateX(frameCount * 0.01);
  buffer.rotateY(frameCount * 0.015);
  // draw the mesh of triangles
  buffer.fill(255);
  buffer.noStroke();
  buffer.beginShape(TRIANGLES);
  for (int i = 0; i < triangles.size(); i++) {
    Triangle t = (Triangle)triangles.get(i);
    buffer.vertex(t.p1.x, t.p1.y, t.p1.z);
    buffer.vertex(t.p2.x, t.p2.y, t.p2.z);
    buffer.vertex(t.p3.x, t.p3.y, t.p3.z);
  }
  buffer.endShape();
  buffer.endDraw();
  image(buffer, 0, 0);
  perftracker.displayOnTopBar();
  perftracker.display(0, 0);
}
