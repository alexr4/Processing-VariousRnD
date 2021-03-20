import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;

import com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.texture.Texture;
import com.jogamp.opengl.GL2ES2;

PJOGL pgl;
GL2ES2 gl;

int[] textureHandles;

//http://forum.jogamp.org/GL-RGBA32F-with-glTexImage2D-td4035766.html
public Texture createRgbaFloatTexture(GL2ES2 gl, int w, int h) { 
  boolean flipVertically = false; 

  float[] colorBuffer = new float[w * h * 4];
  FloatBuffer buffer = allocateDirectFloatBuffer(w * h * 4);


  for (int i=0; i<colorBuffer.length; i++) {
    colorBuffer[i] = random(4.0);
  }
  //printArray(colorBuffer);

   buffer.rewind();
   buffer.put(colorBuffer);
   buffer.rewind();
  println(buffer.hasArray(), buffer.isDirect());
  

  int numTextures = 1; 
  textureHandles = new int[numTextures]; 
  gl.glGenTextures(numTextures, textureHandles, 0); 

  final int glTextureHandle = textureHandles[0]; 

  gl.glBindTexture(GL.GL_TEXTURE_2D, glTextureHandle); 

  int mipmapLevel = 0; 
  int internalFormat = GL2ES2.GL_RGBA32F; 
  int numBorderPixels = 0; 
  int pixelFormat = GL2ES2.GL_RGBA; 
  int pixelType = GL2ES2.GL_FLOAT; 
  boolean mipmap = false; 
  boolean dataIsCompressed = false; 

  gl.glTexImage2D(GL.GL_TEXTURE_2D, mipmapLevel, internalFormat, w, h, numBorderPixels, pixelFormat, pixelType, buffer); 

  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR); 
  gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR_MIPMAP_LINEAR); 
  gl.glGenerateMipmap(gl.GL_TEXTURE_2D); // Don't really need mipmaps, but we'll create anyway for now. 
  Texture texture = new Texture(glTextureHandle, GL2ES2.GL_TEXTURE_2D, w, h, w, h, flipVertically); 

  return texture;
} 

FloatBuffer allocateDirectFloatBuffer(int n) {
  return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
}
