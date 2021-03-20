static class ImgFilter {
  static private PApplet context;
  static private String path = "data";
  static private PShader brightness;
  static private PShader level;
  static private PShader denoise;
  static private PShader bilateral;
  static private PShader median3x3;
  static private PShader median5x5;
  static private PShader dilate3x3;
  static private PShader dilate3x3Gaps;
  static private PShader dilate3x3Median;
  static private PShader dilate5x5;
  static private PShader dilate5x5Median;
  static private PShader blur;
  static private PGraphics blurPassH;
  static private PGraphics blurPassV;
  static private PShader gamma;
  static private PShader mask;
  static private PShader grain;
  static private PShader chromaWarp;


  static private void setContext(PApplet context_) {
    context = context_;
    initBrightShader();
    initLevelShader();
    initDenoiseShader();
    initBilateralShader();
    initMedianShader();
    initDilateShader();
    initBlurShader();
    initGammaShader();
    initMaskShader();
    initGrainShader();
    initChromaWarpShader();
  }

  static private void setBlurBuffer(PImage src) {
    if (context != null) {
      if (blurPassH == null || blurPassH.width != src.width || blurPassH.height != src.height
        || blurPassV == null || blurPassV.width != src.width || blurPassV.height != src.height) {
        blurPassV = context.createGraphics(src.width, src.height, P2D);
        blurPassH = context.createGraphics(src.width, src.height, P2D);
      }
    }
  }

  static private void setPath(String path_) {
    path = path_;
  }

  static private void initBrightShader() {
    brightness = context.loadShader(path+"/"+"brightness.glsl");
  }

  static private  void initLevelShader() {
    level = context.loadShader(path+"/"+"level.glsl");
  }

  static private  void initDenoiseShader() {
    denoise = context.loadShader(path+"/"+"denoise.glsl");
  }

  static private  void initBilateralShader() {
    bilateral = context.loadShader(path+"/"+"bilateral.glsl");
  }

  static private  void initMedianShader() {
    median3x3 = context.loadShader(path+"/"+"medianFilter3x3Optimized.glsl");
    median5x5 = context.loadShader(path+"/"+"medianFilter5x5Optimized.glsl");
  }

  static private  void initDilateShader() {
    dilate3x3 = context.loadShader(path+"/"+"dilateFilter3x3.glsl");
    dilate3x3Gaps = context.loadShader(path+"/"+"dilateFilter3x3Gaps.glsl");
    dilate3x3Median = context.loadShader(path+"/"+"dilateFilter3x3Median.glsl");
    dilate5x5 = context.loadShader(path+"/"+"dilateFilter5x5.glsl");
    dilate5x5Median = context.loadShader(path+"/"+"dilateFilter5x5Median.glsl");
  }

  static private  void initBlurShader() {
    blur = context.loadShader(path+"/"+"blurHV.glsl");
  }

  static private  void initGammaShader() {
    gamma = context.loadShader(path+"/"+"gamma.glsl");
  }

  static private  void initMaskShader() {
    mask = context.loadShader(path+"/"+"mask.glsl");
  }
  
   static private  void initGrainShader() {
    grain = context.loadShader(path+"/"+"grain.glsl");
  }
  
   static private  void initChromaWarpShader() {
    chromaWarp = context.loadShader(path+"/"+"chromaWarp.glsl");
  }


  /**
   * IMAGE FILTERS AVAILABLE
   *** Brightness
   *** Level
   */
  static private void getBrightImage(PApplet context_, PImage src, float contrast, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }
    brightness.set("resolution", (float) src.width, (float) src.height);
    brightness.set("contrast", contrast);

    getPostProcessBuffer(src, brightness, buffer);
  }



  static private void getLevelImage(PApplet context_, PImage src, float minInput, float gamma, float maxOutput, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }
    level.set("resolution", (float) src.width, (float) src.height);
    level.set("minInput", minInput);
    level.set("medium", gamma);
    level.set("maxOutput", maxOutput);

    getPostProcessBuffer(src, level, buffer);
  }

  static private void getDenoiseImage(PApplet context_, PImage src, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }
    denoise.set("resolution", (float) src.width, (float) src.height);

    getPostProcessBuffer(src, denoise, buffer);
  }

  static private void getBilateralImage(PApplet context_, PImage src, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    bilateral.set("resolution", (float) src.width, (float) src.height);

    getPostProcessBuffer(src, bilateral, buffer);
  }

  static private void getMedian3x3Image(PApplet context_, PImage src, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    median3x3.set("resolution", (float) src.width, (float) src.height);
    getPostProcessBuffer(src, median3x3, buffer);
  }

  static private void getMedian5x5Image(PApplet context_, PImage src, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    median5x5.set("resolution", (float) src.width, (float) src.height);
    getPostProcessBuffer(src, median5x5, buffer);
  }

  static private void getDilate3x3Image(PApplet context_, PImage src, float ratio, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    dilate3x3.set("resolution", (float) src.width, (float) src.height);
    dilate3x3.set("ratio", (float) ratio);
    getPostProcessBuffer(src, dilate3x3, buffer);
  }

  static private void getDilate3x3Median(PApplet context_, PImage src, float ratio, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    dilate3x3Median.set("resolution", (float) src.width, (float) src.height);
    dilate3x3Median.set("ratio", (float) ratio);

    getPostProcessBuffer(src, dilate3x3Median, buffer);
  }

  static private void getDilate5x5Image(PApplet context_, PImage src, float ratio, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    dilate5x5.set("resolution", (float) src.width, (float) src.height);
    dilate5x5.set("ratio", (float) ratio);
    getPostProcessBuffer(src, dilate5x5, buffer);
  }

  static private void getDilate5x5MedianImage(PApplet context_, PImage src, float ratio, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    dilate5x5Median.set("resolution", (float) src.width, (float) src.height);
    dilate5x5Median.set("ratio", (float) ratio);
    getPostProcessBuffer(src, dilate5x5Median, buffer);
  }


  static private void getDilate3x3GapsImage(PApplet context_, PImage src, float ratio, float radius, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    dilate3x3Gaps.set("resolution", (float) src.width, (float) src.height);
    dilate3x3Gaps.set("ratio", (float) ratio);
    dilate3x3Gaps.set("radius", (float) radius);

    getPostProcessBuffer(src, dilate3x3Gaps, buffer);
  }

  static private void getBlurImage(PApplet context_, PImage src, float amount, float sigma, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }
    setBlurBuffer(src);


    blur.set("blurSize", amount);
    blur.set("sigma", sigma);

    getBlurProcessBuffer(src, blur, buffer);
  }

  static private void getGammaImage(PApplet context_, PImage src, float value, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    gamma.set("resolution", (float) src.width, (float) src.height);
    gamma.set("gamma", value);
    getPostProcessBuffer(src, gamma, buffer);
  }

  static private void getGrainImage(PApplet context_, PImage src, float intensity, float time, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    grain.set("resolution", (float) src.width, (float) src.height);
    grain.set("intensity", intensity);
    grain.set("time", time);
    getPostProcessBuffer(src, grain, buffer);
  }
  
  static private void getChromaWarpImage(PApplet context_, PImage src, float strength, float inc, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    chromaWarp.set("resolution", (float) src.width, (float) src.height);
    chromaWarp.set("strength", strength);
    chromaWarp.set("inc", inc);
    getPostProcessBuffer(src, chromaWarp, buffer);
  }
  
  static private void getChromaWarpImage(PApplet context_, PImage src, float step, float strength, float inc, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    chromaWarp.set("resolution", (float) src.width, (float) src.height);
    chromaWarp.set("step", step);
    chromaWarp.set("strength", strength);
    chromaWarp.set("inc", inc);
    getPostProcessBuffer(src, chromaWarp, buffer);
  }
  
  static private void getChromaWarpImage(PApplet context_, PImage src, float step, float strength, float inc, float distMin, float distMax, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    chromaWarp.set("resolution", (float) src.width, (float) src.height);
    chromaWarp.set("step", step);
    chromaWarp.set("strength", strength);
    chromaWarp.set("inc", inc);
    chromaWarp.set("distMin", distMin);
    chromaWarp.set("distMax", distMax);
    getPostProcessBuffer(src, chromaWarp, buffer);
  }

  static private void getMaskImage(PApplet context_, PImage src, PImage maski, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    mask.set("resolution", (float) src.width, (float) src.height);
    mask.set("mask", maski);
    mask.set("type", 0.0);
    getPostProcessBuffer(src, mask, buffer);
  }

  static private void getMaskImage(PApplet context_, PImage src, PImage maski, PImage maskbg, PGraphics buffer) {  
    if (context == null) {
      setContext(context_);
    }

    mask.set("resolution", (float) src.width, (float) src.height);
    mask.set("mask", maski);
    mask.set("backTexture", maskbg);
    mask.set("type", 1.0);
    getPostProcessBuffer(src, mask, buffer);
  }



  /**
   * Post Process
   */
  static private void getPostProcessBuffer(PImage src, PShader sh, PGraphics buffer) {
    buffer.beginDraw();
    buffer.background(255, 1);
    buffer.shader(sh);
    buffer.image(src, 0, 0, buffer.width, buffer.height);
    buffer.endDraw();
  }

  static private void getBlurProcessBuffer(PImage src, PShader sh, PGraphics buffer) {
    // PGraphics buffer = context.createGraphics(src.width, src.height, P2D);
    sh.set("pass", 0);
    blurPassH.beginDraw();
    blurPassH.shader(sh);
    blurPassH.image(src, 0, 0, blurPassH.width, blurPassH.height);
    blurPassH.endDraw();

    sh.set("pass", 1);
    blurPassV.beginDraw();
    blurPassV.shader(sh);
    blurPassV.image(blurPassH, 0, 0, blurPassV.width, blurPassV.height);
    blurPassV.endDraw();

    buffer.beginDraw();
    buffer.image(blurPassV, 0, 0, buffer.width, buffer.height);
    buffer.endDraw();
  }

  /**
   * DITHERING AVAILABLE
   *** Floyd-Steinberg
   */
  static private PImage getFloydSteinbergDither(PImage src, float factor, boolean gray, float scaleFactor) {
    return  getFloydSteinbergDither(context, src, factor, gray, scaleFactor);
  }

  static private PImage getFloydSteinbergDither(PApplet context_, PImage src, float factor, boolean gray, float scaleFactor) {
    PGraphics buffer = context_.createGraphics(floor(src.width * scaleFactor), floor(src.height * scaleFactor), P2D);
    buffer.beginDraw();
    buffer.image(src, 0, 0, buffer.width, buffer.height);
    buffer.endDraw();

    PImage dither = buffer.copy();
    if (gray) dither.filter(GRAY);

    dither.loadPixels();

    //Floyd-Steinberg 
    for (int y=0; y<dither.height-1; y++) {
      for (int x = 1; x<dither.width-1; x++) 
      {
        int index = getIndexAt(x, y, dither.width);
        color cARGB = dither.pixels[index];
        float[] RGBA = getRGBG(cARGB);

        float closestRed = findClosestChannelPalette(RGBA[0], factor);
        float closestGreen = findClosestChannelPalette(RGBA[1], factor);
        float closestBlue = findClosestChannelPalette(RGBA[2], factor);

        //define closest palette
        dither.pixels[index] = setColor(closestRed, closestGreen, closestBlue, 255);

        //define quantized error
        float errorR = RGBA[0] - closestRed;
        float errorG = RGBA[1] - closestGreen;
        float errorB = RGBA[2] - closestBlue;
        float[] errorRGB = {errorR, errorG, errorB};

        int[] indices = {
          getIndexAt(x+1, y, dither.width), 
          getIndexAt(x-1, y+1, dither.width), 
          getIndexAt(x, y+1, dither.width), 
          getIndexAt(x+1, y+1, dither.width)
        };

        float[] distributions = {7.0, 3.0, 5.0, 1.0};
        float distributionDivider = 16.0;

        for (int i=0; i<4; i++) {
          float[] dithers = ditherAt(dither.pixels, indices[i], errorRGB, distributions[i], distributionDivider);
          dither.pixels[indices[i]] = setColor(dithers[0], dithers[1], dithers[2], 255);
        }
      }
    }

    return dither;
  }


  static private float findClosestChannelPalette(float channel, float factor) {
    return round(factor * channel / 255) * (255 / factor);
  }

  static private float[] ditherAt(int[] pixelsImg, int index, float[] errors, float factor, float divider) {
    color cARGB = pixelsImg[index];
    float[] RGBA = getRGBG(cARGB);
    float[] _RGB = new float[3]; 
    for (int i=0; i<errors.length; i++) {
      _RGB[i] =  RGBA[i] + errors[i] * factor / divider;
    }

    return _RGB;
  } 


  /**
   * FAST BLUR from Mario Klingemann
   */
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

  /**
   * HELPERS
   */

  private static int setColor(float gray) {
    return setColor(gray, gray, gray, 255.0);
  }

  private static int setColor(float r, float g, float b) {
    return setColor(r, g, b, 255.0);
  }

  private static int setColor(float r, float g, float b, float a) {
    if (a > 255) {
      a = 255;
    } else if (a < 0) { 
      a = 0;
    }
    if (r > 255) { 
      r = 255;
    } else if (r < 0) { 
      r = 0;
    }
    if (g > 255) { 
      g = 255;
    } else if (g < 0) { 
      g = 0;
    }
    if (b > 255) { 
      b = 255;
    } else if (b < 0) { 
      b = 0;
    }

    return ((int)a << 24) | ((int)r << 16) | ((int)g << 8) | (int)b;
  }

  static private float[] getRGBG(color c) {
    float a = (c >> 24) & 0xFF;
    float r = (c >> 16) & 0xFF;
    float g = (c >> 8) & 0xFF; 
    float b = c & 0xFF;

    float[] rgba = {r, g, b, a};
    return rgba;
  }

  static private int getIndexAt(int x, int y, int w) {
    return x + y * w;
  }
}
