//easing model
static class NormalEasing
{
  // ==================================================
  // Easing Equations by Robert Penner : http://robertpenner.com/easing/
  // http://www.timotheegroleau.com/Flash/experiments/easing_function_generator.htm
  // Based on ActionScript implementation by gizma : http://gizma.com/easing/
  // Processing implementation by Bonjour, Interactive Lab
  // soit time le temps actuelle ou valeur x à l'instant t;
  // soit start la position x de départ;
  // soit end l'increment de s donnant la position d'arrivee a = s + e;
  // soit duration la durée de l'opération
  // ==================================================
  // Linear
  static float linear(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return inc*time/duration + start;
  }

  // Quadratic
  static float inQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return inc * time * time + start;
  }

  static float outQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return -inc * time * (time - 2) + start;
  }

  static float inoutQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * time * time + start;
    } else
    {
      time--;
      return - inc/2 * (time * (time - 2) - 1) + start;
    }
  }

  //Cubic
  static float inCubic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return inc * pow(time, 3) + start;
  }

  static float outCubic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return inc * (pow(time, 3) + 1) + start;
  }

  static float inoutCubic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(time, 3) + start;
    } else
    {
      time -= 2;
      return inc/2 * (pow(time, 3) + 2) + start;
    }
  }

  //Quatric
  static float inQuartic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return inc * pow(time, 4) + start;
  }

  static float outQuartic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return -inc * (pow(time, 4) - 1) + start;
  }

  static float inoutQuartic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(time, 4) + start;
    } else
    {
      time -= 2;
      return -inc/2 * (pow(time, 4) - 2) + start;
    }
  }

  //Quintic
  static float inQuintic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return inc * pow(time, 5) + start;
  }

  static float outQuintic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return inc * (pow(time, 5) + 1) + start;
  }

  static float inoutQuintic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(time, 5) + start;
    } else
    {
      time -= 2;
      return inc/2 * (pow(time, 5) + 2) + start;
    }
  }

  //Sinusoïdal
  static float inSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return -inc * cos(time/duration * HALF_PI) + inc + start;
  }

  static float outSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return inc * sin(time/duration * HALF_PI) + start;
  }

  static float inoutSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return -inc/2 * (cos(PI * time/duration) - 1) + start;
  }

  //Exponential
  static float inExp(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    //return inc * pow(2, 10 * (time/duration - 1)) + start;
    if (time <= 0)
    {
      return start;
    } else
    {
      return inc * pow(2, 10 * (time/duration-1)) + start;
    }
  }

  static float outExp(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    if (time >= 1.0)
    {
      return 1.0;
    } else
    {
      return inc * (-pow(2, -10 * (time/duration)) + 1) + start;
    }
  }

  static float inoutExp(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(2, 10 * (time-1)) + start;
    } else
    {
      time --;
      return inc/2 * (-pow(2, -10 * time) + 2) + start;
    }
  }

  //Circular
  static float inCirc(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return -inc * (sqrt(1 - time * time) - 1) + start;
  }

  static float outCirc(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return inc * sqrt(1 - time * time) + start;
  }

  static float inoutCirc(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return -inc/2 * (sqrt(1 - time * time) - 1) + start;
    } else
    {
      time -= 2;
      return inc/2 * (sqrt(1 - time * time) + 1) + start;
    }
  }
}




static class Easing
{
  // ==================================================
  // Easing Equations by Robert Penner : http://robertpenner.com/easing/
  // http://www.timotheegroleau.com/Flash/experiments/easing_function_generator.htm
  // Based on ActionScript implementation by gizma : http://gizma.com/easing/
  // Processing implementation by Bonjour, Interactive Lab
  // soit time le temps actuelle ou valeur x à l'instant t;
  // soit start la position x de départ;
  // soit end l'increment de s donnant la position d'arrivee a = s + e;
  // soit duration la durée de l'opération
  // ==================================================
  // Linear
  static float linear(float time, float start, float end, float duration)
  { 
    float inc = end - start;
    return inc*time/duration + start;
  }

  // Quadratic
  static float inQuad(float time, float start, float end, float duration)
  {
    time /= duration;
    float inc = end - start;
    return inc * time * time + start;
  }

  static float outQuad(float time, float start, float end, float duration)
  {
    time /= duration;
    float inc = end - start;
    return -inc * time * (time - 2) + start;
  }

