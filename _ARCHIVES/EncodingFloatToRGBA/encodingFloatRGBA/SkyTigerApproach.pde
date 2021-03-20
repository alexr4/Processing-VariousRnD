
// ref :: https://skytiger.wordpress.com/2010/12/01/packing-depth-into-color/
public final static float[] skefactor = {1, 255, 65025, 16581375};
public final static float[] skscale = {1.0, 256.0, 65536.0};
public final static float[] skdfactor = {1.0/1.0, 1.0/255, 1.0/65025.0, 1.0/16581375.0};
public final static float[] ogb = {65536.0 / 16777215.0, 256.0/16777215.0};
public final static float skmask = 1.0/256.0; 
public final static float sknormal = 256.0/255.0;

//----------IMPL1
int skfloatToARGB32(float value) {
  float[] rgba = {
    skefactor[0] * value,
    skefactor[1] * value,
    skefactor[2] * value,
    skefactor[3] * value,
  };
  
  rgba[1] = fract(rgba[1]);
  rgba[2] = fract(rgba[2]);
  rgba[3] = fract(rgba[3]);
  
  rgba[0] -= rgba[1] * skmask;
  rgba[1] -= rgba[2] * skmask;
  rgba[2] -= rgba[3] * skmask;
  //rgba[3] = 1.0; //avoid 0 as alpha
  
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

float skARGB32Tofloat(int argb) {
  float[] argbArray = getRGBA(argb);
  
  return dot(argbArray, skdfactor);
}

//------------------IMPL1
int skfloatToARGB24(float value){
  float[] rgb = {
    skefactor[0] * value,
    skefactor[1] * value,
    skefactor[2] * value
  };
  
  rgb[1] = fract(rgb[1]);
  rgb[2] = fract(rgb[2]);
  
  rgb[0] -= rgb[1] * skmask;
  rgb[1] -= rgb[2] * skmask;
  
  //remap between 0 and 255
  rgb[0] *= 255.0;
  rgb[1] *= 255.0;
  rgb[2] *= 255.0;
  
  //clamp rgba
  if (rgb[0] > 255) rgb[0] = 255; else if (rgb[0] < 0) rgb[0] = 0;
  if (rgb[1] > 255) rgb[1] = 255; else if (rgb[1] < 0) rgb[1] = 0;
  if (rgb[2] > 255) rgb[2] = 255; else if (rgb[2] < 0) rgb[2] = 0;
  
  return (int)255 << 24 | (int)rgb[0] << 16 | (int)rgb[1] << 8 |(int)rgb[2];
}

float skARGB24Tofloat(int argb) {
  float[] skdfactorRGB = {skdfactor[0], skdfactor[1], skdfactor[2]};
  float[] argbArray = getRGBA(argb);
  
  return dot(argbArray, skdfactorRGB);
}


//----------------------------IMPL2
int sk2floatToARGB24(float value){
  //avoid precision error
  float[] units = {value, value, value};
  units[1] -= Math.floor(units[1] / ogb[0]) *  ogb[0];
  units[2] -= Math.floor(units[2] / ogb[1]) *  ogb[1];
  
  //scale up
  float[] rgb = {
    skscale[0] * units[0],
    skscale[1] * units[1],
    skscale[2] * units[2]
  };
  
  //frac and normalize
  rgb[0] = fract(rgb[0]) * sknormal;
  rgb[1] = fract(rgb[1]) * sknormal;;
  rgb[2] = fract(rgb[2]) * sknormal;;
  
  rgb[0] -= rgb[1] / 256.0;
  rgb[1] -= rgb[2] / 256.0;
  
  //remap between 0 and 255
  rgb[0] *= 255.0;
  rgb[1] *= 255.0;
  rgb[2] *= 255.0;
  
  //clamp rgba
  if (rgb[0] > 255) rgb[0] = 255; else if (rgb[0] < 0) rgb[0] = 0;
  if (rgb[1] > 255) rgb[1] = 255; else if (rgb[1] < 0) rgb[1] = 0;
  if (rgb[2] > 255) rgb[2] = 255; else if (rgb[2] < 0) rgb[2] = 0;
  
  return (int)255 << 24 | (int)rgb[0] << 16 | (int)rgb[1] << 8 |(int)rgb[2];
}

float sk2ARGB24Tofloat(int argb) {
  float[] skdfactorRGB = {65536.0/65793.0, 256.0/65793.0, 1.0/65793.0};
  float[] argbArray = getRGBA(argb);
  
  return dot(argbArray, skdfactorRGB);
}

//----------IMPL1
int skfloatToARGB16(float value) {
  float[] rgba = {
    skefactor[0] * value,
    skefactor[1] * value,
    //skefactor[2] * value,
    //skefactor[3] * value,
  };
  
  rgba[1] = fract(rgba[1]);
  //rgba[2] = fract(rgba[2]);
  //rgba[3] = fract(rgba[3]);
  
  rgba[0] -= rgba[1] * skmask;
  //rgba[1] -= rgba[2] * skmask;
  //rgba[2] -= rgba[3] * skmask;
  //rgba[3] = 1.0; //avoid 0 as alpha
  
  //remap between 0 and 255
  rgba[0] *= 255.0;
  rgba[1] *= 255.0;
  //rgba[2] *= 255.0;
  //rgba[3] *= 255.0;
  
  //clamp rgba
  if (rgba[0] > 255) rgba[0] = 255; else if (rgba[0] < 0) rgba[0] = 0;
  if (rgba[1] > 255) rgba[1] = 255; else if (rgba[1] < 0) rgba[1] = 0;
  
  return 255 << 24 | (int)rgba[0] << 16 | (int)rgba[1] << 8 |255;
}

float skARGB16Tofloat(int argb) {
  float[] argbArray = getRGBA(argb);
  
  return dot(argbArray, skdfactor);
}
