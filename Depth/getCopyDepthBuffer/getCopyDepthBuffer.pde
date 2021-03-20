//--sketch=D:/_DEV/RnD-Various/Depth/getDepthBuffer --output=D:/_DEV/RnD-Various/Depth/getDepthBuffer\_OUT  --force --present

import java.nio.*;
import com.jogamp.opengl.GL3;
import com.jogamp.opengl.GL4;

import peasy.*;

PeasyCam cam;
PGraphics b;
PShader depthviewer;
IntBuffer textureID;

void settings () {
  int scale = 2;
  size(1920/scale, 1080/scale, P3D);
}

void setup() {
  cam = new PeasyCam(this, 500);

  b = createGraphics(1920, 1080, P3D);
  b.smooth(8);
  b.hint(ENABLE_BUFFER_READING);//enable this to get buffer reading for multisample buffers

  b.beginDraw();
  b.background(0);
  b.endDraw();

  depthviewer = loadShader("depthViewer.glsl");

  textureID = IntBuffer.allocate(1);
  PGL pgl = beginPGL();
  pgl.genTextures(1, textureID);
  pgl.activeTexture(PGL.TEXTURE3+2);//PGL.TEXTURE3+2
  pgl.bindTexture(PGL.TEXTURE_2D, textureID.get(0));

  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_WRAP_S, PGL.CLAMP_TO_EDGE);
  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_WRAP_T, PGL.CLAMP_TO_EDGE);
  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_MIN_FILTER, PGL.NEAREST);
  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_MAG_FILTER, PGL.LINEAR);
  //test red pixels texture
  int[] rgbaPixels = new int[b.width * b.height];
  for (int j = 0; j< rgbaPixels.length; j++) {
    rgbaPixels[j] = color(0, 255, 0, 255);
  }
  //pgl.copyTexImage2D(PGL.TEXTURE_2D, 0, PGL.DEPTH_COMPONENT24, 0, 0, b.width, b.height, 0);
  //pgl.texImage2D(PGL.TEXTURE_2D, 0, PGL.DEPTH_COMPONENT24, b.width, b.height, 0, PGL.DEPTH_COMPONENT, PGL.UNSIGNED_BYTE, null);
  pgl.texImage2D(PGL.TEXTURE_2D, 0, PGL.RGBA, b.width, b.height, 0, PGL.RGBA, PGL.UNSIGNED_BYTE, java.nio.IntBuffer.wrap(rgbaPixels));
  
  endPGL();
  flush();

}  

void draw() {
  b.beginDraw();
  b.background(255, 0, 0);
  b.lights();
  b.rotateY(millis() * 0.001);
  b.noStroke();
  b.fill(255);
  b.box(100);
  //copyDepth(b); //get the depth before the end draw if you want valid data
  b.endDraw(); 

  cam.getState().apply(b);

  cam.beginHUD();
  
  PGL pgl = beginPGL();
  pgl.activeTexture(PGL.TEXTURE3+2);
  pgl.bindTexture(PGL.TEXTURE_2D, 5);
  depthviewer.set("depthTexture", 5);
  
  shader(depthviewer);
  fill(0, 255, 0);
  rect(0, 0, width, height);
  endPGL();

  resetShader();
  image(b, 0, 0, width* 0.25, height*.25);
  cam.endHUD();

  surface.setTitle("FPS: "+frameRate);
}


void copyDepth(PGraphics b) {

  PGL pgl = ((PGraphicsOpenGL)b).beginPGL();
  FrameBuffer fb = ((PGraphicsOpenGL)b).getFrameBuffer(true);


  pgl.bindFramebuffer(PGL.READ_FRAMEBUFFER, fb.glFbo);
  //fb.bind();
  pgl.bindTexture(PGL.TEXTURE_2D, textureID.get(0));
  pgl.copyTexImage2D(PGL.TEXTURE_2D, 0, PGL.DEPTH_COMPONENT24, 0, 0, b.width, b.height, 0);
  //pgl.texImage2D(PGL.TEXTURE_2D, 0, PGL.DEPTH_COMPONENT24, b.width, b.height, 0, PGL.DEPTH_COMPONENT, PGL.UNSIGNED_BYTE, null);
  //pgl.copyTexSubImage2D(PGL.TEXTURE_2D, 0, 0, 0, 0, 0, b.width, b.height);
  pgl.bindFramebuffer(PGL.READ_FRAMEBUFFER, 0);
  pgl.bindTexture(PGL.TEXTURE_2D, 0);
  

  b.endPGL();
}
