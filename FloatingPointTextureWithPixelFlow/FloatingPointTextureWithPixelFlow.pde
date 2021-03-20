import com.jogamp.opengl.GL;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLSLProgram;
import com.thomasdiewald.pixelflow.java.dwgl.DwGLTexture;

DwPixelFlow context;
PGraphics2D canvas; // A PGraphics object to render the data to

// Two shaders: one to update data, one to visualise data to screen
DwGLSLProgram shader;
DwGLSLProgram shaderScreen;

// An object containing two frame buffer objects (textures) I can swap
DwGLTexture.TexturePingPong buffer = new DwGLTexture.TexturePingPong();
PShader sh;
void settings() {
  size(800 * 3, 600, P3D);
  PJOGL.profile = 4;
}

void setup() {
  context = new DwPixelFlow(this);
  canvas = (PGraphics2D) createGraphics(512, 512, P2D);

  shader = context.createShader("my-shader.glsl");
  shaderScreen = context.createShader("my-shader-screen.glsl");

  buffer.resize(context, GL.GL_RGBA32F, 512, 512, GL.GL_RGBA, GL.GL_FLOAT, GL.GL_NEAREST, GL.GL_REPEAT, 4, 1);

  pgl = (PJOGL) beginPGL();  
  gl = pgl.gl.getGL2ES2();
  Texture test = createRgbaFloatTexture(gl, 10, 10);
  endPGL();
  
  sh = loadShader("my-shader-screen - Copie.glsl");
  sh.set("uTexture", textureHandles[0]);
  
  context.printGL_MemoryInfo();
  
  println(test,
          test.getEstimatedMemorySize());
}

// Draw shader output to buffer.dest, where buffer.src acts as input data
void update() {
  context.begin();
  context.beginDraw(buffer.dst);

  shader.begin();
  shader.uniformTexture("uTexture", buffer.src);
  shader.drawFullScreenQuad();
  shader.end();

  context.endDraw();
  context.end();

  buffer.swap();
  
}

void draw() {
  
  update();

  // Render data to PGraphics object with a shader to visualise data
  context.begin();
  context.beginDraw(canvas);

  shaderScreen.begin();
  shaderScreen.uniformTexture("uTexture", buffer.src);
  shaderScreen.drawFullScreenQuad();
  shaderScreen.end();

  context.endDraw();
  context.end();

  // Render PGraphics object to screen
  image(canvas, 0, 0);
  shader(sh);
  fill(255);
  rect(0, 0, width, height);
}
