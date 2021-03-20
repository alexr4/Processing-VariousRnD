/*Per-Pixel shading example : This skecth show the default shader from processing
 set as a Per-Pixel shading. All the processing methods for lights and materials are supported (lights(), ambientLights()...)
 
 Copyright BonjourLab & Processing
 */
import peasy.*;

PShader shader;
PGraphics buffer;
PImage texture;
PImage temp;
boolean perPixel = true;
boolean textureMode = true;

PeasyCam cam;

//shadow
PGraphics shadowMap;
PVector lightDir = new PVector();
PGraphics shadowbuffer;
PShader bit16Unpacker;

void setup() {
  size(720, 720, P3D);
  cam = new PeasyCam(this, 0, 0, 0, 500);

  texture = loadImage("test.png");
  shader = loadShader("P5_DefaultFrag.glsl", "P5_DefaultVert.glsl");
  buffer = createGraphics(width, height, P3D);
  buffer.smooth(8);

  initShadowPass();
  bit16Unpacker = loadShader("unpack16BitsMap_frag.glsl");
  shadowbuffer = createGraphics(shadowMap.width, shadowMap.height, P2D);

  initShape(30, 30, 150);
}

void draw() {
  CameraState state = cam.getState();
  state.apply(buffer);

  // Calculate the light direction (actually scaled by negative distance)
  float lightAngle = frameCount * 0.002;
  float depth = 750;
  lightDir.set(sin(lightAngle) * depth, depth, cos(lightAngle) * depth);

  // Render shadow pass
  shadowMap.beginDraw();
  shadowMap.resetShader();
  shadowMap.camera(lightDir.x, lightDir.y, lightDir.z, 0, 0, 0, 0, 1, 0);
  shadowMap.background(0xffffffff); // Will set the depth to 1.0 (maximum depth)
  render(shadowMap, false);
  shadowMap.endDraw();

  updateDefaultShader(shader);

  state.apply(buffer);
  render(buffer, true);

  shadowbuffer.beginDraw();
  shadowbuffer.shader(bit16Unpacker);
  shadowbuffer.image(shadowMap, 0, 0);
  shadowbuffer.endDraw();

  cam.beginHUD();
  image(buffer, 0, 0);
  image(shadowbuffer, 0, 0, shadowbuffer.width * 0.1, shadowbuffer.height * 0.1);
  fill(255);
  text("Per-Pixel shading", 20, 20);
  cam.endHUD();

  surface.setTitle("FPS : "+round(frameRate));
}

void render(PGraphics b, boolean light) {
  b.beginDraw();
  b.background(0);
  if (light)
  {
    
    //b.lights();
    b.lightFalloff(0.5, 0.001, 0.0);
    b.ambientLight(255/2, 0, 0, 0, 0, 0);
    b.pointLight(0, 255, 0, 0, height/2, 500);
    b.lightSpecular(255, 255, 0);
    b.directionalLight(0, 0, 255, lightDir.x * -1, lightDir.y * -1, lightDir.z * -1);
    b.lightSpecular(0, 255, 255);

    if (perPixel) {
      b.shader(shader);
    } else {
      b.resetShader();
    }
  } else {
    b.noLights();
  }

  b.ambient(255, 0, 0);
  b.emissive(0, 5, 0);
  b.specular(255, 255, 255);
  b.shininess(100.0);

  b.noStroke();

  b.fill(240);
  b.pushMatrix();
  b.translate(0, 0, -250);
  b.box(750, 750, 40);
  b.popMatrix();

  b.fill(200);
  int nbElement = 10;
  for(int i=0; i<nbElement; i++){
    float theta = (float)i / (float)nbElement;
    float x = cos(theta * TWO_PI) * 250;
    float y = sin(theta * TWO_PI) * 250;
    b.pushMatrix();
    b.translate(x, y);
    b.rotateX(frameCount * 0.01);
    b.rotateY(frameCount * 0.01);
    b.box(50);
    b.popMatrix();
  }
  
  b.stroke(400, 20);
  sphere(b);

  b.endDraw();
}

