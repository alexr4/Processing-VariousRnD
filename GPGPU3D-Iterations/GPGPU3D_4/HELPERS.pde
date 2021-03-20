float[] getUVAt(int i, int w, int h) {
  int piu = i % w;
  int piv = (i-piu) / w;

  float u = (float)piu / (float)w;
  float v = (float)piv / (float)h;
  
  return new float[]{u, v};
}

float getAbsoluteMax(float minX, float maxX, float minY, float maxY, float minZ, float maxZ){
  float mx = max(abs(minX), maxX);
  float my = max(abs(minY), maxY);
  float mz = max(abs(minZ), maxZ);
  
  float mxy = max(mx, my);
  float mxyz = max(mxy, mz);
  
  return mxyz;
}

void disableMipmapAndSetFiltering(PingPongBuffer buffer, int filtering, boolean mipmap, int texturemode){
  buffer.setFiltering(filtering);
  buffer.enableTextureMipmaps(mipmap);
  //buffer.dst.textureWrap(texturemode);
}
