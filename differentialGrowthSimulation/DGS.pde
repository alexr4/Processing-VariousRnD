class DGS {
  ArrayList<Node> nodeList;
  QuadTree quadtree;

  DGS(QuadTree quadtree) {
    this.quadtree = quadtree;
  }

  void initAsCircle() {
    int nbElement = 360 / 4;
    float radius = dataBuffer.width * 0.25;

    for (int i=0; i<nbElement; i++) {
      float normIndex = (float)i/ (float)nbElement;
      float theta = normIndex * TWO_PI;

      float x = cos(theta) * radius + dataBuffer.width/2;
      float y = sin(theta) * radius + dataBuffer.height/2;
      PVector location = new PVector(x, y);
      Node node = new Node(location);
      nodeList.add(node);
    }
  }

  void initAsLine(float xmin, float ymin, float xmax, float ymax) {
    nodeList = new ArrayList<Node>();
    Node nodeTop = new Node(new PVector(xmin, ymin));
    Node nodeBottom = new Node(new PVector(xmax, ymax));
    nodeList.add(nodeTop);
    nodeList.add(nodeBottom);
  }

  void run() {
    for (int i=1; i<nodeList.size()-1; i++) {
      Node node = nodeList.get(i);

      int neiPrevIndex = i - 1;//(i - 1 > 0) ? i - 1 : nodeList.size() - 1;
      int neiNextIndex = i + 1;//(i + 1 > nodeList.size() - 1) ? 0 : i +1;

      Node prev = nodeList.get(neiPrevIndex);
      Node next = nodeList.get(neiNextIndex);
      float separationDist = 20.0f;

      Rectangle range = new Rectangle(node.location.x, node.location.y, 50, 50);
      ArrayList<Node> neighbors = quadtree.query(range);

      PVector separation = node.separate(neighbors, separationDist);
      PVector cohesion = node.cohesion(prev, next);
      node.applyForce(separation);
      node.applyForce(cohesion);
      node.checkEdge(dataBuffer, 20);
      node.update();
    }
  }

  void displayDebug(PGraphics b, float fillcolor, float sw) {
    computeDebugBuffer(b, sw, fillcolor, nodeList);
  }

  void addRandomNode() {
    //get two random points
    int randomIndex = floor(random(0, nodeList.size()-1));
    int randomNextIndex = randomIndex+1;

    //get Node
    Node prev = nodeList.get(randomIndex);
    Node next = nodeList.get(randomNextIndex);

    //Compute position of new node
    PVector loc = new PVector();
    loc.add(prev.location);
    loc.add(next.location);
    loc.div(2.0);

    Node newNode = new Node(loc);
    newNode.saturation = 1.0;

    //using ArrayList.add(int index, Object o) will inject the Object at the provided index and update all the remaining indices
    nodeList.add(randomNextIndex, newNode);
    quadtree.insert(newNode);
  }

  void exportSVG(String name, ArrayList<Node> nodeList) {
    String exportName = name+".svg";
    PGraphics pg = createGraphics(width, height, SVG, exportName);
    pg.beginDraw();
    pg.beginShape();
    for (int i=0; i<nodeList.size(); i++) {
      pg.curveVertex(nodeList.get(i).location.x, nodeList.get(i).location.y);
    }
    pg.endShape();
    pg.endDraw();
    pg.dispose();

    println(exportName + " saved.");
  }

  public void computeLaplacianSmooth(int it) {
    for (int i=0; i<it; i++) {
      nodeList = computeLaplacianSmooth(nodeList);
    }
  }

  ArrayList<Node> computeLaplacianSmooth(ArrayList<Node> list) {
    ArrayList<Node> smoothedNodeList = new ArrayList<Node>();
    for (int i=1; i<list.size()-1; i++) {
      Node node = nodeList.get(i);

      int neiPrevIndex = i - 1;//(i - 1 > 0) ? i - 1 : nodeList.size() - 1;
      int neiNextIndex = i + 1;//(i + 1 > nodeList.size() - 1) ? 0 : i +1;

      Node prev = nodeList.get(neiPrevIndex);
      Node next = nodeList.get(neiNextIndex);

      float factor = 1.0 / 2.0;
      PVector newLocation = new PVector();
      newLocation.add(prev.location);
      newLocation.add(next.location);
      newLocation.mult(factor);

      Node smoothedNode = new Node(newLocation);
      smoothedNodeList.add(smoothedNode);
    }

    return smoothedNodeList;
  }

  void computeBuffer(PGraphics buffer, float sw, ArrayList<Node> nodeList) {

    buffer.beginShape();
    buffer.noFill();
    buffer.noStroke();
    buffer.strokeWeight(sw);
    for (int i=0; i<nodeList.size(); i++) {
      float normindex = i / (float)nodeList.size();
      Node node = nodeList.get(i);
      buffer.stroke(normindex, 0.0, 1.0);
      buffer.curveVertex(node.location.x, node.location.y);
    }
    buffer.endShape();
  }

  void computeDebugBuffer(PGraphics buffer, float sw, float hue, ArrayList<Node> nodeList) {
    buffer.noFill();
    //buffer.strokeWeight(sw);
    //buffer.stroke(0.6, 1.0, 1.0, 0.5);
    //quadtree.debug(buffer);
    buffer.noStroke();
    for (int i=0; i<nodeList.size(); i++) {
      Node node = nodeList.get(i);
      buffer.fill(hue, 1.0, 1.0);
      buffer.ellipse(node.location.x, node.location.y, sw, sw);
    }
  }

  int getNumberOfNode() {
    return nodeList.size();
  }

  ArrayList<Node> getNodeList() {
    return nodeList;
  }
}
