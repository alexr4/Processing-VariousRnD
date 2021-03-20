/**
 NODES : 
 This class is a wrapper for physicial engine. It implement various method for physicial simulation.
 This (2019) review is based on Nature of Code from Daniel Shiffman and used design pattern for easy update
 */
/*
public class Node extends NodeBase {
 
 Node() {
 super();
 }
 }*/

/**
 Abstracts methods
 */
public class NodeBase {
  //Identifier

  //Translation
  protected PVector location, velocity, acceleration;
  protected float mass, maxForce, maxSpeed;

  //Rotation

  //Behaviours
  PhysicBehaviour physics;
  PhysicsEdge edges;
  PhysicsDebug debug;

  NodeBase() {
  }

  NodeBase(PVector location) {
    this.init(location, null, 0, 0, 0);
  }

  NodeBase(PVector location, PVector velocity) {
    this.init(location, velocity, 0, 0, 0);
  }

  NodeBase(PVector location, float mass) {
    this.init(location, null, mass, 4.0, 4.0);
  }

  NodeBase(PVector location, float mass, float maxForce, float maxSpeed) {
    this.init(location, null, mass, maxForce, maxSpeed);
  }

  NodeBase(PVector location, PVector velocity, float mass, float maxForce, float maxSpeed) {
    this.init(location, velocity, mass, maxForce, maxSpeed);
  }

  private void init(PVector location, PVector velocity, float mass, float maxForce, float maxSpeed) {
    this.location = location;
    this.velocity = (velocity == null) ? new PVector() : velocity;
    this.acceleration = new PVector();
    this.mass = (mass != 0) ? mass : 1;
    this.maxForce = (maxForce != 0) ? maxForce : 1;
    this.maxSpeed = (maxSpeed != 0) ? maxSpeed : 1;

    //behaviour
    physics = new PhysicBehaviour(this);
    edges = new PhysicsEdge(this);
    debug = new PhysicsDebug(this);
  }

  //update
  public void update() {
    updatePosition();
  }

  public void updatePosition() {
    this.velocity.add(acceleration);
    this.velocity.limit(maxSpeed);
    this.location.add(velocity);
    this.acceleration.mult(0);
  }
}

protected abstract class PhysicsBase {
  NodeBase node;

  PhysicsBase(NodeBase node) {
    this.node = node;
  }
}

/**
 Behaviros
 */
public class PhysicBehaviour extends PhysicsBase {

  PhysicBehaviour(NodeBase node) {
    super(node);
  }

  //Physics
  public void applyForce(PVector force) {
    PVector f = force.copy();
    f.div(node.mass);
    node.acceleration.add(f);
  }

  public void applyFriction(float coeff) {
    applyFriction(coeff, 1.0);
  }

  public void applyFriction(float coeff, float normal) {
    float frictionMag = coeff * normal;
    PVector friction = node.velocity.copy();
    friction.mult(-1.0);
    friction.normalize();
    friction.mult(frictionMag);
    applyForce(friction);
  }

  public void applyGravity(PVector gravity) {
    applyForce(gravity.copy().mult(node.mass));
  }

  public void seek(PVector target) {
    PVector desired = PVector.sub(target, node.location);
    desired.setMag(node.maxSpeed);
    steer(desired);
  }

  public void seek(PVector target, float power) {
    PVector desired = PVector.sub(target, node.location);
    desired.setMag(node.maxSpeed);
    desired.mult(power);
    steer(desired);
  }

  public PVector getSeek(PVector target) {
    PVector desired = PVector.sub(target, node.location);  // A vector pointing from the position to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(node.maxSpeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, node.velocity);
    steer.limit(node.maxForce);  // Limit to maximum steering force
    return steer;
  }

  public void arrive(PVector target) {
    arrive(target, 100);
  }

  public void arrive(PVector target, float maxDist) {
    PVector desired = PVector.sub(target, node.location);
    float dist = desired.mag();
    if (dist < maxDist) {
      float mag = (dist / maxDist) * node.maxSpeed;
      desired.setMag(mag);
    } else {
      desired.setMag(node.maxSpeed);
    }
    steer(desired);
  }

  public void steer(PVector v) {
    PVector steer = PVector.sub(v, node.velocity);
    steer.limit(node.maxForce);
    applyForce(steer);
  }

  public void separate(ArrayList<NodeBase> nodes, float power) {
    PVector force = getSeparate(nodes, 25.0f, false);
    force.mult(power);
    applyForce(force);
  }

  public void separate(ArrayList<NodeBase> nodes, float desiredSeparation, float power) {
    PVector force = getSeparate(nodes, desiredSeparation, false);
    force.mult(power);
    applyForce(force);
  }

  public void separate(ArrayList<NodeBase> nodes, float desiredSeparation, float power, boolean isMassRadius) {
    PVector force = getSeparate(nodes, desiredSeparation, isMassRadius);
    force.mult(power);
    applyForce(force);
  }

  public void separateFromMass(ArrayList<NodeBase> nodes, float power) {
    PVector force = getSeparate(nodes, 0.0, true);
    force.mult(power);
    applyForce(force);
  }

