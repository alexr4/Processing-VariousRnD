import fpstracker.core.*;
import gpuimage.core.*;

PerfTracker pt;
PShader raymarcher, dof, FXAA;
PGraphics buffer;
Filter filter;
static final int AA = 4;
PImage albedo, normal, specular, displacement;

boolean pause;
boolean livecoding;

void setup() {
  size(800, 800, P2D);
  pt = new PerfTracker(this, 120);

  buffer = createGraphics(width, height, P2D);
  filter = new Filter(this, buffer.width, buffer.height);
  raymarcher = loadShader("raymarcher.glsl");
  dof = loadShader("hexagonalDOF.glsl");
  FXAA = loadShader("fxaa.glsl");

  generateCubeMap("_environment/Studio");


  albedo = loadImage("BlueMarble/albedo.jpg");
  normal = loadImage("BlueMarble/normal.png");
  specular = loadImage("BlueMarble/specular.png");
  displacement = loadImage("BlueMarble/displacement.png");
  raymarcher.set("envd", 5);
  raymarcher.set("albedoMap", albedo);
  raymarcher.set("normalMap", normal);
  raymarcher.set("specularMap", specular);
  raymarcher.set("displacementMap", displacement);
}

void draw() {
  Time.update(this, pause);

  compute(livecoding);

  image(filter.getBuffer(), 0, 0);
  pt.display(0, 0);

  surface.setTitle("time: "+Time.time+" livecoding: "+livecoding);
}

void compute(boolean livecoding) {
  try {
    if (livecoding) {
      raymarcher = loadShader("raymarcher.glsl");
      raymarcher.set("envd", 5);
      raymarcher.set("resolution", (float)buffer.width, (float)buffer.height);
      raymarcher.set("albedoMap", albedo);
      raymarcher.set("normalMap", normal);
      raymarcher.set("specularMap", specular);
      raymarcher.set("displacementMap", displacement);
    }

    raymarcher.set("mouse", (float)mouseX/width, (float)mouseY/height);
    raymarcher.set("mipLevel", ((float)mouseX/width) * 7.0);
    raymarcher.set("time", Time.time * 0.001);

    buffer.beginDraw();
    buffer.clear();
    buffer.blendMode(REPLACE);
    buffer.shader(raymarcher);
    buffer.rect(0, 0, buffer.width, buffer.height);
    buffer.endDraw();

    dof.set("resolution", (float)buffer.width, (float)buffer.height);
    dof.set("mouse", (float)mouseX/(float)width, (float)mouseY/(float)height);

    filter.getCustomFilter(buffer, dof);
    for (int i=0; i<AA; i++) {
      filter.getCustomFilter(filter.getBuffer(), FXAA);
    }
  }
  catch(Exception e) {
    e.printStackTrace();
  }
}

void keyPressed() {
  switch(key) {
  case 'p' :
  case 'P' :
    pause = !pause;
    break;
  case 'l' :
  case 'L' :
    livecoding = !livecoding;
    break;
  case 'r' :
  case 'R' :
    Time.resetTime(this);
    break;
  }
}
