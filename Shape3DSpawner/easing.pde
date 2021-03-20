//easing model
//easing model
static class Maths
{
  //MathsConstant  
  public static final int LINEAR = 0;
  public static final int INQUAD = 1;
  public static final int OUTQUAD = 2;
  public static final int INOUTQUAD = 3;
  public static final int INCUBIC = 4;
  public static final int OUTCUBIC = 5;
  public static final int INOUTCUBIC= 6;
  public static final int INQUARTIC = 7;
  public static final int OUTQUARTIC = 8;
  public static final int INOUTQUARTIC= 9;
  public static final int INQUINTIC = 10;
  public static final int OUTQUINTIC = 11;
  public static final int INOUTQUINTIC= 12;
  public static final int INSIN = 13;
  public static final int OUTSIN = 14;
  public static final int INOUTSIN= 15;
  public static final int INEXP = 16;
  public static final int OUTEXP = 17;
  public static final int INOUTEXP= 18;
  public static final int INCIRC = 19;
  public static final int OUTCIRC = 20;
  public static final int INOUTCIRC= 21;
}

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
    return norm(inc*time/duration + start, 0.0, 1.0);
  }

  // Quadratic
  static float inQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return norm(inc * time * time + start, 0.0, 1.0);
  }

  static float outQuad(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    float inc = end - start;
    return norm(-inc * time * (time - 2) + start, 0.0, 1.0);
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
      return norm(inc/2 * time * time + start, 0.0, 1.0);
    } else
    {
      time--;
      return norm(-inc/2 * (time * (time - 2) - 1) + start, 0.0, 1.0);
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
    return norm(inc * pow(time, 3) + start, 0.0, 1.0);
  }

  static float outCubic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return norm(inc * (pow(time, 3) + 1) + start, 0.0, 1.0);
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
      return norm(inc/2 * pow(time, 3) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return norm(inc/2 * (pow(time, 3) + 2) + start, 0.0, 1.0);
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
    return norm(inc * pow(time, 4) + start, 0.0, 1.0);
  }

  static float outQuartic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return norm(-inc * (pow(time, 4) - 1) + start, 0.0, 1.0);
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
      return norm(inc/2 * pow(time, 4) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return norm(-inc/2 * (pow(time, 4) - 2) + start, 0.0, 1.0);
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
    return norm(inc * pow(time, 5) + start, 0.0, 1.0);
  }

  static float outQuintic(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return norm(inc * (pow(time, 5) + 1) + start, 0.0, 1.0);
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
      return norm(inc/2 * pow(time, 5) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return norm(inc/2 * (pow(time, 5) + 2) + start, 0.0, 1.0);
    }
  }

  //Sinusoïdal
  static float inSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return norm(-inc * cos(time/duration * HALF_PI) + inc + start, 0.0, 1.0);
  }

  static float outSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return norm(inc * sin(time/duration * HALF_PI) + start, 0.0, 1.0);
  }

  static float inoutSin(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    float inc = end - start;
    return norm(-inc/2 * (cos(PI * time/duration) - 1) + start, 0.0, 1.0);
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
      return norm(inc * pow(2, 10 * (time/duration-1)) + start, 0.0, 1.0);
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
      return norm(inc * (-pow(2, -10 * (time/duration)) + 1) + start, 0.0, 1.0);
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
      return norm(inc/2 * pow(2, 10 * (time-1)) + start, 0.0, 1.0);
    } else
    {
      time --;
      return norm(inc/2 * (-pow(2, -10 * time) + 2) + start, 0.0, 1.0);
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
    return norm(-inc * (sqrt(1 - time * time) - 1) + start, 0.0, 1.0);
  }

  static float outCirc(float time)
  { 
    float start = 0.0;
    float end = 1.0;
    float duration = 1.0;
    time /= duration;
    time --;
    float inc = end - start;
    return norm(inc * sqrt(1 - time * time) + start, 0.0, 1.0);
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
      return norm(-inc/2 * (sqrt(1 - time * time) - 1) + start, 0.0, 1.0);
    } else
    {
      time -= 2;
      return norm(inc/2 * (sqrt(1 - time * time) + 1) + start, 0.0, 1.0);
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
