PImage src;

int w, h;
//il est necessaire pour le moment de créer et instancier les calques sur lesquels nous allons écrire les effets
PGraphics pass0;
PGraphics pass1;


void settings() {
  src = loadImage("test.png");

  w = floor(src.width / 1);
  h = floor(src.height / 1);
  size(w * 3, h * 1, P2D);
}

void setup() {
  //you nedd to set the path of the shader if they on a subfolder of data
  ImgFilter.setPath("data/imgFilter");

  //Les calques sont à la meme taille que l'image à modifier
  pass0 = createGraphics(src.width, src.height, P2D);
  pass1 = createGraphics(src.width, src.height, P2D);

  //surface.setLocation(0, 0);

}

void draw() {
  //Pour appeler un filtre le modèle est : ImgFilter.Filtre(context, calque source, ...param..., calque de destination)
  
  //ImgFilter.getChromaWarpImage(context, source, strength, inc, dest);
  //ImgFilter.getChromaWarpImage(this, src, 0.1, 0.1, pass0);
  //ImgFilter.getGrainImage(context, source, intensity, animation Time, dest);
  //ImgFilter.getGrainImage(this, pass0, 0.15, millis()/1000.0, pass1);
  
  image(src, 0, 0);
  image(pass0, src.width, 0);
  image(pass1, src.width * 2, 0);

  surface.setTitle("frameRate : "+round(frameRate)+" resolution : "+width+"*"+height);
}
