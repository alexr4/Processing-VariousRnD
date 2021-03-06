class Point {
  float x, y;

  Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

class Rectangle {
  float x, y, w, h;

  Rectangle(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  boolean contains(Point point) {
    return (point.x > this.x - this.w && 
      point.x < this.x + this.w &&
      point.y > this.y - this.h &&  
      point.y < this.y + this.h);
  }

  boolean intersect(Rectangle range) {
    return !(range.x - range.w > this.x + this.w ||
      range.x + range.w < this.x - this.w ||
      range.y - range.h > this.y + this.h ||
      range.y + range.h < this.y - this.h);
  }
}

class QuadTree {
  Rectangle aabb;
  int capacity;
  ArrayList<Point> pointList;

  //subdivision
  QuadTree northeast, northwest, southeast, southwest;
  boolean divided;

  QuadTree(Rectangle aabb, int capacity) {
    this.aabb = aabb;
    this.capacity = capacity;
    this.pointList = new ArrayList<Point>();
  }

  boolean insert(Point point) {
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
    Rectangle aabbNE = new Rectangle(this.aabb.x + this.aabb.w * 0.5, this.aabb.y - this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);
    Rectangle aabbNW = new Rectangle(this.aabb.x - this.aabb.w * 0.5, this.aabb.y - this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);
    Rectangle aabbSE = new Rectangle(this.aabb.x + this.aabb.w * 0.5, this.aabb.y + this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);
    Rectangle aabbSW = new Rectangle(this.aabb.x - this.aabb.w * 0.5, this.aabb.y + this.aabb.h * 0.5, this.aabb.w * 0.5, this.aabb.h * 0.5);

    this.northeast = new QuadTree(aabbNE, this.capacity);
    this.northwest = new QuadTree(aabbNW, this.capacity);
    this.southeast = new QuadTree(aabbSE, this.capacity);
    this.southwest = new QuadTree(aabbSW, this.capacity);

    this.divided = true;
  }

  ArrayList<Point> query(Rectangle range) {
    ArrayList<Point> found = new ArrayList<Point>();
    if (!this.aabb.intersect(range)) {
    } else {
      for (Point p : this.pointList) {
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

  public void debug(PGraphics b) {
    b.noFill();
    b.stroke(0, 0, 255);
    b.rectMode(CENTER);
    b.rect(this.aabb.x, this.aabb.y, this.aabb.w * 2.0, this.aabb.h * 2.0);

    b.noStroke();
    b.fill(255, 0, 0);
    for (Point p : pointList) {
      b.ellipse(p.x, p.y, 4, 4);
    }

    if (divided) {
      northeast.debug(b);
      northwest.debug(b);
      southeast.debug(b);
      southwest.debug(b);
    }
  }
}
