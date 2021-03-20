class FlowField {
  float res;
  int cols, rows, depth;
  ArrayList<PVector> locList;
  ArrayList<PVector> dirList;
  PVector mainDirection;
  float perlinOffset;
  float perlinSpeed;
  float cornerX, cornerY, cornerZ;
  PVector center;
  float hyp;

  AABB3D aabb;

  FlowField(AABB3D aabb, float res, PVector mainDirection, float perlinOffset, float perlinSpeed) {
    initVariables(aabb, res, mainDirection, perlinOffset, perlinSpeed);
  }

  public void initVariables(AABB3D aabb, float res, PVector mainDirection, float perlinOffset, float perlinSpeed) {
    this.res = res;
    this.aabb = aabb;
    this.perlinOffset = perlinOffset;
    this.perlinSpeed = perlinSpeed;
    this.mainDirection = mainDirection;  
    rows = ceil(aabb.h/this.res);
    cols = ceil(aabb.w/this.res);
    depth = ceil(aabb.d/this.res);
    locList = new ArrayList<PVector>();
    dirList = new ArrayList<PVector>();
    cornerX = aabb.x - aabb.w * 0.5;
    cornerY = aabb.y - aabb.h * 0.5;
    cornerZ = aabb.z - aabb.d * 0.5;
    center = new PVector(aabb.x, aabb.y, aabb.z);
    hyp = sqrt(pow(aabb.w, 2) + pow(aabb.h, 2) + pow(aabb.d, 2));
  }

  public void initPerlin() {
    for (int d=0; d<depth; d++) {
      float doff = d * perlinOffset;
      for (int r=0; r<rows; r++) {
        float roff = r * perlinOffset;
        for (int c=0; c<cols; c++) {
          float coff = c * perlinOffset;
          float perlinTheta = noise(coff, roff, doff);
          float perlinPhi = noise(doff, roff, coff);
          float theta = perlinTheta * PI;// + mainDirection;
          float phi   = perlinPhi * TWO_PI;// + mainDirection;
          PVector dir = new PVector(
            sin(theta) * cos(phi), 
            sin(theta) * sin(phi), 
            cos(theta)
            );
          dir.add(mainDirection);
          dir.normalize();
          PVector loc = new PVector(c * res + res * 0.5 + cornerX, r * res + res * 0.5 + cornerY, d * res + res * 0.5 + cornerZ);
          dirList.add(dir);
          locList.add(loc);
        }
      }
    }
  }

  void updatePerlin(float time) {
    for (int d=0; d<depth; d++) {
      float doff = d * perlinOffset;
      for (int r=0; r<rows; r++) {
        float roff = r * perlinOffset;
        for (int c=0; c<cols; c++) {
          float coff = c * perlinOffset;
          int index = to1D(c, r, d);//x + WIDTH * (y + DEPTH * z) https://stackoverflow.com/questions/7367770/how-to-flatten-or-index-3d-array-in-1d-array
          float perlinTheta = noise(coff + time, roff + time, doff + time);
          float perlinPhi = noise(doff + time, roff + time, coff + time);
          float theta = perlinTheta * PI;// + mainDirection;
          float phi   = perlinPhi * TWO_PI;// + mainDirection;
          PVector dir = new PVector(
            sin(theta) * cos(phi), 
            sin(theta) * sin(phi), 
            cos(theta)
            );
          dir.add(mainDirection);
          dir.normalize();
          dirList.set(index, dir);
        }
      }
    }
  }

  public void initCurl3D(float eps) {
    for (int d=0; d<depth; d++) {
      float doff = d * perlinOffset;
      for (int r=0; r<rows; r++) {
        float roff = r * perlinOffset;
        for (int c=0; c<cols; c++) {
          float coff = c * perlinOffset;
          PVector dir = computeCurl3DAt(coff, roff, doff, eps).normalize();
          //dir.mult(TWO_PI);
          PVector loc = new PVector(c * res + res * 0.5 + cornerX, r * res + res * 0.5 + cornerY, d * res + res * 0.5 + cornerZ);
          dirList.add(dir);
          locList.add(loc);
        }
      }
    }
  }
  
  void updateCurl3D(float time, float eps) {
    updateCurl3D(time, eps, 0.075, 0.075);
  }
  
  void updateCurl3D(float time, float eps, float edge, float thickness) {
    for (int d=0; d<depth; d++) {
      float doff = d * perlinOffset;
      for (int r=0; r<rows; r++) {
        float roff = r * perlinOffset;
        for (int c=0; c<cols; c++) {
          float coff = c * perlinOffset;
          int index = to1D(c, r, d);//x + WIDTH * (y + DEPTH * z) https://stackoverflow.com/questions/7367770/how-to-flatten-or-index-3d-array-in-1d-array
          //float perlinTheta = noise(coff + time, roff + time, doff + time);
          PVector dir = computeCurl3DAt(coff + time, roff + time, doff + time, eps).normalize();
          PVector loc = locList.get(index);

          //SDF
          float boxSDF = signedDistanceFromBox(loc, new PVector(aabb.w, aabb.h, aabb.d).mult(0.25));
          float normBoxSDF = boxSDF / hyp;
          float sdfstep = smoothstep(edge, edge+thickness, normBoxSDF);

          //float distToCenter = PVector.dist(center, loc) / (hyp * 0.45);
          PVector desired = PVector.sub(center, loc).normalize();
          dir = PVector.lerp(dir, desired, sdfstep);
          //dir.mult(TWO_PI);
          dirList.set(index, dir);
        }
      }
    }
  }



  void debug(PGraphics buffer, int inc) {
    buffer.noFill();
    buffer.pushStyle();
    for (int i=0; i<dirList.size(); i++) {
      int[] coords = to3D(i);
      int x = coords[0];
      int y = coords[1];
      int z = coords[2];
      if ((x + y + z) % inc == 0) {
        PVector dir = dirList.get(i);
        PVector loc = locList.get(i);


        float len = sqrt(res * res + res * res) * 0.5;
        PVector shaft = dir.copy().mult(len).add(loc);

        buffer.stroke(150, 15);
        buffer.noFill();
        buffer.strokeWeight(1);
        buffer.pushMatrix();
        buffer.translate(loc.x, loc.y, loc.z);
        buffer.box(this.res);

        buffer.popMatrix();
        buffer.stroke(150);
        buffer.line(loc.x, loc.y, loc.z, shaft.x, shaft.y, shaft.z);
        buffer.strokeWeight(4);
        buffer.point(shaft.x, shaft.y, shaft.z);
      }
    }
    buffer.popStyle();
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
    int c = round((lookup.x - cornerX)/aabb.w * cols);
    int r = round((lookup.y - cornerY)/aabb.h * rows);
    int d = round((lookup.z - cornerZ)/aabb.d * rows);
    c = constrain(c, 0, cols-1);
    r = constrain(r, 0, rows-1);
    d = constrain(d, 0, depth-1);

    int index = to1D(c, r, d);
    return dirList.get(index);
  }

  PVector lookupPosition(PVector lookup) {
    int c = round((lookup.x - cornerX)/aabb.w * cols);
    int r = round((lookup.y - cornerY)/aabb.h * rows);
    int d = round((lookup.z - cornerZ)/aabb.d * rows);
    c = constrain(c, 0, cols-1);
    r = constrain(r, 0, rows-1);
    d = constrain(d, 0, depth-1);

    int index = to1D(c, r, d);
    return locList.get(index);
  }

  public int to1D( int x, int y, int z) {
    return (z * cols * rows) + (y * cols) + x;
  }

  public int[] to3D( int idx ) {
    final int z = idx / (cols * rows);
    idx -= (z * cols * rows);
    final int y = idx / cols;
    final int x = idx % cols;
    return new int[]{ x, y, z };
  }
}
