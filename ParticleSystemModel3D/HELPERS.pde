float signedDistanceFromBox(PVector p, PVector s) {
  PVector d = new PVector(abs(p.x), abs(p.y), abs(p.z)).sub(s);
  PVector max = new PVector(max(d.x, 0), max(d.y, 0), max(d.z, 0));
  float maxYZ = max(d.y, d.z);
  float maxXMaxYZ = max(d.x, maxYZ);
  float minMaxXMaxYZ = min(maxXMaxYZ, 0.0f);
  //   max = max + new Vector3(minMaxXMaxYZ, minMaxXMaxYZ, minMaxXMaxYZ);
  return max.mag(); //remove this line for an only partially signed sdf
}

float smoothstep(float edge0, float edge1, float x) {
  float t = constrain((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  return t * t * (3.0 - 2.0 * t);
}
