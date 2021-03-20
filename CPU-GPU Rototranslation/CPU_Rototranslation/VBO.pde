import java.nio.*;

public class VBOInterleaved implements ShaderSource {
  final static short VRT_CMP_COUNT = 4; //Number of component per vertex
  final static short CLR_CMP_COUNT = 4; //Number of component per color
  /*define layout for interleaved VBO
   xyzwrgbaxyzwrgbaxyzwrgba...
   
   |v1       |v2       |v3       |... vertex
   |0   |4   |8   |12  |16  |20  |... offset
   |xyzw|rgba|xyzw|rgba|xyzw|rgba|... components
   
   stride (values per vertex) is 8 floats
   vertex offset is 0 floats (starts at the beginning of each line)
   color offset is 4 floats (starts after vertex coords)
   
   |0   |4   |8
   v1 |xyzw|rgba|
   v2 |xyzw|rgba|
   v3 |xyzw|rgba|
   |...
   */

  final static short NBR_COMP    =  VRT_CMP_COUNT + CLR_CMP_COUNT;
  final static short STRIDE      = (VRT_CMP_COUNT + CLR_CMP_COUNT) * Float.BYTES;
  final static short VRT_OFFSET  =                               0 * Float.BYTES;
  final static short CLR_OFFSET  =                   CLR_CMP_COUNT * Float.BYTES;

  private float[] VBOi;
  private int vertexCount;
  private FloatBuffer attributeBuffer;
  private int attributeVboId;
  private PShader shader;
  private PApplet parent;

  public VBOInterleaved(PApplet parent) {
    this.parent = parent;
    this.init();
  }

  private void init() {
    this.shader = new PShader(this.parent, this.vertSource, this.fragSource);
  }

  private void initVBO(PGraphics context, int numberOfVertex) {
    this.vertexCount = numberOfVertex;
    this.VBOi = new float[vertexCount * 8];
    this.attributeBuffer = allocateDirectFloatBuffer(VBOi.length);

    PGL pgl = context.beginPGL();
    IntBuffer intBuffer = IntBuffer.allocate(1);
    pgl.genBuffers(1, intBuffer);
    this.attributeVboId = intBuffer.get(0);
    context.endPGL();

    this.feedVBO();
    this.updateVBO();
  }

  private void feedVBO() {
    for (int i=0; i<VBOi.length; i++) {
      this.VBOi[i] = 1.0;
    }
  }

  public void updateVBO() {
    try {
      this.attributeBuffer.rewind(); 
      this.attributeBuffer.put(VBOi); 
      this.attributeBuffer.rewind();
    }
    catch(Exception e) {
      e.printStackTrace();
    }
  }
  
  public void setVertex(int i, float x, float y, float z) {
    this.VBOi[i * NBR_COMP + 0] = x;
    this.VBOi[i * NBR_COMP + 1] = y;
    this.VBOi[i * NBR_COMP + 2] = z;
  }

  public void setColor(int i, float r, float g, float b, float a) {
    this.VBOi[i * NBR_COMP + 4] = r;
    this.VBOi[i * NBR_COMP + 5] = g;
    this.VBOi[i * NBR_COMP + 6] = b;
    this.VBOi[i * NBR_COMP + 7] = a;
  }

  public void draw(PGraphics context) {
    PGL pgl = context.beginPGL();
    this.shader.bind();
    //send uniform to shader if necessary
    //...

    //get attributes location
    int vrtLoc = pgl.getAttribLocation(this.shader.glProgram, "vertex");
    pgl.enableVertexAttribArray(vrtLoc);

    int clrLoc = pgl.getAttribLocation(this.shader.glProgram, "color");
    pgl.enableVertexAttribArray(clrLoc);

    //bind VBO
    pgl.bindBuffer(PGL.ARRAY_BUFFER, this.attributeVboId);

    //fill data
    pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * this.VBOi.length, this.attributeBuffer, PGL.STATIC_DRAW);//USE PGL.STATIC_DRAW if attributes are not set to be update by the CPU

    //Associate current bound vbo with attribute
    pgl.vertexAttribPointer(vrtLoc, VRT_CMP_COUNT, PGL.FLOAT, false, STRIDE, VRT_OFFSET);
    pgl.vertexAttribPointer(clrLoc, CLR_CMP_COUNT, PGL.FLOAT, false, STRIDE, CLR_OFFSET);
    
    //draw buffer
    pgl.drawArrays(PGL.POINTS, 0, this.vertexCount);

    //disable arrays
    pgl.disableVertexAttribArray(vrtLoc);
    pgl.disableVertexAttribArray(clrLoc);
    
    //undind VBO
    pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

    //unbind shader
    this.shader.unbind();

    context.endPGL();
  }

  //utils
  private FloatBuffer allocateDirectFloatBuffer(int n) {
    return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
  }
}

static interface ShaderSource {
  public final static String[] vertSource = {
    "#version 150", 
    "uniform mat4 transform;", 
    "in vec4 vertex;", 
    "in vec4 color;", 
    "out vec4 vertColor;", 
    "void main(){", 
    "gl_Position = transform * vertex;", 
    "vertColor = color;", 
    "}"
  };

  public final static String[] fragSource = {
    "#ifdef GL_ES", 
    "precision mediump float;", 
    "precision mediump int;", 
    "#endif", 
    "in vec4 vertColor;", 
    "void main() {", 
    "gl_FragColor = vertColor;", 
    "}"
  };
}
