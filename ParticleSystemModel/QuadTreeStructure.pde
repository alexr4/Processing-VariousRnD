/** AABB 2D based on center */
class AABB2D {
  float x, y, w, h;

  AABB2D(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  boolean contains(NodeBase node) {
    return (
      node.location.x <= this.x + this.w &&
      node.location.x >= this.x - this.w && 
      node.location.y <= this.y + this.h &&
      node.location.y >= this.y - this.h);
  }

  boolean intersect(AABB2D range) {
    return !(range.x - range.w > this.x + this.w ||
      range.x + range.w < this.x - this.w ||
      range.y - range.h > this.y + this.h ||
      range.y + range.h < this.y - this.h);
  }
}

class QuadTree {
  AABB2D aabb;
  int capacity;
  ArrayList<NodeBase> pointList;

  //subdivision
  QuadTree northeast, northwest, southeast, southwest;
  boolean divided;

  QuadTree(AABB2D aabb, int capacity) {
    this.aabb = aabb;
    this.capacity = capacity;
    this.pointList = new ArrayList<NodeBase>();
  }

  boolean insert(NodeBase point) {
    boolean inserted = false;
    if (this.aabb.contains(point)) {
      if (this.pointList.size() < this.capacity) {
        pointList.add(point);
        inserted = true;
      } else {
        if (!divided) {
          this.subdivide();
        }

        if (this.northeast.insert(point)) {
          inserted = true;
        } else if (this.northwest.insert(point)) {
          inserted = true;
        } else if (this.southeast.insert(point)) {
          inserted = true;
        } else if (this.southwest.insert(point)) {
          inserted = true;
        }

        if (this.pointList.size() > this.capacity) {
          println("WARNING:\t"+this.pointList.size()+" is outsitde the edge of "+this.capacity);
        }
      }
    } else {
    }

    return inserted;
  }

  private void subdivide() {
    //note aabb x,y is not centered
    AABB2D aabbNE = new AABB2D(this.aabb.x + this.aabb.w * 0.5, this.aabb.y - this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);
    AABB2D aabbNW = new AABB2D(this.aabb.x - this.aabb.w * 0.5, this.aabb.y - this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);
    AABB2D aabbSE = new AABB2D(this.aabb.x + this.aabb.w * 0.5, this.aabb.y + this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);
    AABB2D aabbSW = new AABB2D(this.aabb.x - this.aabb.w * 0.5, this.aabb.y + this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);

    this.northeast = new QuadTree(aabbNE, this.capacity);
    this.northwest = new QuadTree(aabbNW, this.capacity);
    this.southeast = new QuadTree(aabbSE, this.capacity);
    this.southwest = new QuadTree(aabbSW, this.capacity);

    this.divided = true;
  }

  ArrayList<NodeBase> query(AABB2D range) {
    ArrayList<NodeBase> found = new ArrayList<NodeBase>();
    if (!this.aabb.intersect(range)) {
    } else {
      for (NodeBase p : this.pointList) {
        if (range.contains(p)) {
          found.add(p);
        }
      }

      if (this.divided) {
        found.addAll(this.northeast.query(range));
        found.addAll(this.northwest.query(range));
        found.addAll(this.southeast.query(range));
        found.addAll(this.southwest.query(range));
      }
    }
    return found;
  }

  public String getNumberOfData(AABB2D aabb) {
    ArrayList<NodeBase> found = new ArrayList<NodeBase>();
    for (NodeBase p : this.pointList) {
      if (aabb.contains(p)) {
        found.add(p);
      }
    }
    String st = ""+found.size();
    if (this.divided) {
      st += "\nnortheast "+northeast.getNumberOfData(aabb);
      st += "\nnorthwest "+northwest.getNumberOfData(aabb);
      st += "\nsoutheast "+southeast.getNumberOfData(aabb);
      st += "\nsouthwest "+southwest.getNumberOfData(aabb);
      st += "\n";
    }
    return st;
  }

  public void clear() {
    pointList.clear();
    this.northeast = null;
    this.northwest = null;
    this.southeast = null;
    this.southwest = null;
    divided = false;
  }

  public void update(ArrayList<NodeBase> nodes) {
    if (this.divided) {
      this.northeast.clear();
      this.northwest.clear();
      this.southeast.clear();
      this.southwest.clear();
    }
    clear();
    for (NodeBase node : nodes) {
      this.insert(node);
    }
  }

  public void debug(PGraphics b) {
    b.noFill();
    b.stroke(0, 0, 255);
    b.rectMode(CENTER);
    b.rect(this.aabb.x, this.aabb.y, this.aabb.w * 2.0, this.aabb.h * 2.0);
    //b.ellipse(this.aabb.x, this.aabb.y, 10, 10);
    //b.ellipse(this.aabb.x, this.aabb.y , this.aabb.w, this.aabb.h);

    //b.noStroke();
    //b.fill(255, 0, 0);

    //for (NodeBase p : pointList) {
    //  b.ellipse(p.location.x, p.location.y, 4, 4);
    //}

    if (divided) {
      northeast.debug(b);
      northwest.debug(b);
      southeast.debug(b);
      southwest.debug(b);
    }
  }
}
