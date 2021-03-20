ArrayList<PVector> vertList;
ArrayList<PVector> randSample;

double[] mat = {
  363.3043657461551, 
  0.0, 
  256.2471550098364, 
  0.0, 
  363.93353596977937, 
  209.1975098420263, 
  0.0, 
  0.0, 
  1.0
};


void setup() {
  size(800, 800);

  double[] imat = Maths.invertMatrix(mat, 3, 3);/*
  println("--");
  printArray(mat);
  println("--");
  printArray(imat);
*/
  double[] m = {0, 1, 2, 3, 4, 5, 6, 7, 8};
  double[] v = {0, 1, 2};
  
  double[] vm = Maths.multMV(m, 3, 3, v);
  printArray(vm);
  
  vertList = new ArrayList<PVector>();
  int nbVert = 20;
  for (int i=0; i<nbVert; i++) {
    float a = norm(i, 0, nbVert) * TWO_PI;
    float r = random(20, 100);
    float x = width/2 + cos(a) * r;
    float y = height/2 + sin(a) * r;
    vertList.add(new PVector(x, y));
  }

  randSample = new ArrayList<PVector>();
  int nbSample = 200;
  for (int i=0; i<nbSample; i++) {
    float a = norm(i, 0, nbSample) * TWO_PI;
    float r = random(0, 40);
    float x = width/2 + cos(a) * r;
    float y = height/2 + sin(a) * r;
    randSample.add(new PVector(x, y));
  }
}

void draw() {
  background(20);

  /*
  float alpha = 0;
   PVector loc = new PVector(mouseX, mouseY);
   if(Maths.isInsidePoly(loc, vertList)){
   alpha = 255;
   }*/
  /*
  float ratio = Maths.getInsidePolyRatio(randSample, vertList);
   
   noStroke();
   fill(255);
   text("Inside polygon ratio = "+ratio, 20, 20);
   
   boolean allPointsInsidePoly = Maths.isInsidePoly(randSample, vertList);
   println(allPointsInsidePoly);
   
   noStroke();
   for(PVector v : randSample){
   if(Maths.isInsidePoly(v, vertList)){
   fill(0, 255, 0);
   }else{
   fill(0, 0, 255);
   }
   ellipse(v.x, v.y , 2, 2);
   }
   
   //fill(255, 0, 0, alpha);
   noFill();
   stroke(255, 0, 0);
   beginShape();
   for (PVector v : vertList) {
   vertex(v.x, v.y);
   }
   endShape(CLOSE);
   */
  /* if(Maths.isInsidePoly(loc, vertList)) println("isInsidePoly");*/
}
