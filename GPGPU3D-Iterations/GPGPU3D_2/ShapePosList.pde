ArrayList<PVector> getVertListFrom3DShape(PShape obj, int offset, float scale) {
  ArrayList<PVector> tmp = new ArrayList<PVector>();
  for (int i=0; i<obj.getChildCount(); i+=offset) {
    PShape child = obj.getChild(i);
    for (int j=0; j<child.getVertexCount(); j+=3) {
      PVector A = child.getVertex(j).mult(scale);
      PVector B = child.getVertex(j+1).mult(scale);
      PVector C = child.getVertex(j+2).mult(scale);

      PVector gravity = PVector.add(A, B).add(C).div(3.0);
      //tmp.add(gravity);
      tmp.add(A);
      tmp.add(B);
      tmp.add(C);
    }
  }
  return tmp;
}