  static float inoutQuad(float time, float start, float end, float duration)
  {
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * time * time + start;
    } else
    {
      time--;
      return - inc/2 * (time * (time - 2) - 1) + start;
    }
  }

  //Cubic
  static float inCubic(float time, float start, float end, float duration)
  {
    time /= duration;
    float inc = end - start;
    return inc * pow(time, 3) + start;
  }

  static float outCubic(float time, float start, float end, float duration)
  {
    time /= duration;
    time --;
    float inc = end - start;
    return inc * (pow(time, 3) + 1) + start;
  }

  static float inoutCubic(float time, float start, float end, float duration)
  {
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(time, 3) + start;
    } else
    {
      time -= 2;
      return inc/2 * (pow(time, 3) + 2) + start;
    }
  }

  //Quatric
  static float inQuartic(float time, float start, float end, float duration)
  {
    time /= duration;
    float inc = end - start;
    return inc * pow(time, 4) + start;
  }

  static float outQuartic(float time, float start, float end, float duration)
  {
    time /= duration;
    time --;
    float inc = end - start;
    return -inc * (pow(time, 4) - 1) + start;
  }

  static float inoutQuartic(float time, float start, float end, float duration)
  {
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(time, 4) + start;
    } else
    {
      time -= 2;
      return -inc/2 * (pow(time, 4) - 2) + start;
    }
  }

  //Quintic
  static float inQuintic(float time, float start, float end, float duration)
  {
    time /= duration;
    float inc = end - start;
    return inc * pow(time, 5) + start;
  }

  static float outQuintic(float time, float start, float end, float duration)
  {
    time /= duration;
    time --;
    float inc = end - start;
    return inc * (pow(time, 5) + 1) + start;
  }

  static float inoutQuintic(float time, float start, float end, float duration)
  {
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(time, 5) + start;
    } else
    {
      time -= 2;
      return inc/2 * (pow(time, 5) + 2) + start;
    }
  }

  //Sinusoïdal
  static float inSin(float time, float start, float end, float duration)
  {
    float inc = end - start;
    return -inc * cos(time/duration * HALF_PI) + inc + start;
  }

  static float outSin(float time, float start, float end, float duration)
  {
    float inc = end - start;
    return inc * sin(time/duration * HALF_PI) + start;
  }

  static float inoutSin(float time, float start, float end, float duration)
  {
    float inc = end - start;
    return -inc/2 * (cos(PI * time/duration) - 1) + start;
  }

  //Exponential
  static float inExp(float time, float start, float end, float duration)
  {
    float inc = end - start;
    //return inc * pow(2, 10 * (time/duration - 1)) + start;
    if (time <= 0)
    {
      return start;
    } else
    {
      return inc * pow(2, 10 * (time/duration-1)) + start;
    }
  }

  static float outExp(float time, float start, float end, float duration)
  {
    float inc = end - start;
    if (time >= 1.0)
    {
      return 1.0;
    } else
    {
      return inc * (-pow(2, -10 * (time/duration)) + 1) + start;
    }
  }

  static float inoutExp(float time, float start, float end, float duration)
  {
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return inc/2 * pow(2, 10 * (time-1)) + start;
    } else
    {
      time --;
      return inc/2 * (-pow(2, -10 * time) + 2) + start;
    }
  }

  //Circular
  static float inCirc(float time, float start, float end, float duration)
  {
    time /= duration;
    float inc = end - start;
    return -inc * (sqrt(1 - time * time) - 1) + start;
  }

  static float outCirc(float time, float start, float end, float duration)
  {
    time /= duration;
    time --;
    float inc = end - start;
    return inc * sqrt(1 - time * time) + start;
  }

  static float inoutCirc(float time, float start, float end, float duration)
  {
    time /= duration/2;
    float inc = end - start;
    if (time < 1)
    {
      return -inc/2 * (sqrt(1 - time * time) - 1) + start;
    } else
    {
      time -= 2;
      return inc/2 * (sqrt(1 - time * time) + 1) + start;
    }
  }
}



static class MathsVector
{
  static public PVector computeRodrigueRotation(PVector k, PVector v, float theta)
  {
    // Olinde Rodrigues formula : Vrot = v* cos(theta) + (k x v) * sin(theta) + k * (k . v) * (1 - cos(theta));
    PVector kcrossv = k.cross(v);
    float kdotv = k.dot(v);

    float x = v.x * cos(theta) + kcrossv.x * sin(theta) + k.x * kdotv * (1 - cos(theta));
    float y = v.y * cos(theta) + kcrossv.y * sin(theta) + k.y * kdotv * (1 - cos(theta));
    float z = v.z * cos(theta) + kcrossv.z * sin(theta) + k.z * kdotv * (1 - cos(theta));

    PVector nv = new PVector(x, y, z);
    nv.normalize();

    return  nv;
  }

