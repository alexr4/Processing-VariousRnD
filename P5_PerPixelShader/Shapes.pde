
int resAlpha;
int resBeta;
float radius;
float alpha, beta, x, y, z;
int cols, rows;
PVector[][] vertice;

void initShape(int resA, int resB, float rad) {
  //varibales
  resAlpha = resA;
  resBeta = resB;
  radius = rad;

  cols = resAlpha;//360/resAlpha;
  rows = resBeta;///resBeta;

  //println(cols-1);

  vertice = new PVector[cols][rows];

  initSphere();
}


void initSphere()
{
  for (int i = 0; i<cols; i++)
  {

    for (int j = 0; j<rows; j++)
    { 
      alpha = map(i, 0, cols-1, 0, PI);
      beta = map(j, 0, rows-1, 0, TWO_PI);
      //radius = random(100, 110);

      x = sin(alpha) * cos(beta) * radius;
      y = sin(alpha) * sin(beta) * radius;
      z = cos(alpha) * radius;

      vertice[i][j] = new PVector(x, y, z);
    }
  }
}

void sphere(PGraphics b)
{

  b.beginShape(QUAD);
  b.stroke(255, 5);

  for (int i =0; i<cols-1; i++)
  {
    for (int j=0; j<rows-1; j++)
    {
      PVector v0 = vertice[i][j];
      PVector v1 = vertice[i][j+1];
      PVector v2 = vertice[i+1][j];
      PVector v3 = vertice[i+1][j+1];

      float uvx0 = norm(i, 0, cols-1);
      float uvy0 = norm(j, 0, rows-1);
      float uvx1 = norm(i, 0, cols-1);
      float uvy1 = norm(j+1, 0, rows-1);
      float uvx2 = norm(i+1, 0, cols-1);
      float uvy2 = norm(j, 0, rows-1);
      float uvx3 = norm(i+1, 0, cols-1);
      float uvy3 = norm(j+1, 0, rows-1);
      PVector nV0 = v0.get();
      PVector nV1 = v1.get();
      PVector nV2 = v2.get();
      PVector nV3 = v3.get();
      nV0.normalize().mult(-1);
      nV1.normalize().mult(-1);
      nV2.normalize().mult(-1);
      nV3.normalize().mult(-1);

      //b.stroke(255, 10);
      //b.strokeWeight(1);
      //noFill();
      //fill(r0, g0, b0, alpha);
      b.normal(nV0.x, nV0.y, nV0.z);
      b.vertex(v0.x, v0.y, v0.z, uvx0, uvy0);
      //fill(r1, g1, b1, alpha);
      b.normal(nV1.x, nV1.y, nV1.z);
      b.vertex(v1.x, v1.y, v1.z, uvx1, uvy1);
      //fill(r3, g3, b3, alpha);
      b.normal(nV3.x, nV3.y, nV3.z);
      b.vertex(v3.x, v3.y, v3.z, uvx3, uvy3);
      //fill(r2, g2, b2, alpha);
      b.normal(nV2.x, nV2.y, nV2.z);
      b.vertex(v2.x, v2.y, v2.z, uvx2, uvy2);
    }
  }

  b.endShape(CLOSE);
}
