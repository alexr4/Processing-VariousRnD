int getIndex(int x, int y) {
  x = constrain(x, 0, N-1);
  y = constrain(y, 0, N-1);
  return x + y * N;
}


class Fluid {
  int size;
  float dt; //timestamp
  float diffusion; //diffusion
  float viscosity; //viscosity

  float[] s; //prev density
  float[] density; //density

  //Vector field
  float[] Vx; 
  float[] Vy;

  //previous vector field
  float[] Vx0;
  float[] Vy0;

  Fluid(float dt, float diffusion, float viscosity) {
    this.size = N;
    this.dt = dt;
    this.diffusion = diffusion;
    this.viscosity = viscosity;

    this.s = new float[N * N];
    this.density = new float[N * N];

    this.Vx =  new float[N * N];
    this.Vy =  new float[N * N];

    this.Vx0 = new float[N * N];
    this.Vy0 = new float[N * N];
  }

  void step()
  {
    int N          = this.size;
    float visc     = this.viscosity;
    float diff     = this.diffusion;
    float dt       = this.dt;
    float[]Vx      = this.Vx;
    float[]Vy      = this.Vy;
    float[]Vx0     = this.Vx0;
    float[]Vy0     = this.Vy0;
    float[]s       = this.s;
    float[]density = this.density;

    diffuse(1, Vx0, Vx, visc, dt, 4);
    diffuse(2, Vy0, Vy, visc, dt, 4);

    project(Vx0, Vy0, Vx, Vy, 4);

    advect(1, Vx, Vx0, Vx0, Vy0, dt);
    advect(2, Vy, Vy0, Vx0, Vy0, dt);

    project(Vx, Vy, Vx0, Vy0, 4);

    diffuse(0, s, density, diff, dt, 4);
    advect(0, density, s, Vx, Vy, dt);
  }

  void addDensity(int x, int y, float amount)
  {
    int index = getIndex(x, y);
    this.density[index] += amount;
  }

  void addVelocity(int x, int y, float amountX, float amountY)
  {
    int index = getIndex(x, y);
    this.Vx[index] += amountX;
    this.Vy[index] += amountY;
  }

  void renderDensity() {
    for (int i=0; i<N; i++) {
      for (int j=0; j<N; j++) {
        float x = i * scale;
        float y = j * scale;
        float d = this.density[getIndex(i, j)];
        fill(d);
        noStroke();
        rect(x, y, scale, scale);
      }
    }
  }

  void fadeDensity(float fd) {
    for (int i=0; i<this.density.length; i++) {
      float d = this.density[i];
      this.density[i] = constrain(d-fd, 0, 255);
    }
  }


  void renderVelocity(float limit, float scaler) {
    for (int i=0; i<N; i++) {
      for (int j=0; j<N; j++) {
        float x = i * scale;
        float y = j * scale;
        float vx = this.Vx[getIndex(i, j)];
        float vy = this.Vy[getIndex(i, j)];
        PVector v = new PVector(vx, vy);
        v.mult(15.0);
        stroke(255, 100);
        if (!(abs(vx) < limit && abs(vy) <= limit)) {
          beginShape(LINES);
          stroke(255, 255 * v.mag() + 20);
          vertex(x, y);
          stroke(255, 20);
          vertex(x + vx * scale * scaler, y + vy* scale * scaler);
          endShape();

          //line(x, y, x + vx * scale * scaler, y + vy* scale * scaler);
        }
      }
    }
  }

  void renderVelocity(float scaler) {
    noStroke();
    for (int i=0; i<N; i++) {
      for (int j=0; j<N; j++) {
        float x = i * scale;
        float y = j * scale;
        float vx = this.Vx[getIndex(i, j)];
        float vy = this.Vy[getIndex(i, j)];
        PVector v = new PVector(vx, vy);
        float mag = v.mag();
        float red = noise(x * 0.005, y * 0.005, mag);
        float green = noise(x * 0.05, y * 0.05, mag);
        float blue = noise(x * 0.0025, y * 0.0025, mag);
        // v.normalize();
        float gamma = atan2(v.y, v.x);
        // println(gamma);

        pushMatrix();
        translate(x, y);
        rotate(gamma);
        fill(255, 255.0 * red);
        rect(0, 0, scaler + (scaler * 0.25) * mag * 100.0, 2.0 + 2.0 * mag * 100.0);
        popMatrix();

        /*v.mult(scaler);
         stroke(255, 100);
         strokeWeight(1);
         beginShape(LINES);
         vertex(x, y);
         vertex(x + v.x, y + v.y);
         endShape();*/
      }
    }
  }
}
