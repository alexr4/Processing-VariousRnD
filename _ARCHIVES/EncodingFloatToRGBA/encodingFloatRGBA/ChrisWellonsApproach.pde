public static final float cwBase = 1.0/255.0;
public static final float cwBase255 = cwBase * 255.0;
public static final float cwOffset = cwBase * cwBase / 2.0;

int cwfloatToARGB32(float value) {
  float unit = value + cwOffset;
  float R = unit % cwBase;
  float G = floor(value / cwBase);

  return ((int)255 << 24) | ((int)R << 16) | ((int)G << 8) | (int)255;
}

float cwARGB16Tofloat(int argb) {
  float[] rgba = getRGBA(argb);
  
  float[] BASEVec = {cwBase255, cwBase255 * cwBase255};
  float[] channel = {rgba[0], rgba[1]};
  float decode = dot(channel, BASEVec);
  decode -= cwOffset;
  
  return decode;
}
