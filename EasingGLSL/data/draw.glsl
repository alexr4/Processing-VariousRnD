float plot(float value, float axis){
  return  axis - value;
}

float circle(vec2 st, vec2 center){
  return distance(center, st);
}

float rect(in vec2 st, vec2 size){
  st = st * 2.0 - 1.0;
  return max(abs(st.x/size.x), abs(st.y/size.y));
}