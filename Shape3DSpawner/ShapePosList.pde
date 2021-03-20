ArrayList<Node> getNodeFrom3DShape(PShape obj, int offset, float scale) {
  ArrayList<Node> tmp = new ArrayList<Node>();
  for (int i=0; i<obj.getChildCount(); i+=offset) {
    PShape child = obj.getChild(i);
    for (int j=0; j<child.getVertexCount(); j+=3) {
      PVector A = child.getVertex(j);
      PVector B = child.getVertex(j+1);
      PVector C = child.getVertex(j+2);
      
      PVector gravity = PVector.add(A, B).add(C).div(3.0).mult(scale);
      tmp.add(new Node(gravity));
    }
  }
  println(tmp.size());
  return tmp;
}
