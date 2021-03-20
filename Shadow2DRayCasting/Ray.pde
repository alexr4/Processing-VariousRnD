class Ray {
  PVector ray;
  PVector origin;
  PVector dir;
  PVector dirMax;
  float maxLength;
  PVector world;
  boolean skipped;

  Ray(PVector origin, PVector dir, float maxLength, PVector world) {
    this.origin = origin;
    this.dir = dir;
    this.maxLength = maxLength;
    this.dirMax = this.dir.copy().mult(maxLength);
    this.world = world;
    updateRay(this.origin);
  }

  void updateRay(PVector origin) {
    this.origin = origin;
    this.ray = origin.copy().add(dirMax);
    checkEdge();
  }

  void checkEdge() {
    PVector north = lineIntersection(this.origin.x, this.origin.y, this.ray.x, this.ray.y, 0, 0, this.world.x, 0);
    PVector east = lineIntersection(this.origin.x, this.origin.y, this.ray.x, this.ray.y, this.world.x, 0, this.world.x, this.world.y);
    PVector south = lineIntersection(this.origin.x, this.origin.y, this.ray.x, this.ray.y, 0, this.world.y, this.world.x, this.world.y);
    PVector west = lineIntersection(this.origin.x, this.origin.y, this.ray.x, this.ray.y, 0, 0, 0, this.world.y);

    if (north != null) {
      this.ray = north.copy();
    } else if (east != null) {
      this.ray = east.copy();
    } else if (south != null) {
      this.ray = south.copy();
    } else if (west != null) {
      this.ray = west.copy();
    }
  }

  void projectToFindCollision(PGraphics buffer, int step) {
    PVector subray = this.origin;
    float speed = PVector.dist(this.origin, this.ray)/(float)step;
    for (int i=0; i<step; i++) {
      if (checkCollison(buffer, subray)) {
        this.ray = subray.copy();
        break;
      } else {
        subray = subray.copy().add(this.dir.copy().mult(speed));
      }
    }
  }

  boolean checkCollison(PGraphics buffer, PVector pos) {
    int index = (int)pos.x + (int)pos.y * buffer.width;
    int pixel = buffer.pixels[index];
    float red = pixel >> 16 & 0xFF;
    if (red > 0) {
      return true;
    } else {
      return false;
    }
    /*
    int a = x >> 24 & 0xFF;
     int r = x >> 16 & 0xFF;
     int g = x >> 8 & 0xFF;
     int b = x & 0xFF;
     */
  }

  void defineSkipped(Ray previous, Ray next) {
    skipped = isRayCanBeSkipped(previous, next);
  }

  boolean isRayCanBeSkipped(Ray previous, Ray next) {
    PVector prevToRay = PVector.sub(this.ray, previous.ray).normalize();
    PVector rayToNext = PVector.sub(next.ray, this.ray).normalize();
    float dot = PVector.dot(prevToRay, rayToNext);
    if (dot >= 0.99) {
      return true;
    } else {
      return false;
    }
  }

  void displayRay(color c, float size) {
    if (!skipped) {
      noFill();
      stroke(c);
      line(this.origin.x, this.origin.y, this.ray.x, this.ray.y);
      fill(c);
      noStroke();
      ellipse(this.ray.x, this.ray.y, size, size);
    }
  }
}
