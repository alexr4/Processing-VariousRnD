public static final float[] afactor = {1.0, 255.0, 65025.0, 16581375.0};
public static final float[] adfactor = {1.0, 1/255.0, 1/65025.0, 1/16581375.0};
public static final float[] aMask = {1.0/255.0, 1.0/255.0, 1.0/255.0, 0.0};


int afloatToARGB32(float value){
  float[] rgba = {
    afactor[0] * value,
    afactor[1] * value,
    afactor[2] * value,
    afactor[3] * value,
  };
  
  //get only fractionnal parts
  rgba[0] = fract(rgba[0]);
  rgba[1] = fract(rgba[1]);
  rgba[2] = fract(rgba[2]);
  rgba[3] = fract(rgba[3]);
  
  //substract compen encoded value from the previous comp
  rgba[0] -= rgba[1] * aMask[0]; 
  rgba[1] -= rgba[2] * aMask[1];
  rgba[2] -= rgba[3] * aMask[2];
  rgba[3] -= rgba[3] * aMask[3];
  
  //remap between 0 and 255
  rgba[0] *= 255.0;
  rgba[1] *= 255.0;
  rgba[2] *= 255.0;
  rgba[3] *= 255.0;
  
  //clamp rgba
  if (rgba[3] > 255) rgba[3] = 255; else if (rgba[3] < 0) rgba[3] = 0;
  if (rgba[0] > 255) rgba[0] = 255; else if (rgba[0] < 0) rgba[0] = 0;
  if (rgba[1] > 255) rgba[1] = 255; else if (rgba[1] < 0) rgba[1] = 0;
  if (rgba[2] > 255) rgba[2] = 255; else if (rgba[2] < 0) rgba[2] = 0;
  
  return (int)rgba[3] << 24 | (int)rgba[0] << 16 | (int)rgba[1] << 8 |(int)rgba[2];
}

float aARGB32Tofloat(int argb) {
  float[] rgbaArray = getRGBA(argb);
  
  return dot(rgbaArray, adfactor);
}
