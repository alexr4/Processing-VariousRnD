float smoothStroke(float x, float limit, float thickness, float smoothness){
    float d = smoothstep(limit - thickness * 0.5 - smoothness, limit - thickness * 0.5, x) - 
              smoothstep(limit + thickness * 0.5, limit + thickness * 0.5 + smoothness, x);
    return clamp(d, 0.0, 1.0);
}

float stroke(float x, float limit, float thickness){
    float d = step(limit, x + thickness * 0.5) - 
              step(limit, x - thickness * 0.5);
    return clamp(d, 0.0, 1.0);
}

float fill(float x, float size){
    return 1.0 - step(size, x);
}

float smoothFill(float x, float size, float smoothness){
    return 1.0 - smoothstep(size - smoothness, size, x);
}