public void initShadowPass() {
  shadowMap = createGraphics(2048, 2048, P3D);
  String[] vertSource = {
    "uniform mat4 transform;", 

    "attribute vec4 vertex;", 

    "void main() {", 
    "gl_Position = transform * vertex;", 
    "}"
  };
  String[] fragSource = {

    // In the default shader we won't be able to access the shadowMap's depth anymore,
    // just the color, so this function will pack the 16bit depth float into the first
    // two 8bit channels of the rgba vector.
    "vec4 packDepth(float depth) {", 
    "float depthFrac = fract(depth * 255.0);", 
    "return vec4(depth - depthFrac / 255.0, depthFrac, 1.0, 1.0);", 
    "}", 

    "void main(void) {", 
    "gl_FragColor = packDepth(gl_FragCoord.z);", 
    "}"
  };
  shadowMap.noSmooth(); // Antialiasing on the shadowMap leads to weird artifacts
  //shadowMap.loadPixels(); // Will interfere with noSmooth() (probably a bug in Processing)
  shadowMap.beginDraw();
  shadowMap.noStroke();
  shadowMap.shader(new PShader(this, vertSource, fragSource));
  //shadowMap.ortho(-1240, 1240, -1240, 1240, 0, 1500); // Setup orthogonal view matrix for the directional light
  shadowMap.endDraw();
}

void updateDefaultShader(PShader sh) {

  // Bias matrix to move homogeneous shadowCoords into the UV texture space
  PMatrix3D shadowTransform = new PMatrix3D(
    0.5, 0.0, 0.0, 0.5, 
    0.0, 0.5, 0.0, 0.5, 
    0.0, 0.0, 0.5, 0.5, 
    0.0, 0.0, 0.0, 1.0
    );

  // Apply project modelview matrix from the shadow pass (light direction)
  shadowTransform.apply(((PGraphicsOpenGL)shadowMap).projmodelview);

  // Apply the inverted modelview matrix from the default pass to get the original vertex
  // positions inside the shader. This is needed because Processing is pre-multiplying
  // the vertices by the modelview matrix (for better performance).
  PMatrix3D modelviewInv = ((PGraphicsOpenGL)g).modelviewInv;
  shadowTransform.apply(modelviewInv);

  // Convert column-minor PMatrix to column-major GLMatrix and send it to the shader.
  // PShader.set(String, PMatrix3D) doesn't convert the matrix for some reason.
  sh.set("shadowTransform", new PMatrix3D(
    shadowTransform.m00, shadowTransform.m10, shadowTransform.m20, shadowTransform.m30, 
    shadowTransform.m01, shadowTransform.m11, shadowTransform.m21, shadowTransform.m31, 
    shadowTransform.m02, shadowTransform.m12, shadowTransform.m22, shadowTransform.m32, 
    shadowTransform.m03, shadowTransform.m13, shadowTransform.m23, shadowTransform.m33
    ));

  // Calculate light direction normal, which is the transpose of the inverse of the
  // modelview matrix and send it to the default shader.
  float lightNormalX = lightDir.x * modelviewInv.m00 + lightDir.y * modelviewInv.m10 + lightDir.z * modelviewInv.m20;
  float lightNormalY = lightDir.x * modelviewInv.m01 + lightDir.y * modelviewInv.m11 + lightDir.z * modelviewInv.m21;
  float lightNormalZ = lightDir.x * modelviewInv.m02 + lightDir.y * modelviewInv.m12 + lightDir.z * modelviewInv.m22;
  float normalLength = sqrt(lightNormalX * lightNormalX + lightNormalY * lightNormalY + lightNormalZ * lightNormalZ) * -1;
  sh.set("lightDirection", lightNormalX / -normalLength, lightNormalY / -normalLength, lightNormalZ / -normalLength);

  // Send the shadowmap to the default shader
  sh.set("shadowMap", shadowMap);
}
