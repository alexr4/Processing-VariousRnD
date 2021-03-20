import fpstracker.core.*;

PerfTracker pft;

ArrayList<NodeBase> nodelist;
QuadTree quadtree;
AABB2D aabb;
FlowField field;
boolean attract;

boolean pause;
boolean debug;

void settings() {
  size(1000, 1000, P2D);
  smooth(8);
}

void setup() {
  pft = new PerfTracker(this, 100);
  initNode(); 
  background(20);
  frameRate(300);
}

void draw() {
  noStroke();
  fill(0, 20);
  rectMode(CORNER);
  rect(0, 0, width, height);
  background(20);

  quadtree.update(nodelist);

  field.updateCurl2D(millis() * 0.1, millis() * 0.0001);

  PVector wind = new PVector(noise(frameCount * 0.01) * 2.0 - 1.0, 0.0);
  PVector gravity = new PVector(0.0, 1.0);
  PVector mouse = new PVector(mouseX, mouseY);

  //int i = 0;
  //textAlign(LEFT, CENTER);
  rectMode(CENTER);
  for (NodeBase node : nodelist) {
    AABB2D naabb = new AABB2D(node.location.x, node.location.y, 15, 15);
    ArrayList<NodeBase> others = quadtree.query(naabb); 

    //node.physics.applyForce(wind);
    //node.physics.applyGravity(gravity);
    node.physics.applyFriction(0.01);
    
    //node.physics.seek(mouse, 100.0);
    //node.physics.arrive(mouse, 100);
    
    node.physics.separate(others, 1.5, 25.0);
    node.physics.align(others, 50.0, 1.0);
    node.physics.cohesion(others, 50.0, 0.5);
    //node.physics.separateFromMass(others, 4.0);
    node.physics.follow(field);

    node.update();
    //node.edges.warpArround2D(aabb);
    node.edges.infinite2D(aabb);
    //node.edges.bounce2D(aabb);
    //node.edges.respawnAtRandom(aabb);
    //node.edges.respawnAt(new PVector(aabb.x, aabb.y));

    //node.debug.arrow(g, 10);
    stroke(255, 200);
    node.debug.line(g, 4);
    //node.debug.displayVelocity(g, 2.0);
    //node.debug.displayAcceleration(g, 2.0);
    //node.debug.displayForce(g, wind, 4, color(0, 255, 255));
    //noStroke();
    //fill(255, 25);
    //node.debug.display(g);

    //for (NodeBase other : others) {
    //  if (PVector.dist(other.location, node.location) <= 15) {
    //    line(other.location.x, other.location.y, node.location.x, node.location.y);
    //  }
    //}
  }


  if (debug) {
    noFill();
    stroke(255);
    rect(aabb.x, aabb.y, aabb.w, aabb.h); 
    quadtree.debug(g);
    field.debug(g, 1); 
    pft.display(0, 0);
  }else{
    pft.displayOnTopBar();
  }
}


void keyPressed() {
  if (key == 'r') {
    initNode();
    background(20);
  }
  if (key == 'p') {
    pause = !pause;
    if (pause) {
      noLoop();
    } else {
      loop();
    }
  }
  if (key == 'd') {
    debug = !debug;
  }
}


void initNode() {
  float rw = random(100, width*0.45);
  aabb = new AABB2D(width*0.5, height*0.5, width-rw, height-rw); 
  quadtree = new QuadTree(aabb, 4);

  nodelist = new ArrayList<NodeBase>();
  int max = 2500;
  for (int i=0; i<max; i++) {
    PVector loc = new PVector(random(rw * 0.5, width-rw * 0.5), random(rw * 0.5, height-rw * 0.5));

    float mass =  random(4.0, 8.0);
    float maxForce = random(2.0, 5.0);
    float maxSpeed = random(2.0, 5.0);
    NodeBase node = new NodeBase(loc, null, mass, maxForce, maxSpeed);

    nodelist.add(node);
    quadtree.insert(node);
  }

  field = new FlowField(aabb, 20, 0.0, random(0.1), random(0.01));
  field.initCurl2D(random(TWO_PI));
}
