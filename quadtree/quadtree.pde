import fpstracker.core.*;
PerfTracker pt;

Rectangle aabb;
Rectangle range;
QuadTree quadtree;

ArrayList<Point> debugPoint;

void setup() {
  size(500, 500, P2D);
  smooth();
  pt = new PerfTracker(this, 100);


  aabb = new Rectangle(width * 0.5, height * 0.5, width * 0.5, height * 0.5);
  range = new Rectangle(random(width), random(height), width * 0.1, height * 0.1);
  quadtree = new QuadTree(aabb, 4);
  debugPoint = new ArrayList<Point>();

  for (int i=0; i<8760; i++) {
    Point p = new Point(random(width), random(height));
    debugPoint.add(p);
    quadtree.insert(p);
  }
}

void draw() {
  background(0);
  ArrayList<Point> debugQueryPoint = quadtree.query(range); 
  println(debugQueryPoint.size());
  
  noFill();
  stroke(0, 255, 0);
  for (Point p : debugQueryPoint) {
    ellipse(p.x, p.y, 6, 6);
  }

  quadtree.debug(g);

  range.x = mouseX;
  range.y = mouseY;

  rectMode(CENTER);
  noFill();
  stroke(0, 255, 0);
  rect(range.x, range.y, range.w * 2.0, range.h *2.0);


  /*
  if (mousePressed) {
   for (int i=0; i<4; i++) {
   float angle = random(TWO_PI);
   float rad = random(10, 20);
   Point p = new Point(mouseX + cos(angle) * rad, mouseY + sin(angle) * rad);
   quadtree.insert(p);
   }
   }
   */




  pt.display(0, 0);
}

void keyPressed() {
  if (key == 'r') {
    quadtree = new QuadTree(aabb, 4);
  }
}
