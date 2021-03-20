import com.jogamp.opengl.GL3;
import java.nio.IntBuffer;

IntBuffer envMapTextureID;
PShape cubeMapObj;
PMatrix3D cameraMatrix;

int mipLevel = 7;
String textureName = "output_pmrem";
String[] cubeSideNames  = { 
  "_posx", 
  "_negx", 
  "_posy", 
  "_negy", 
  "_posz", 
  "_negz"
};
String[] mipSize = {
  "_1024x1024", 
  "_512x512", 
  "_256x256", 
  "_128x128", 
  "_64x64", 
  "_32x32", 
  "_16x16" 
  //"_8x8", 
};

void generateCubeMap(String filepath) {
  PGL pgl = beginPGL();
  // create the OpenGL-based cubeMap
  IntBuffer envMapTextureID = IntBuffer.allocate(1);
  pgl.genTextures(1, envMapTextureID);
  pgl.activeTexture(PGL.TEXTURE1);//PGL.TEXTURE3+2
  pgl.enable(GL3.GL_TEXTURE_CUBE_MAP_SEAMLESS);
  pgl.enable(PGL.TEXTURE_CUBE_MAP);  
  pgl.bindTexture(PGL.TEXTURE_CUBE_MAP, envMapTextureID.get(0));
  pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_WRAP_S, PGL.CLAMP_TO_EDGE);
  pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_WRAP_T, PGL.CLAMP_TO_EDGE);
  pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_WRAP_R, PGL.CLAMP_TO_EDGE);
  pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_MIN_FILTER, PGL.LINEAR_MIPMAP_LINEAR);
  pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_MAG_FILTER, PGL.LINEAR);

  for (int k=0; k<mipLevel; k++) {
    PImage[] textures = new PImage[cubeSideNames.length];
    for (int i=0; i<textures.length; i++) {
      textures[i] = loadImage(filepath+"/Radiance/"+textureName+cubeSideNames[i]+"_"+k+mipSize[k]+".tga");
    }

    // put the textures in the cubeMap
    for (int i=0; i<textures.length; i++) {
      int w = textures[i].width;
      int h = textures[i].height;
      textures[i].loadPixels();
      int[] pix = textures[i].pixels;
      int[] rgbaPixels = new int[pix.length];
      for (int j = 0; j< pix.length; j++) {
        int pixel = pix[j];
        rgbaPixels[j] = 0xFF000000 | ((pixel & 0xFF) << 16) | ((pixel & 0xFF0000) >> 16) | (pixel & 0x0000FF00);
      }
      pgl.texImage2D(PGL.TEXTURE_CUBE_MAP_POSITIVE_X + i, k, PGL.RGBA, w, h, 0, PGL.RGBA, PGL.UNSIGNED_BYTE, java.nio.IntBuffer.wrap(rgbaPixels));
    }
  }
  pgl.generateMipmap(PGL.TEXTURE_CUBE_MAP); //this is requiered for mipmaps
  endPGL();
  flush();
  
  
  cubeMapObj = texturedCube(filepath+"/Skybox/", 2000);
}

PShape texturedCube(String filepath, float scale) {
  PShape cube = createShape(GROUP);
  textureName = "output_skybox";
  PImage[] textures = new PImage[cubeSideNames.length];
  for (int i=0; i<textures.length; i++) {
    textures[i] = loadImage(filepath+textureName+cubeSideNames[i]+".tga");
  }

  // +Z "front" face
  textureMode(NORMAL);
  PShape cubepz = createShape();
  cubepz.beginShape(QUADS);
  cubepz.texture(textures[4]);
  cubepz.vertex(-1*scale, -1*scale, 1*scale, 0, 0);
  cubepz.vertex( 1*scale, -1*scale, 1*scale, 1, 0);
  cubepz.vertex( 1*scale, 1*scale, 1*scale, 1, 1);
  cubepz.vertex(-1*scale, 1*scale, 1*scale, 0, 1);
  cubepz.endShape();

  // -Z "back" face
  PShape cubenz = createShape();
  cubenz.beginShape(QUADS);
  cubenz.texture(textures[5]);
  cubenz.vertex( 1*scale, -1*scale, -1*scale, 0, 0);
  cubenz.vertex(-1*scale, -1*scale, -1*scale, 1, 0);
  cubenz.vertex(-1*scale, 1*scale, -1*scale, 1, 1);
  cubenz.vertex( 1*scale, 1*scale, -1*scale, 0, 1);
  cubenz.endShape();

  // +Y "bottom" face
  PShape cubepy = createShape();
  cubepy.beginShape(QUADS);
  cubepy.texture(textures[3]);
  cubepy.vertex(-1*scale, 1*scale, 1*scale, 0, 0);
  cubepy.vertex( 1*scale, 1*scale, 1*scale, 1, 0);
  cubepy.vertex( 1*scale, 1*scale, -1*scale, 1, 1);
  cubepy.vertex(-1*scale, 1*scale, -1*scale, 0, 1);
  cubepy.endShape();

  // -Y "top" face
  PShape cubeny = createShape();
  cubeny.beginShape(QUADS);
  cubeny.texture(textures[2]);
  cubeny.vertex(-1*scale, -1*scale, -1*scale, 0, 0);
  cubeny.vertex( 1*scale, -1*scale, -1*scale, 1, 0);
  cubeny.vertex( 1*scale, -1*scale, 1*scale, 1, 1);
  cubeny.vertex(-1*scale, -1*scale, 1*scale, 0, 1);
  cubeny.endShape();

  // +X "right" face
  PShape cubepx = createShape();
  cubepx.beginShape(QUADS);
  cubepx.texture(textures[0]);
  cubepx.vertex( 1*scale, -1*scale, 1*scale, 0, 0);
  cubepx.vertex( 1*scale, -1*scale, -1*scale, 1, 0 );
  cubepx.vertex( 1*scale, 1*scale, -1*scale, 1, 1);
  cubepx.vertex( 1*scale, 1*scale, 1*scale, 0, 1);
  cubepx.endShape();

  // -X "left" face
  PShape cubenx = createShape();
  cubenx.beginShape(QUADS);
  cubenx.texture(textures[1]);
  cubenx.vertex(-1*scale, -1*scale, -1*scale, 0, 0);
  cubenx.vertex(-1*scale, -1*scale, 1*scale, 1, 0);
  cubenx.vertex(-1*scale, 1*scale, 1*scale, 1, 1);
  cubenx.vertex(-1*scale, 1*scale, -1*scale, 0, 1);
  cubenx.endShape();

  cube.addChild(cubepz);
  cube.addChild(cubenz);
  cube.addChild(cubepy);
  cube.addChild(cubeny);
  cube.addChild(cubepx);
  cube.addChild(cubenx);
  return cube;
}

void displayCubeMap()
{
  pushStyle();
  noStroke();
  shape(cubeMapObj);
  popStyle();

  //cameraMatrix correction
  PGraphics3D g3 = (PGraphics3D)g;
  cameraMatrix = g3.camera;
  //cameraMatrix = g3.cameraInv;



  envShader.set("camMatrix", cameraMatrix);
}