  public void align(ArrayList<NodeBase> nodes, float neighbordist, float power) {
    PVector force = getAlign(nodes, neighbordist);
    force.mult(power);
    applyForce(force);
  }

  public void cohesion(ArrayList<NodeBase> nodes, float neighbordist, float power) {
    PVector force = getCohesion(nodes, neighbordist);
    force.mult(power);
    applyForce(force);
  }

  public void follow(FlowField field) {
    // What is the vector at that spot in the flow field?
    PVector desired = field.lookup(node.location).copy();
    // Scale it up by maxspeed
    desired.mult(node.maxSpeed);
    // Steering is desired minus velocity
    steer(desired);
  }

  public PVector getSeparate (ArrayList<NodeBase> nodes, float desiredSeparation, boolean isMassRadius) {
    float tmpSep = desiredSeparation;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (NodeBase other : nodes) {
      if (other != node) {
        if (isMassRadius) {
          float addSep = other.mass * 0.5 + node.mass * 0.5;
          desiredSeparation = tmpSep + addSep;
        }
        float d = PVector.dist(node.location, other.location);
        // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
        if ((d > 0) && (d < desiredSeparation)) {
          // Calculate vector pointing away from neighbor
          PVector diff = PVector.sub(node.location, other.location);
          diff.normalize();
          diff.div(d);        // Weight by distance
          steer.add(diff);
          count++;            // Keep track of how many
        }
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(node.maxSpeed);
      steer.sub(node.velocity);
      steer.limit(node.maxForce);
    }
    return steer;
  }


  public PVector getAlign(ArrayList<NodeBase> nodes, float neighbordist) {
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (NodeBase other : nodes) {
      float d = PVector.dist(node.location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(node.maxSpeed);
      PVector steer = PVector.sub(sum, node.velocity);
      steer.limit(node.maxForce);
      return steer;
    } else {
      return new PVector(0, 0);
    }
  }

  public PVector getCohesion (ArrayList<NodeBase> nodes, float neighbordist) {
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (NodeBase other : nodes) {
      float d = PVector.dist(node.location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return getSeek(sum);  // Steer towards the position
    } else {
      return new PVector(0, 0);
    }
  }
}

public class PhysicsEdge extends PhysicsBase {

  PhysicsEdge(NodeBase node) {
    super(node);
  }

  public void bounce(AABB3D aabb) {
    bounce(aabb, 1.5);
  }

  public void bounce(AABB3D aabb, float friction) {
    PVector desired = null;

    if (node.location.x > aabb.x + aabb.w * 0.5) {
      PVector norm = new PVector(-1, 0, 0);
      desired = reflect(node.velocity, norm);
      node.location.x = aabb.x + aabb.w * 0.5;
    } else if (node.location.x < aabb.x - aabb.w * 0.5) {
      PVector norm = new PVector(1, 0, 0);
      desired = reflect(node.velocity, norm);
      node.location.x = aabb.x - aabb.w * 0.5;
    }

    if (node.location.y > aabb.y + aabb.h * 0.5) {
      PVector norm = new PVector(0, -1, 0);
      desired = reflect(node.velocity, norm);
      node.location.y = aabb.y + aabb.h * 0.5;
    } else if (node.location.y < aabb.y - aabb.h * 0.5) {
      PVector norm = new PVector(0, 1, 0);
      desired = reflect(node.velocity, norm);
      node.location.y = aabb.y - aabb.h * 0.5;
    }

    if (node.location.z > aabb.z + aabb.d * 0.5) {
      PVector norm = new PVector(0, 0, -1);
      desired = reflect(node.velocity, norm);
      node.location.z = aabb.z + aabb.d * 0.5;
    } else if (node.location.z < aabb.z - aabb.d * 0.5) {
      PVector norm = new PVector(0, 0, 1);
      desired = reflect(node.velocity, norm);
      node.location.z = aabb.z - aabb.d * 0.5;
    }

    if (desired != null) {
      desired.normalize();
      desired.mult(node.velocity.mag());
      node.velocity = desired;
      node.physics.applyFriction(friction);
    }
  }

  public void infinite(AABB3D aabb) {
    if (node.location.x < aabb.x - aabb.w * 0.5) {
      node.location.x = aabb.x + aabb.w * 0.5;
    } else if (node.location.x > aabb.x + aabb.w * 0.5) {
      node.location.x = aabb.x - aabb.w * 0.5;
    }
    if (node.location.y < aabb.y - aabb.h * 0.5) {
      node.location.y = aabb.y + aabb.h * 0.5;
    } else if (node.location.y > aabb.y + aabb.h * 0.5) {
      node.location.y = aabb.y - aabb.h * 0.5;
    } 
    if (node.location.z < aabb.z - aabb.d * 0.5) {
      node.location.z = aabb.z + aabb.d * 0.5;
    } else if (node.location.z > aabb.z + aabb.d * 0.5) {
      node.location.z = aabb.z - aabb.d * 0.5;
    }
  }

  public void warpArround(AABB3D aabb) {
    PVector desired = null;

    if (node.location.x > aabb.x + aabb.w * 0.5) {
      desired = new PVector(node.maxSpeed * -1.0, node.velocity.y, node.velocity.z);
    } else if (node.location.x < aabb.x - aabb.w * 0.5) {
      desired = new PVector(node.maxSpeed, node.velocity.y, node.velocity.z);
    }

    if (node.location.y > aabb.y + aabb.h * 0.5) {
      desired = new PVector(node.velocity.x, node.maxSpeed * -1.0, node.velocity.z);
    } else if (node.location.y < aabb.y - aabb.h * 0.5) {
      desired = new PVector(node.velocity.x, node.maxSpeed, node.velocity.z);
    }

    if (node.location.z > aabb.z + aabb.d * 0.5) {
      desired = new PVector(node.velocity.x, node.velocity.y, node.maxSpeed * -1.0);
    } else if (node.location.z < aabb.z - aabb.d * 0.5) {
      desired = new PVector(node.velocity.x, node.velocity.y, node.maxSpeed);
    }

    // if (node.location.x > aabb.x + aabb.w * 0.5 || 
    //     node.location.x < aabb.x - aabb.w * 0.5 ||
    //     node.location.y > aabb.y + aabb.h * 0.5 ||
    //     node.location.y < aabb.y - aabb.h * 0.5 ||
    //     node.location.z > aabb.z + aabb.d * 0.5 ||
    //     node.location.z < aabb.z - aabb.d * 0.5) {
    //     desired = PVector.sub(new PVector(aabb.x, aabb.y, aabb.z), node.location);
    // }

    if (desired != null) {
      desired.normalize();
      desired.mult(node.maxSpeed);
      node.physics.steer(desired);
    }
  }

  public void respawnAt(PVector respawn, AABB3D aabb) {
    if (   node.location.x > aabb.x + aabb.w * 0.5
      || node.location.x < aabb.x - aabb.w * 0.5
      || node.location.y > aabb.y + aabb.h * 0.5
      || node.location.y < aabb.y - aabb.h * 0.5
      || node.location.z > aabb.z + aabb.d * 0.5
      || node.location.z < aabb.z - aabb.d * 0.5) {
      node.location = respawn.copy();
    }
  }

  public void respawnAtRandom(AABB3D aabb) {
    if (   node.location.x > aabb.x + aabb.w * 0.5
      || node.location.x < aabb.x - aabb.w * 0.5
      || node.location.y > aabb.y + aabb.h * 0.5
      || node.location.y < aabb.y - aabb.h * 0.5
      || node.location.z > aabb.z + aabb.d * 0.5
      || node.location.z < aabb.z - aabb.d * 0.5){
      node.location = new PVector(random(aabb.x - aabb.w * 0.5, aabb.x + aabb.w *0.5), random(aabb.y - aabb.h * 0.5, aabb.y + aabb.h *0.5), random(aabb.z - aabb.d * 0.5, aabb.z + aabb.d *0.5));
    }
  }

  PVector reflect(PVector vel, PVector norm) {
    PVector dir = vel.copy().mult(-1).normalize();
    float dotDN = dir.dot(norm);
    return new PVector(2*norm.x*dotDN - dir.x, 2*norm.y*dotDN - dir.y, 2*norm.z*dotDN - dir.z);
  }
}

public class PhysicsDebug extends PhysicsBase {
  PhysicsDebug(NodeBase node) {
    super(node);
  }

  public void arrow(PGraphics c, float len) {
    PVector shaft = node.velocity.copy().normalize().mult(len).add(node.location);
    PVector arrowRight = node.velocity.copy().normalize().rotate(PI * 0.85).mult(len*0.5).add(shaft);
    PVector arrowLeft = node.velocity.copy().normalize().rotate(-PI * 0.85).mult(len*0.5).add(shaft);
    c.line(node.location.x, node.location.y, node.location.z, shaft.x, shaft.y, shaft.z);
    c.line(shaft.x, shaft.y, shaft.z, arrowRight.x, arrowRight.y, arrowRight.z);
    c.line(shaft.x, shaft.y, shaft.z, arrowLeft.x, arrowLeft.y, arrowLeft.z);
  }

  public void line(PGraphics c, float len) { 
    PVector shaft = node.velocity.copy().normalize().mult(-len).add(node.location);
    c.line(node.location.x, node.location.y, node.location.z, shaft.x, shaft.y, shaft.z);
  }

  public void display(PGraphics c) {
    c.pushStyle();
    c.strokeWeight(node.mass);
    c.point(node.location.x, node.location.y, node.location.z);
    c.popStyle();
  }

  public void displayVelocity(PGraphics c, float inc) {
    displayForce(c, node.velocity.copy(), inc, color(255, 255, 0));
  }

  public void displayAcceleration(PGraphics c, float inc) {
    displayForce(c, node.acceleration.copy(), inc, color(255, 0, 0));
  }

  public void displayForce(PGraphics c, PVector v, float inc, color col) {
    PVector shaft = v.copy().mult(inc).add(node.location);
    c.stroke(col);
    c.line(node.location.x, node.location.y, node.location.z, shaft.x, shaft.y, shaft.z);
  }
}
