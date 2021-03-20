public static final double cwBase = 1.0/255.0;
public static final double cwBase255 = cwBase * 255.0;
public static final double cwOffset = cwBase * cwBase / 2.0;

int cwfloatToARGB16(double value) {
  double unit = value + cwOffset;
  double R = unit % cwBase;
  double G = Math.floor(value / cwBase);

  return ((int)255 << 24) | ((int)R << 16) | ((int)G << 8) | (int)255;
}

double cwARGBToFloat(int argb) {
  double[] rgba = getRGBA(argb);
  
  double[] BASEVec = {cwBase255, cwBase255 * cwBase255};
  double[] channel = {rgba[0], rgba[1]};
  double decode = dot(channel, BASEVec);
  decode -= cwOffset;
  
  return decode;
}
