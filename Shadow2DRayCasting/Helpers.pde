void displayPoint(PGraphics buffer, PVector loc, float size, int nbCol) {
  buffer.noStroke();
  for (int i=0; i<nbCol; i++) {
    float offsetx = colWidth * i;
    color c = color(i*(360/3.0), 100, 100);
    for (Ray ray : rayList) {
      buffer.pushMatrix();
      buffer.translate(offsetx, 0);
      ray.displayRay(c, size);
      buffer.popMatrix();
    }

    //lightsource
    buffer.fill(c);
    float x = loc.x + offsetx;
    float y = loc.y;
    buffer.ellipse(x, y, size, size);
  }
}

void generateBackground(PGraphics buffer, int seed) {

  randomSeed(seed);
  buffer.beginDraw();
  buffer.background(0);
  buffer.noStroke();
  buffer.fill(255);
  for (int i=0; i<8; i++) {
    float rand = random(1);
    float x = random(buffer.width);
    float y = random(buffer.height);
    float radius = random(buffer.width * 0.05, buffer.width * 0.1);
    if (rand <= 0.33) {
      float eta = random(HALF_PI);
      buffer.pushMatrix();
      buffer.translate(x, y);
      buffer.rotate(eta);
      buffer.rect(0, 0, radius, radius);
      buffer.popMatrix();
    } else if (rand <= 0.33 * 2.0 && rand > 0.33) {
      float eta = random(HALF_PI) + frameCount * 0.01;
      buffer.pushMatrix();
      buffer.translate(x, y);
      buffer.rectMode(CENTER);
      buffer.rotate(eta);
      buffer.rect(0, 0, radius * 0.5, radius * 2.0);
      buffer.rotate(HALF_PI);
      buffer.rect(0, 0, radius * 0.5, radius * 2.0);
      buffer.popMatrix();
    } else {
      buffer.ellipse(x, y, radius, radius);
    }
  }
  buffer.endDraw();
}


//MATHS
boolean linesTouching(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float denominator = ((x2 - x1) * (y4 - y3)) - ((y2 - y1) * (x4 - x3));
  float numerator1 = ((y1 - y3) * (x4 - x3)) - ((x1 - x3) * (y4 - y3));
  float numerator2 = ((y1 - y3) * (x2 - x1)) - ((x1 - x3) * (y2 - y1));

  // Detect coincident lines (has a problem, read below)
  if (denominator == 0) return numerator1 == 0 && numerator2 == 0;

  float r = numerator1 / denominator;
  float s = numerator2 / denominator;

  return (r >= 0 && r <= 1) && (s >= 0 && s <= 1);
}

PVector lineIntersection(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {

  // calculate the distance to intersection point
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
    return new PVector(x1 + (uA * (x2-x1)), y1 + (uA * (y2-y1)));
  }
  return null;
}