  static public PVector compute2DRotationVector(PVector k, float eta)
  {
    float x = k.x * cos(eta) - k.y * sin(eta);
    float y = k.x * sin(eta) + k.y * cos(eta);

    return new PVector(x, y);
  }

  static public PVector compute3DRotationVector(PVector k, float eta, char axis)
  {
    /*
  around Z-axis would be
     
     |cos θ   -sin θ   0| |x|   |x cos θ - y sin θ|   |x'|
     |sin θ    cos θ   0| |y| = |x sin θ + y cos θ| = |y'|
     |  0       0      1| |z|   |        z        |   |z'|
     
     around Y-axis would be
     
     | cos θ    0   sin θ| |x|   | x cos θ + z sin θ|   |x'|
     |   0      1       0| |y| = |         y        | = |y'|
     |-sin θ    0   cos θ| |z|   |-x sin θ + z cos θ|   |z'|
     
     around X-axis would be
     
     |1     0           0| |x|   |        x        |   |x'|
     |0   cos θ    -sin θ| |y| = |y cos θ - z sin θ| = |y'|
     |0   sin θ     cos θ| |z|   |y sin θ + z cos θ|   |z'|
     */
    if (axis == 'x' || axis == 'X')
    {
      float x = k.x;
      float y = k.y * cos(eta) - k.z * sin(eta);
      float z = k.y * sin(eta) + k.z * cos(eta);
      PVector v = new PVector(x, y, z);
      v.normalize();

      return v;
    } else if (axis == 'y' || axis == 'Y')
    {
      float x = k.x * cos(eta) + k.z * sin(eta);
      float y = k.y;
      float z = k.x * -1 * sin(eta) + k.z * cos(eta);
      PVector v = new PVector(x, y, z);
      v.normalize();

      return v;
    } else if (axis == 'z' || axis == 'Z')
    {
      float x = k.x * cos(eta) - k.y * sin(eta);
      float y = k.x * sin(eta) + k.y * cos(eta);
      float z = k.z;

      PVector v = new PVector(x, y, z);
      v.normalize();

      return v;
    } else
    {
      println("pick a correct axis of rotation");
      return null;
    }
  }
}

static class ImageComputation
{
  // ==================================================
  // Super Fast Blur v1.1
  // by Mario Klingemann 
  // <http://incubator.quasimondo.com>
  // ==================================================
  static void fastblur(PImage img, int radius)
  {
    if (radius<1) {
      return;
    }
    int w=img.width;
    int h=img.height;
    int wm=w-1;
    int hm=h-1;
    int wh=w*h;
    int div=radius+radius+1;
    int r[]=new int[wh];
    int g[]=new int[wh];
    int b[]=new int[wh];
    int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
    int vmin[] = new int[max(w, h)];
    int vmax[] = new int[max(w, h)];
    int[] pix=img.pixels;
    int dv[]=new int[256*div];
    for (i=0; i<256*div; i++) {
      dv[i]=(i/div);
    }

    yw=yi=0;

    for (y=0; y<h; y++) {
      rsum=gsum=bsum=0;
      for (i=-radius; i<=radius; i++) {
        p=pix[yi+min(wm, max(i, 0))];
        rsum+=(p & 0xff0000)>>16;
        gsum+=(p & 0x00ff00)>>8;
        bsum+= p & 0x0000ff;
      }
      for (x=0; x<w; x++) {

        r[yi]=dv[rsum];
        g[yi]=dv[gsum];
        b[yi]=dv[bsum];

        if (y==0) {
          vmin[x]=min(x+radius+1, wm);
          vmax[x]=max(x-radius, 0);
        }
        p1=pix[yw+vmin[x]];
        p2=pix[yw+vmax[x]];

        rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
        gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
        bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
        yi++;
      }
      yw+=w;
    }

    for (x=0; x<w; x++) {
      rsum=gsum=bsum=0;
      yp=-radius*w;
      for (i=-radius; i<=radius; i++) {
        yi=max(0, yp)+x;
        rsum+=r[yi];
        gsum+=g[yi];
        bsum+=b[yi];
        yp+=w;
      }
      yi=x;
      for (y=0; y<h; y++) {
        pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
        if (x==0) {
          vmin[y]=min(y+radius+1, hm)*w;
          vmax[y]=max(y-radius, 0)*w;
        }
        p1=x+vmin[y];
        p2=x+vmax[y];

        rsum+=r[p1]-r[p2];
        gsum+=g[p1]-g[p2];
        bsum+=b[p1]-b[p2];

        yi+=w;
      }
    }
  }
}