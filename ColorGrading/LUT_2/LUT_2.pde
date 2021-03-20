//Easy color correction using LookUp Table 
//Inspired by Waltz Binaire add-on for VVVVV : http://waltzbinaire.com/lutz/
//Based on Lev Zelensky paper : http://liovch.blogspot.fr/2012/07/add-instagram-like-effects-to-your-ios.html?m=1
//And Matt desLauriers implementation : https://github.com/mattdesl/glsl-lut 
//Based on http://alaingalvan.tumblr.com/post/79864187609/glsl-color-correction-shaders

PImage source;
PImage[] lutsrc;
PImage actualLut;
PShader PP_LUT;
PGraphics buffer;
int index;
String[] sourceName = {
  "LUT_src", 
  "LUT_old_2", 
  "LUT_old", 
  "LUT_cool", 
  "LUT_Martin"
};

String txt;

void settings() {
  float scale = 1.0;
  size(int (512 * scale), int(512 * scale), P3D);
}

void setup() {
  source = loadImage("test.png");
  lutsrc = new PImage[sourceName.length];
  for (int i=0; i<lutsrc.length; i++) {
    lutsrc[i] = loadImage("_LUT/"+sourceName[i]+".jpg");
  }
  actualLut = lutsrc[index];

  buffer = createGraphics(source.width, source.height, P3D);
  PP_LUT = loadShader("PP_LUT.glsl");
  PP_LUT.set("resolution", (float) width, (float) height);  
  PP_LUT.set("lut", actualLut);  
  surface.setLocation(0, 0);
}

void draw() {
  buffer.beginDraw();
  buffer.background(0);
  if (!mousePressed) {
    buffer.shader(PP_LUT);
    txt = "color grading : "+sourceName[index];
  } else {
    buffer.resetShader();
    txt = "source";
  }
  buffer.image(source, 0, 0);
  buffer.endDraw();

  image(buffer, 0, 0, width, height);
  textSize(18);
  text(txt, 20, height - 40);
  image(actualLut, 0, 0, actualLut.width/8, actualLut.height/8);
}

void keyPressed() {
  if (key == 'a') {
    index --;
    if (index <0) {
      index = sourceName.length - 1;
    }
    actualLut = lutsrc[index];  
    PP_LUT.set("lut", actualLut);
  }
  if (key == 'z') {
    index ++;
    if (index >= sourceName.length) {
      index = 0;
    }
    actualLut = lutsrc[index];  
    PP_LUT.set("lut", actualLut);
  }

  if (key =='s') {
    saveFrame("img_"+frameCount+".png");
  }
}
