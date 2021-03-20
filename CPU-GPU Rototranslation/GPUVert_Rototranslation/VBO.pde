import java.nio.*;

public class VBOInterleaved implements ShaderSource {
  final static short VRT_CMP_COUNT = 4; //Number of component per vertex
  final static short CLR_CMP_COUNT = 4; //Number of component per color
  final static short UV_CMP_COUNT = 4; //Number of component per uv
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

  final static short NBR_COMP    = VRT_CMP_COUNT + CLR_CMP_COUNT + UV_CMP_COUNT;
  final static short STRIDE      =                        NBR_COMP * Float.BYTES;
  final static short VRT_OFFSET  =                               0 * Float.BYTES;
  final static short CLR_OFFSET  =                   VRT_CMP_COUNT * Float.BYTES;
  final static short  UV_OFFSET  = (VRT_CMP_COUNT + CLR_CMP_COUNT) * Float.BYTES;

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
    this.VBOi = new float[vertexCount * NBR_COMP];
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

  public void setVertTexCoord(int i, float u, float v, float s, float t) {
    this.VBOi[i * NBR_COMP +  8] = u;
    this.VBOi[i * NBR_COMP +  9] = v;
    this.VBOi[i * NBR_COMP + 10] = s;
    this.VBOi[i * NBR_COMP + 11] = t;
  }

  public void draw(PGraphics context) {
    PGL pgl = context.beginPGL();
    this.shader.bind();

    //send uniform to shader if necessary -> this be to be set a variables
    //...
    this.shader.set("rotationMatrix", new PMatrix3D((float)R[0], (float)R[1], (float)R[2], 0.0, 
      (float)R[3], (float)R[4], (float)R[5], 0.0, 
      (float)R[6], (float)R[7], (float)R[8], 0.0, 
      0.0, 0.0, 0.0, 1.0));

    this.shader.set("translationMatrix", (float)T[0], (float)T[1], (float)T[2], 0.0);
    this.shader.set("intrinsicMatrix", (float)Cx, (float)Cy, (float)Fx, (float)Fy);
    this.shader.set("dataTexture", packedDepth);
    this.shader.set("dataMax", dataMax);
    this.shader.set("size", 2000.0);

    //get attributes location
    int vrtLoc = pgl.getAttribLocation(this.shader.glProgram, "vertex");
    pgl.enableVertexAttribArray(vrtLoc);

    int clrLoc = pgl.getAttribLocation(this.shader.glProgram, "color");
    pgl.enableVertexAttribArray(clrLoc);

    int uvLoc = pgl.getAttribLocation(this.shader.glProgram, "texCoord");
    pgl.enableVertexAttribArray(uvLoc);

    //bind VBO
    pgl.bindBuffer(PGL.ARRAY_BUFFER, this.attributeVboId);

    //fill data
    pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * this.VBOi.length, this.attributeBuffer, PGL.STATIC_DRAW);//USE PGL.STATIC_DRAW if attributes are not set to be update by the CPU

    //Associate current bound vbo with attribute
    pgl.vertexAttribPointer(vrtLoc, VRT_CMP_COUNT, PGL.FLOAT, false, STRIDE, VRT_OFFSET);
    pgl.vertexAttribPointer(clrLoc, CLR_CMP_COUNT, PGL.FLOAT, false, STRIDE, CLR_OFFSET);
    pgl.vertexAttribPointer( uvLoc, UV_CMP_COUNT, PGL.FLOAT, false, STRIDE, UV_OFFSET);

    //draw buffer
    pgl.drawArrays(PGL.POINTS, 0, this.vertexCount);

    //disable arrays
    pgl.disableVertexAttribArray(vrtLoc);
    pgl.disableVertexAttribArray(clrLoc);
    pgl.disableVertexAttribArray( uvLoc);

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
    "#ifdef GL_ES", 
    "precision highp float;", 
    "precision highp vec4;", 
    "precision highp vec3;", 
    "precision highp vec2;", 
    "precision highp int;", 
    "precision highp sampler2D;",
    "#endif",  
    "uniform mat4 transform;", 
    "uniform mat4 projection;", 
    "uniform mat4 rotationMatrix = mat4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);", 
    "uniform vec4 translationMatrix = vec4(0, 0, 0, 0);", 
    "uniform vec4 intrinsicMatrix = vec4(1, 1, 1, 1);", 
    "uniform sampler2D dataTexture;", 
    "uniform int dataMax = 8000;", 
    "uniform float size = 500.0;", 
    "in vec4 vertex;", 
    "in vec4 color;", 
    "in vec4 texCoord;", 
    "out vec4 vertColor;", 
    "int decodeRGBAMod(vec4 rgba, float edge){", 
    "float divider = (float(edge) / 256.0);", 
    "int index = int(round(rgba.b * divider));", 
    "return int(rgba.r * 255) + index * 255;", 
    "}", 
    "vec4 backProject(vec2 pixel, float depth){", 
    "float x = (pixel.x - intrinsicMatrix.x) * depth / intrinsicMatrix.z;", 
    "float y = (pixel.y - intrinsicMatrix.y) * depth / intrinsicMatrix.w;", 
    "return vec4(x, y, depth, 1.0);", 
    "}", 
    "vec4 computeNewPosition(vec4 pos, mat4 R, vec4 T){", 
    "return (R * pos) + T;", 
    "}", 
    "void main(){", 
    //define uv
    "vec2 uv = texCoord.xy;", 
    //get data into texture
    "vec4 tex = texture(dataTexture, uv);", 
    //decode data
    "float depth =float(decodeRGBAMod(tex, float(dataMax))) / dataMax;", 
    //get world position
    "vec4 backproj = backProject(vertex.xy, float(depth));", 
    "backproj.xyz *= size;", 
    "vec4 pos = computeNewPosition(backproj, rotationMatrix, translationMatrix);", 
    "gl_Position = transform * pos;", 
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
