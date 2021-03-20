
//used only as debug
float[] loadObjAsArray(PShape obj, float scale) {
  ArrayList<Float> l = new ArrayList<Float>();

  for (int i = 0; i<obj.getChildCount(); i++) {
    PShape child = obj.getChild(i);
    for (int j=0; j<child.getVertexCount(); j++) {
      PVector v = child.getVertex(j);
      v.mult(scale);
      v.sub(new PVector(0.0, -scale*0.5, -scale*0.5));

      float x = norm(v.x, -250.0, 250.0);
      float y = 1.0 - norm(v.y, -250.0, 250.0);
      float z = norm(v.z, -250.0, 250.0);
      
      l.add(x);
      l.add(y);
      l.add(z);
    }
  }
  Float[] posInterleavedPosData0 = new Float[l.size()];
  posInterleavedPosData0 = l.toArray(posInterleavedPosData0);


  float[] posInterleavedPosData = new float[posInterleavedPosData0.length];
  int i = 0;
  for (Float f : posInterleavedPosData0) {
    posInterleavedPosData[i] = (float) f;
    i++;
  }
  return posInterleavedPosData;
}
