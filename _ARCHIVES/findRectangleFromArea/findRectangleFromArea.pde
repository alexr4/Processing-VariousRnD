int area = 512*424;//7680*4320;

void setup() {
  size(500, 500, P2D);
  
  frameRate(60);
  int st = millis();
  int tt = 1000/60;
  println("target time = "+tt);
  println("process start = "+(millis())+"\n");
  
  findRectangleFromArea(area);
  
  int et = millis();
  int pt = (et-st);
  double ptm = pt/(double)tt;
  println("\nprocess end = "+et);
  println("process time = "+pt);
  println("nb frame = "+ptm);
}

void draw() {
}

void findRectangleFromArea(int area) {
  float sqrtArea = sqrt(area);
  int isqrtArea = ceil(sqrtArea);
  
  int w = 0;
  int h = 0;
  //method 1
  for (h=int(isqrtArea); h>0; h--) {
    // integer division discarding remainder:
    w = area/h;
    if ( w*h == area ) {
      // closest pair is (w,h)
      break;
    }
  }

  println(
    "area        :"+area+"\n"+
    "sqrt area   :"+sqrtArea+"\n"+
    "width       :"+w+"\n"+
    "height      :"+h+"\n"+
    "final area  :"+(w*h)
    );
    
    PImage img = createImage(w, h, ARGB);
    println(img.width, img.height);
}
