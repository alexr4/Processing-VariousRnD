class FlowField {
  float res;
  int cols, rows;
  ArrayList<PVector> locList;
  ArrayList<PVector> dirList;
  float mainDirection;
  float perlinOffset;
  float perlinSpeed;
  float cornerX, cornerY;

  AABB2D aabb;

  FlowField(AABB2D aabb, float res, float mainDirection, float perlinOffset, float perlinSpeed) {
    initVariables(aabb, res, mainDirection, perlinOffset, perlinSpeed);
  }

  public void initVariables(AABB2D aabb, float res, float mainDirection, float perlinOffset, float perlinSpeed) {
    this.res = res;
    this.aabb = aabb;
    this.perlinOffset = perlinOffset;
    this.perlinSpeed = perlinSpeed;
    this.mainDirection = mainDirection;  
    rows = ceil(aabb.h/this.res);
    cols = ceil(aabb.w/this.res);
    locList = new ArrayList<PVector>();
    dirList = new ArrayList<PVector>();
    cornerX = aabb.x - aabb.w * 0.5;
    cornerY = aabb.y - aabb.h * 0.5;
  }

  public void initPerlin() {
    for (int r=0; r<rows; r++) {
      float roff = r * perlinOffset;
      for (int c=0; c<cols; c++) {
        float coff = c * perlinOffset;
        float perlin = noise(coff, roff, millis() * perlinSpeed);
        float eta = perlin * TWO_PI + mainDirection;
        PVector dir = PVector.fromAngle(eta);
        PVector loc = new PVector(c * res + res * 0.5 + cornerX, r * res + res * 0.5 + cornerY);
        dirList.add(dir);
        locList.add(loc);
      }
    }
  }

  void updatePerlin(float time) {
    for (int r=0; r<rows; r++) {
      float roff = r * perlinOffset;
      for (int c=0; c<cols; c++) {
        int index = c + r * cols;
        float coff = c * perlinOffset;
        float perlin = noise(coff, roff, time * perlinSpeed);
        float eta = perlin * TWO_PI + mainDirection;
        PVector dir = PVector.fromAngle(eta);
        dirList.set(index, dir);
      }
    }
  }

  public void initCurl3D(float eps) {
    for (int r=0; r<rows; r++) {
      float roff = r * perlinOffset;
      for (int c=0; c<cols; c++) {
        float coff = c * perlinOffset;
        PVector dir = computeCurl3DAt(coff, roff, millis() * perlinSpeed, eps).normalize();
        //dir.mult(TWO_PI);
        PVector loc = new PVector(c * res + res * 0.5 + cornerX, r * res + res * 0.5 + cornerY);
        dirList.add(dir);
        locList.add(loc);
      }
    }
  }

  void updateCurl3D(float time, float eps) {
    for (int r=0; r<rows; r++) {
      float roff = r * perlinOffset;
      for (int c=0; c<cols; c++) {
        int index = c + r * cols;
        float coff = c * perlinOffset;
        PVector dir = computeCurl3DAt(coff, roff, time * perlinSpeed, eps).normalize();
        //dir.mult(TWO_PI);
        dirList.set(index, dir);
      }
    }
  }
  
   public void initCurl2D(float eps) {
    for (int r=0; r<rows; r++) {
      float roff = r * perlinOffset;
      for (int c=0; c<cols; c++) {
        float coff = c * perlinOffset;
        PVector dir = computeCurl2DAt(coff, roff, eps).normalize();
        //dir.mult(TWO_PI);
        PVector loc = new PVector(c * res + res * 0.5 + cornerX, r * res + res * 0.5 + cornerY);
        dirList.add(dir);
        locList.add(loc);
      }
    }
  }

  void updateCurl2D(float time, float eps) {
    for (int r=0; r<rows; r++) {
      float roff = r * perlinOffset;
      for (int c=0; c<cols; c++) {
        int index = c + r * cols;
        float coff = c * perlinOffset;
        PVector dir = computeCurl2DAt(coff + time * 0.001, roff + time * 0.001, eps).normalize();
        //dir.mult(TWO_PI);
        dirList.set(index, dir);
      }
    }
  }


  void debug(PGraphics buffer, int inc) {
    buffer.noFill();
    for (int i=0; i<dirList.size(); i++) {
      int x = i % cols;
      int y = (i - x) / cols;
      if ((x + y) % inc == 0) {
        PVector dir = dirList.get(i);
        PVector loc = locList.get(i);

        float len = sqrt(res * res + res * res) * 0.5;
        PVector shaft = dir.copy().mult(len).add(loc);
        PVector arrowRight = dir.copy().rotate(PI * 0.85).mult(len*0.5).add(shaft);
        PVector arrowLeft = dir.copy().rotate(-PI * 0.85).mult(len*0.5).add(shaft);
        buffer.rectMode(CENTER);
        buffer.stroke(150);
        buffer.line(loc.x, loc.y, shaft.x, shaft.y);
        buffer.line(shaft.x, shaft.y, arrowRight.x, arrowRight.y);
        buffer.line(shaft.x, shaft.y, arrowLeft.x, arrowLeft.y);
      }
    }
  }

  PVector computeCurl3DAt(float x, float y, float z, float eps) {
    //based Pete Werner implementation on http://platforma-kooperativa.org/media/uploads/curl_noise_slides.pdf
    //float eps = 1.0; //here epsilon is a global
    float n1, n2, a, b;
    PVector curl = new PVector();  

    //compute gradients
    n1 = noise(x, y + eps, z);
    n2 = noise(x, y - eps, z);
    a = (n1 - n2) / (2 * eps);

    n1 = noise(x, y, z + eps);
    n2 = noise(x, y, z - eps);
    b = (n1 - n2) / (2 * eps);

    curl.x = a - b;

    n1 = noise(x, y, z + eps);
    n2 = noise(x, y, z - eps); 
    a = (n1 - n2) / (2 * eps);

    n1 = noise(x + eps, y, z);  
    n2 = noise(x + eps, y, z);  
    b = (n1 - n2) / (2 * eps);  

    curl.y = a - b;

    n1 = noise(x + eps, y, z);
    n2 = noise(x - eps, y, z);
    a = (n1 - n2) / (2 * eps);

    n1 = noise(x, y + eps, z);
    n2 = noise(x, y - eps, z);
    b = (n1 - n2) / (2 * eps); 

    curl.z = a - b;

    return curl;
  }

  PVector computeCurl2DAt(float x, float y, float eps) {
    //based Pete Werner implementation on http://platforma-kooperativa.org/media/uploads/curl_noise_slides.pdf
    //float eps = 1.0; //here epsilon is a global
    float n1, n2, a, b;

    //compute gradients
    n1 = noise(x, y + eps);
    n2 = noise(x, y - eps);
    a = (n1 - n2) / (2 * eps);

    n1 = noise(x + eps, y);
    n2 = noise(x - eps, y);
    b = (n1 - n2) / (2 * eps);

    return new PVector(a, -b);
  }


  PVector lookup(PVector lookup) {
    int c = floor((lookup.x - cornerX)/aabb.w * cols);
    int r = floor((lookup.y - cornerY)/aabb.h * rows);
    c = constrain(c, 0, cols-1);
    r = constrain(r, 0, rows-1);

    int index = c + r * cols;
    return dirList.get(index);
  }

  PVector lookupPosition(PVector lookup) {
    int c = floor((lookup.x - cornerX)/aabb.w * cols);
    int r = floor((lookup.y - cornerY)/aabb.h * rows);
    c = constrain(c, 0, cols-1);
    r = constrain(r, 0, rows-1);

    int index = c + r * cols;
    return locList.get(index);
  }
}
