import fpstracker.core.*;

PerfTracker pft;

ArrayList<NodeBase> nodelist;
OcTree octree;
AABB3D aabb;
FlowField field;

int TMPDIM = 1000;

boolean pause;
boolean debug;

void settings() {
  size(1000, 1000, P3D);
  smooth(8);
}

void setup() {
  pft = new PerfTracker(this, 100);
  initNode(); 
  background(20);
  frameRate(60);
}

void draw() {
  Time.update(this, pause);
  octree.update(nodelist);
  field.updateCurl3D(Time.time * 0.00005, Time.time * 0.00015);
  // field.updatePerlin(Time.time * 0.0001);
  PVector wind = new PVector(noise(frameCount * 0.01) * 2.0 - 1.0, 0.0);
  PVector gravity = new PVector(0.0, 1.0);
  PVector mouse = new PVector(mouseX, mouseY);

  float neiDistRange = TMPDIM * 0.025;
  float noiseSep      = 1.5 + noise(Time.time * 0.00125);
  float noiseAlign    = 1.0 + noise(Time.time * 0.0065);
  float noiseCohesion = 1.0 + noise(Time.time * 0.0025);
  for (NodeBase node : nodelist) {
    AABB3D naabb = new AABB3D(node.location.x, node.location.y, node.location.z, neiDistRange, neiDistRange, neiDistRange);
    ArrayList<NodeBase> others = octree.query(naabb); 
    // node.physics.applyForce(wind);
    // node.physics.applyGravity(gravity);
    // node.physics.applyFriction(0.01);

    //node.physics.seek(mouse, 100.0);
    //node.physics.arrive(mouse, 100);

    node.physics.separate(others, neiDistRange * 10.0, noiseSep);
    node.physics.align(others, neiDistRange * 1.0, noiseAlign);
    node.physics.cohesion(others, neiDistRange * 1.0, noiseCohesion);
    // node.physics.separateFromMass(others, 4.0);
    node.physics.follow(field);

    node.update();
    // node.edges.bounce(aabb);
    node.edges.infinite(aabb);
    // node.edges.warpArround(aabb);
    // node.edges.respawnAt(new PVector(aabb.x, aabb.y, aabb.z), aabb);
    // node.edges.respawnAtRandom(aabb);
  }



  background(20);

  pushMatrix();
  translate(width/2, height/2, -TMPDIM * 0.5);
  rotateY(Time.time * 0.0001);
  rotateX(Time.time * 0.000125);

  noFill();
  stroke(150);
  box(aabb.w, aabb.h, aabb.d);

  stroke(255, 200);
  for (NodeBase node : nodelist) {
    //node.debug.arrow(g, 10);
    node.debug.line(g, 10);
    // node.debug.arrow(g, 20);
    // node.debug.displayVelocity(g, 2.0);
    // node.debug.displayAcceleration(g, 2.0);
    //node.debug.displayForce(g, wind, 4, color(0, 255, 255));
    //noStroke();
    //fill(255, 25);
    // node.debug.display(g);

    //for (NodeBase other : others) {
    //  if (PVector.dist(other.location, node.location) <= 15) {
    //    line(other.location.x, other.location.y, node.location.x, node.location.y);
    //  }
    //}
  }


  if (debug) {
    octree.debug(g, 4, color(0, 0, 255), color(0, 127, 255));
    field.debug(g, 1);
  }

  popMatrix();

  if (debug) {
    noLights();
    pft.display(0, 0);
  } else {
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
  }
  if (key == 'd') {
    debug = !debug;
  }
}


void initNode() {
  aabb = new AABB3D(0, 0, 0, TMPDIM, TMPDIM, TMPDIM); 
  octree = new OcTree(aabb, 25);

  nodelist = new ArrayList<NodeBase>();
  float radiusScale = random(0.1, 0.25);
  int max = 2000;
  for (int i=0; i<max; i++) {
    float theta = random(PI);
    float eta   = random(TWO_PI);

    PVector loc = new PVector(sin(theta) * sin(eta) * (TMPDIM * radiusScale), 
                              sin(theta) * cos(eta) * (TMPDIM * radiusScale), 
                              cos(theta) * (TMPDIM * radiusScale));

    float mass =  random(4.0, 8.0);
    float maxForce = random(15.0, 25.0) * 0.25;
    float maxSpeed = random(15.0, 25.0) * 0.25;
    NodeBase node = new NodeBase(loc, null, mass, maxForce, maxSpeed);

    nodelist.add(node);
    octree.insert(node);
  }

  field = new FlowField(aabb, 75, new PVector(), random(0.5, 0.75), 1.0);//random(0.1), random(0.01));
  // field.initPerlin();
  field.initCurl3D(random(TWO_PI));
}
