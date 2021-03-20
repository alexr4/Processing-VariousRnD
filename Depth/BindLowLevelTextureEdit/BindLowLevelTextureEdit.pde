//--sketch=D:/_DEV/RnD-Various/Depth/getDepthBuffer --output=D:/_DEV/RnD-Various/Depth/getDepthBuffer\_OUT  --force --present

import java.nio.*;
import com.jogamp.opengl.GL3;
import com.jogamp.opengl.GL4;


PShader depthviewer;
IntBuffer textureID;
PImage pImage;
PGraphics aux;
PImage checker;
int textureUnit;

void settings () {
  int scale = 2;
  size(1920/scale, 1920/scale, P3D);
}

void setup() {
  textureUnit = PGL.TEXTURE3;
  println(PGL.TEXTURE1, PGL.TEXTURE2, PGL.TEXTURE3);

  pImage = loadImage("trigger.jpg");
  aux = createGraphics(width, height, P2D);
  aux.beginDraw();
  aux.image(pImage, 0, 0, aux.width, aux.height);
  aux.endDraw();

  checker = loadImage("custom_uv_diag.png");

  depthviewer = loadShader("depthViewer.glsl");

  textureID = IntBuffer.allocate(1);
  PGL pgl = beginPGL();
  pgl.genTextures(1, textureID);
  pgl.activeTexture(textureUnit);//PGL.TEXTURE3+2
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

  this.depthviewer.bind();
  
  //https://www.khronos.org/opengl/wiki/Example/Texture_Shader_Binding
  //retreive the location of the uniform from the shader
  int loc = pgl.getUniformLocation(depthviewer.glProgram, "depthTexture");
  //specify the value to the shader
  //pgl.uniform1i(loc, textureUnit);//using texture unit does no work here (?) need to use the texture name ? (InTbuffer)
  pgl.uniform1i(loc, textureID.get(0));

  pgl.activeTexture(textureUnit);//PGL.TEXTURE3+2
  pgl.bindTexture(PGL.TEXTURE_2D, textureID.get(0));
  //depthviewer.set("depthTexture", textureID.get(0));

  depthviewer.set("texture1", pImage);
  depthviewer.set("texture2", aux);
  depthviewer.set("checker", checker);
  
  shader(depthviewer);

  fill(0, 255, 0);
  rect(0, 0, width, height);
  this.depthviewer.unbind();
  endPGL();



  surface.setTitle("FPS: "+frameRate);
}
