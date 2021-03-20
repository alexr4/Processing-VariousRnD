//--sketch=D:/_DEV/RnD-Various/Depth/getDepthBuffer --output=D:/_DEV/RnD-Various/Depth/getDepthBuffer\_OUT  --force --present

import java.nio.*;
import com.jogamp.opengl.GL3;
import com.jogamp.opengl.GL4;


PShader depthviewer;
IntBuffer textureID;

void settings () {
  int scale = 2;
  size(1920/scale, 1080/scale, P3D);
}

void setup() {

  depthviewer = loadShader("depthViewer.glsl");

  textureID = IntBuffer.allocate(1);
  PGL pgl = beginPGL();
  pgl.genTextures(1, textureID);
  pgl.activeTexture(PGL.TEXTURE1);//PGL.TEXTURE3+2
  pgl.bindTexture(PGL.TEXTURE_2D, textureID.get(0));
  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_WRAP_S, PGL.CLAMP_TO_EDGE);
  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_WRAP_T, PGL.CLAMP_TO_EDGE);
  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_MIN_FILTER, PGL.NEAREST);
  pgl.texParameteri(PGL.TEXTURE_2D, PGL.TEXTURE_MAG_FILTER, PGL.LINEAR);
  //test red pixels texture
  int[] rgbaPixels = new int[width * height];
  for (int j = 0; j< rgbaPixels.length; j++) {
    rgbaPixels[j] = color(random(255), random(255), random(255), 255);
  }
   pgl.texImage2D(PGL.TEXTURE_2D, 0, PGL.RGBA, width, height, 0, PGL.RGBA, PGL.UNSIGNED_BYTE, java.nio.IntBuffer.wrap(rgbaPixels));
  
  endPGL();
  flush();
}  

void draw() {
  PGL pgl = beginPGL();
  pgl.activeTexture(PGL.TEXTURE1);//PGL.TEXTURE3+2
  pgl.bindTexture(PGL.TEXTURE_2D, 1);//5
  depthviewer.set("depthTexture", 1);//5
  
  shader(depthviewer);
  fill(0, 255, 0);
  rect(0, 0, width, height);
  endPGL();


  surface.setTitle("FPS: "+frameRate);
}
