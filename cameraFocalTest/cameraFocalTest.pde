import fpstracker.core.*;

PerfTracker pt;
PGraphics buffer;
PGraphics debug;

void settings() {
  size(2000, 500, P3D);
}

void setup() {
  pt = new PerfTracker(this, 120);
  buffer = createGraphics(width/2, height, P3D);
  debug = createGraphics(width/2, height, P3D);
}

void draw() {
  //set processing variables for perspective
  float dfov         = 14 + norm(mouseX, 0, width) * (140 - 14);
  float fov          = radians(dfov);//PI/3.0;
  float cameraZ      = (buffer.height/2.0) / tan(fov/2.0);
  float near         = cameraZ / 10.0;
  float far          = cameraZ * 10.0;
  float aspectRatio  = (float)buffer.width/(float)buffer.height;
  println(near, far);

  //compute focalLength for sending to raymarcher
  /*based on :
   - https://photo.stackexchange.com/questions/97213/finding-focal-length-from-image-size-and-fov
   - http://paulbourke.net/miscellaneous/lens/
   */
  float A = buffer.height/2;
  float a = fov/2;
  float focalLength = (A / tan(a));

  //recompute fovy to check if the FL computation is good;
  float fovy = 2 * atan(.5 * buffer.height / focalLength);
  float fovx = 2 * atan(.5 * buffer.width / focalLength);
  String text = "Original P5 fovy = " + fov + "\n" +
    "FOV x = "+ fovx + "\n" + 
    "Focal Length = " + focalLength + "\n"+
    "Recompute fovy = " + fovy + "\n"+
    "Diff betwen fovs = "+(fov-fovy);



  //frustum computation : https://gamedev.stackexchange.com/questions/19774/determine-corners-of-a-specific-plane-in-the-frustum
  /*
  Near Top Left = Cnear + (up * (Hnear / 2)) - (w * (Wnear / 2))
   Near Top Right = Cnear + (up * (Hnear / 2)) + (w * (Wnear / 2)) 
   Near Bottom Left = Cnear - (up * (Hnear / 2)) - (w * (Wnear /2))
   Near Bottom Right = Cnear + (up * (Hnear / 2)) + (w * (Wnear / 2))
   Far Top Left = Cfar + (up * (Hfar / 2)) - (w * Wfar / 2))
   Far Top Right = Cfar + (up * (Hfar / 2)) + (w * Wfar / 2))
   Far Bottom Left = Cfar - (up * (Hfar / 2)) - (w * Wfar / 2))
   Far Bottom Right = Cfar - (up * (Hfar / 2)) + (w * Wfar / 2))
   */
  float gizmoLen = 100;
  PVector rayOrigin = new PVector();
  PVector target = new PVector(0, 0, far);

  PVector ww = PVector.sub(target, rayOrigin).normalize();
  PVector uu = ww.cross(new PVector(0, 1, 0)).normalize();
  PVector vv = uu.cross(ww).normalize();

  PVector gww = ww.copy().mult(gizmoLen);
  PVector guu = uu.copy().mult(gizmoLen);
  PVector gvv = vv.copy().mult(gizmoLen);

  float nearHeight   = 2 * tan(fov * .5) * near;
  float nearWidth    = nearHeight * aspectRatio;

  float farHeight    = 2 * tan(fov * .5) * far;
  float farWidth     = farHeight * aspectRatio;

  PVector nearCenter = PVector.add(rayOrigin, ww.copy().mult(near));
  PVector farCenter  = PVector.add(rayOrigin, ww.copy().mult(far));

  PVector nearTopLeft = nearCenter.copy().add(vv.copy().mult(nearHeight * .5)).sub(uu.copy().mult(nearWidth * .5));
  PVector nearTopRight = nearCenter.copy().add(vv.copy().mult(nearHeight * .5)).add(uu.copy().mult(nearWidth * .5));
  PVector nearBottomLeft = nearCenter.copy().sub(vv.copy().mult(nearHeight * .5)).sub(uu.copy().mult(nearWidth * .5));
  PVector nearBottomRight = nearCenter.copy().sub(vv.copy().mult(nearHeight * .5)).add(uu.copy().mult(nearWidth * .5));

  PVector farTopLeft = farCenter.copy().add(vv.copy().mult(farHeight * .5)).sub(uu.copy().mult(farWidth * .5));
  PVector farTopRight = farCenter.copy().add(vv.copy().mult(farHeight * .5)).add(uu.copy().mult(farWidth * .5));
  PVector farBottomLeft = farCenter.copy().sub(vv.copy().mult(farHeight * .5)).sub(uu.copy().mult(farWidth * .5));
  PVector farBottomRight = farCenter.copy().sub(vv.copy().mult(farHeight * .5)).add(uu.copy().mult(farWidth * .5));

  //custom plane dist
  float maxTime = 4.0;
  float timeSec = millis() / 1000.0;
  float modTime = (timeSec % maxTime);
  float normTime = modTime / maxTime;
  float dist = normTime * (far - near) + near;

  PVector[] customPlaneCorners = getPlaneCorners(rayOrigin, ww, uu, vv, dist, aspectRatio, fov);
  int colsrows = 10;
  float boxSize = 75;
  float twh = (boxSize * colsrows) * .5;
  float boxZ = -500;
  
  debug.beginDraw();
  debug.background(0);
  debug.camera(0, 0, 1000, 0, 0, 0, 0, 1, 0); 
  debug.rotateY(frameCount * 0.01);
  //gizmo
  debug.stroke(255, 0, 0);
  debug.line(0, 0, 0, guu.x, guu.y, guu.z);
  debug.stroke(0, 255, 0);
  debug.line(0, 0, 0, gvv.x, gvv.y, gvv.z);
  debug.stroke(0, 0, 255);
  debug.line(0, 0, 0, gww.x, gww.y, gww.z); 

  //frustum
  debug.stroke(255, 255, 0);
  debug.line(rayOrigin.x, rayOrigin.y, rayOrigin.z, target.x, target.y, target.z); 
  debug.line(rayOrigin.x, rayOrigin.y, rayOrigin.z, farTopLeft.x, farTopLeft.y, farTopLeft.z); 
  debug.line(rayOrigin.x, rayOrigin.y, rayOrigin.z, farTopRight.x, farTopRight.y, farTopRight.z); 
  debug.line(rayOrigin.x, rayOrigin.y, rayOrigin.z, farBottomRight.x, farBottomRight.y, farBottomRight.z); 
  debug.line(rayOrigin.x, rayOrigin.y, rayOrigin.z, farBottomLeft.x, farBottomLeft.y, farBottomLeft.z); 

  //near
  debug.noFill();
  debug.beginShape();
  debug.vertex(nearTopLeft.x, nearTopLeft.y, nearTopLeft.z);
  debug.vertex(nearTopRight.x, nearTopRight.y, nearTopRight.z);
  debug.vertex(nearBottomRight.x, nearBottomRight.y, nearBottomRight.z);
  debug.vertex(nearBottomLeft.x, nearBottomLeft.y, nearBottomLeft.z);
  debug.endShape(CLOSE);
  
  //far
  debug.beginShape();
  debug.vertex(farTopLeft.x, farTopLeft.y, farTopLeft.z);
  debug.vertex(farTopRight.x, farTopRight.y, farTopRight.z);
  debug.vertex(farBottomRight.x, farBottomRight.y, farBottomRight.z);
  debug.vertex(farBottomLeft.x, farBottomLeft.y, farBottomLeft.z);
  debug.endShape(CLOSE);

  debug.stroke(255, 0, 0);
  debug.fill(255, 0, 0, 100);
  debug.beginShape();
  debug.vertex(customPlaneCorners[0].x, customPlaneCorners[0].y, customPlaneCorners[0].z);
  debug.vertex(customPlaneCorners[1].x, customPlaneCorners[1].y, customPlaneCorners[1].z);
  debug.vertex(customPlaneCorners[3].x, customPlaneCorners[3].y, customPlaneCorners[3].z);
  debug.vertex(customPlaneCorners[2].x, customPlaneCorners[2].y, customPlaneCorners[2].z);
  debug.endShape(CLOSE);
  
  debug.fill(255);
  debug.stroke(0);
  for (int i=0; i<colsrows; i++) {
    for (int j=0; j<colsrows; j++) {
      float x = map(i, 0, colsrows, -twh, twh);
      float y = map(j, 0, colsrows, -twh, twh);
      debug.pushMatrix();
      debug.translate(x, y, -boxZ);
      debug.rotateX(-PI/6 + frameCount * 0.01   + i * .25);
      debug.rotateY( PI/3 + frameCount * 0.0125 + j * .25);
      debug.box(boxSize*.5);
      debug.popMatrix();
    }
  }

  debug.endDraw();

  buffer.beginDraw();
  buffer.background(20);
  buffer.pushMatrix();
  buffer.camera(0, 0, 0, 0, 0, boxZ, 0, 1, 0); 
  buffer.perspective(fov, aspectRatio, near, far);
  buffer.lights();

  buffer.fill(255);
  buffer.stroke(0);
  for (int i=0; i<colsrows; i++) {
    for (int j=0; j<colsrows; j++) {
      float x = map(i, 0, colsrows, -twh, twh);
      float y = map(j, 0, colsrows, -twh, twh);
      buffer.pushMatrix();
      buffer.translate(x, y, boxZ);
      buffer.rotateX(-PI/6 + frameCount * 0.01   + i * .25);
      buffer.rotateY( PI/3 + frameCount * 0.0125 + j * .25);
      buffer.box(boxSize * .5);
      buffer.popMatrix();
    }
  }
  buffer.popMatrix();
  buffer.endDraw();

  image(buffer, 0, 0);
  image(debug, buffer.width, 0);

  fill(0, 100);
  noStroke();
  rect(0, 0, width, 80);
  fill(255);
  noStroke();
  text(text, 140, 20);

  pt.display(10, 10);
}

PVector[] getPlaneCorners(PVector origin, PVector ww, PVector uu, PVector vv, float dist, float aspectRatio, float fov) {

  float pHeight   = 2 * tan(fov * .5) * dist;
  float pWidth    = pHeight * aspectRatio;

  PVector nearCenter = PVector.add(origin, ww.copy().mult(dist));

  PVector nearTopLeft = nearCenter.copy().add(vv.copy().mult(pHeight * .5)).sub(uu.copy().mult(pWidth * .5));
  PVector nearTopRight = nearCenter.copy().add(vv.copy().mult(pHeight * .5)).add(uu.copy().mult(pWidth * .5));
  PVector nearBottomLeft = nearCenter.copy().sub(vv.copy().mult(pHeight * .5)).sub(uu.copy().mult(pWidth * .5));
  PVector nearBottomRight = nearCenter.copy().sub(vv.copy().mult(pHeight * .5)).add(uu.copy().mult(pWidth * .5));

  return new PVector[]{nearTopLeft, nearTopRight, nearBottomLeft, nearBottomRight};
}
