import fpstracker.core.*;

PerfTracker pft;

PShape obj;
ArrayList<Node> nodelist;
OcTree octree;
AABB3D aabb;
FlowField field;

int TMPDIM = 1250;

boolean pause = false;
boolean debug;
boolean returnToShape;

void settings() {
  size(1000, 1000, P3D);
  smooth(8);
}

void setup() {
  pft = new PerfTracker(this, 100);

  obj = loadShape("einstein_Simplify.obj");
  obj.scale(100);
  initNode(); 
  background(20);
  frameRate(60);
}

void draw() {
  Time.update(this, pause);
  modTime(3000);
  returnToShape = inout;
  //octree.update(nodelist);
  field.updateCurl3D(Time.time * 0.00001, Time.time * 0.000015);
  // field.updatePerlin(Time.time * 0.0001);
  PVector wind = new PVector(noise(frameCount * 0.01) * 2.0 - 1.0, 0.0);

  for (Node node : nodelist) {
    if (!returnToShape) {
      node.maxSpeed = node.originalMaxSpeed;
      node.physics.applyForce(wind);
      node.physics.follow(field);
    } else {
      node.maxSpeed = node.arrivedToMaxSpeed;
      node.physics.arrive(node.origin, aabb.w * 0.25);
    }

    node.update();
    node.edges.infinite(aabb);
  }



  background(20);
  lights();
  pushMatrix();
  translate(width/2, height/2, -TMPDIM * 0.75);
  rotateY(Time.time * 0.0001);
  //rotateX(Time.time * 0.000125);
  noFill();
  stroke(255);
  box(aabb.w, aabb.h, aabb.d);

  stroke(255, 200);
  float maxLen = 20.0;
  for (NodeBase node : nodelist) {
    float normSpeed = node.velocity.mag() / node.maxSpeed;
    float len = maxLen * normSpeed;
    PVector shaft = node.velocity.copy().normalize().mult(-len).add(node.location);
    line(node.location.x, node.location.y, node.location.z, shaft.x, shaft.y, shaft.z);
    point(node.location.x, node.location.y, node.location.z);
  }


  if (debug) {
    shape(obj);
    //octree.debug(g, 4, color(0, 0, 255), color(0, 127, 255));
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
  if (key == 'a') {
    returnToShape = !returnToShape;
  }
}


void initNode() {
  aabb = new AABB3D(0, 0, 0, TMPDIM, TMPDIM, TMPDIM); 
  //octree = new OcTree(aabb, 25);


  nodelist = getNodeFrom3DShape(obj, 3, 125.0);
  for (int i=0; i<nodelist.size(); i++) {
    Node node = nodelist.get(i);
    float mass =  random(1.0, 2.0);
    float maxForce = random(15.0, 25.0);
    float maxSpeed = random(15.0, 25.0);
    node.mass = mass;
    node.maxForce = maxForce;
    node.maxSpeed = maxSpeed;
    node.originalMaxSpeed = maxSpeed;
    node.arrivedToMaxSpeed = maxSpeed * 1.5;

    nodelist.set(i, node);
    //octree.insert(node);
  }

  field = new FlowField(aabb, 75, new PVector(), random(0.1), random(0.01));
  // field.initPerlin();
  field.initCurl3D(random(TWO_PI));
}
