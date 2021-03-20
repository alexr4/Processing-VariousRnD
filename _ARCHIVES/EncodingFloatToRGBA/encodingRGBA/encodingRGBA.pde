 /**
 * RGBA performances encoding test
 */
//Aras Pranckevičius
//Skytiger approach : https://skytiger.wordpress.com/2010/12/01/packing-depth-into-color/

int wi = 100;
PImage encodedImage;

double PID = 3.1415926535897932384626433832795028841971693993751058209749445923078164062;


void settings() {
  size(wi, wi, P2D);
}

void setup() {
  encodedImage = new PImage(1, 1, ARGB);
  encodedImage.resize(wi, wi);
  //PID = 98742.0/216236.0;
  double normPID = PID / (PID * 2.0);
  
  int PIDE = skfloatToARGB32(normPID);
  double PIDD = skARGB32Tofloat(PIDE);
  double retreivedValue = PIDD * TWO_PI;
  
  println("entry :"+PID+"\n"+
          "retreived :"+retreivedValue+"\n"+
          "norm entry :"+normPID+"\n"+
          "norm retreived :"+PIDD+"\n"+
          "ARGB value :"+PIDE);
  
}

void draw() {
}


public static double fract(double v) {
  return v % 1.0;
}

public static double[] getRGBA(int argb) {
  double a = argb >> 24 & 0xFF;
  double r = argb >> 16 & 0xFF;
  double g = argb >> 8 & 0xFF;
  double b = argb & 0xFF;
  double[] argbArray = {r, g, b, a};
  return argbArray;
}

public static double dot(double[] A, double[] B) {
    double sum = 0;
    for (int i=0; i<A.length && i< B.length; i++) {
      double componentsMult = A[i] * B[i];
      sum += componentsMult;
    }

    return sum/255.0;
  }
