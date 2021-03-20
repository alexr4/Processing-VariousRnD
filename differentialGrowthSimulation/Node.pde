class Node {
  PVector location, velocity, acceleration;
  float maxSpeed, maxForce;
  float saturation;

  Node(PVector location) {
    this.location = location;
    this.velocity = PVector.random2D();//new PVector();
    this.acceleration = new PVector();
    this.maxSpeed = random(0.5, 1.5);//random(10.0, 20);
    this.maxForce = this.maxSpeed;
  }

  void applyForce(PVector force) {
    this.acceleration.add(force);
  }

  void update() {
    this.velocity.add(this.acceleration);
    this.velocity.limit(this.maxSpeed);
    this.location.add(this.velocity);
    this.acceleration.mult(0.0);
  }


  void checkEdge(PGraphics b, float margin) {
    if (this.location.x < margin || this.location.x > b.width - margin)
      this.velocity.x*=-1;
    if (this.location.y < margin || this.location.y > b.height - margin)
      this.velocity.y*=-1;
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, this.location);
    desired.normalize();
    desired.mult(this.maxSpeed);

    PVector steer = PVector.sub(desired, this.velocity);
    steer.limit(this.maxForce);
    return steer;
  }

  PVector separate(ArrayList<Node> nodes, float desiredSeperation) {
    PVector steer = new PVector();
    int count = 0;
    for (Node other : nodes) {
      if (other != this) {
        //float d = PVector.dist(other.location, this.location);
        //distance optimisation
        float dx = other.location.x - this.location.x; //longueur c en x
        float dy = other.location.y - this.location.y; //longueur c en y
        float dxCube = dx * dx;
        float dyCube = dy * dy;
        float sqrtD = dxCube + dyCube;
        //float d = sqrt(dxCube + dyCube);

        if (sqrtD > 0.0 && sqrtD < desiredSeperation * desiredSeperation) {
          PVector diff = PVector.sub(this.location, other.location);
          diff.normalize();
          diff.div(sqrt(sqrtD));
          steer.add(diff);
          count++;
        }
      }
    }

    if (count > 0) {
      steer.div((float)count);
    }

    if (steer.mag() > 0.0) {
      steer.normalize();
      steer.mult(this.maxSpeed);
      steer.sub(this.velocity);
      steer.limit(this.maxForce);
    }

    return steer;
  }

  PVector cohesion (ArrayList<Node> nodes, float desiredCohesion) {
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Node other : nodes) {
      if (other != this) {
        float d = PVector.dist(this.location, other.location);
        if (d > 0 && (d < desiredCohesion)) {
          sum.add(other.location); // Add position
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }

  PVector cohesion (Node prev, Node next) {
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    sum.add(prev.location); // Add position
    sum.add(next.location); // Add position

    sum.div(2.0);
    return seek(sum);  // Steer towards the position
  }
}
