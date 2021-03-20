//Easy color correction using LookUp Table 
//Inspired by Waltz Binaire add-on for VVVVV : http://waltzbinaire.com/lutz/
//Based on Lev Zelensky paper : http://liovch.blogspot.fr/2012/07/add-instagram-like-effects-to-your-ios.html?m=1
//And Matt desLauriers implementation : https://github.com/mattdesl/glsl-lut 

PImage source;
PShader PP_LUT;
PGraphics buffer;
PImage lutsrc;

void settings() {
  float scale = 1.0;
  size(int (512 * scale), int(512 * scale), P2D);
}

void setup() {

  source = loadImage("test.png");
  lutsrc = loadImage("_LUT/LUTGenerated.png");
  
  buffer = createGraphics(source.width, source.height, P2D);
   
  int mode = 2;
  ((PGraphicsOpenGL)buffer).textureSampling(mode);
  
  PP_LUT = loadShader("PP_LUT.glsl");
  PP_LUT.set("resolution", (float) buffer.width, (float) buffer.height);  
  PP_LUT.set("lut", lutsrc);
  
  
}

void draw() {
  if(mousePressed)
    PP_LUT.set("clicked", 1.0);
  else
    PP_LUT.set("clicked", 0.0);
    
  
  buffer.beginDraw();
  buffer.background(0);
  buffer.shader(PP_LUT);
  buffer.image(source, 0, 0);
  buffer.endDraw();
  
  image(buffer, 0, 0, width, height);
  image(lutsrc.copy(), 0, 0, width * 0.25, height * 0.25);
}

void keyPressed(){
  switch(key){
    case '1' : 
      lutsrc = loadImage("_LUT/LUTGenerated.png");
      PP_LUT.set("lut", lutsrc);
      break;
    case '2' : 
      lutsrc = loadImage("_LUT/lookup_amatorka.png");
      PP_LUT.set("lut", lutsrc);
      break;
    case '3' : 
      lutsrc = loadImage("_LUT/lookup_miss_etikate.png");
      PP_LUT.set("lut", lutsrc);
      break;
    case '4' : 
      lutsrc = loadImage("_LUT/lookup_selective_color.png");
      PP_LUT.set("lut", lutsrc);
      break;
    case '5' : 
      lutsrc = loadImage("_LUT/lookup_soft_elegance_1.png");
      PP_LUT.set("lut", lutsrc);
      break;
    case '6' : 
      lutsrc = loadImage("_LUT/lookup_soft_elegance_2.png");
      PP_LUT.set("lut", lutsrc);
      break;
    case '7' : 
      lutsrc = loadImage("_LUT/LookupTest.png");
      PP_LUT.set("lut", lutsrc);
      break;
     case 's'  :
     save("test.png");
     break;
  }
}
