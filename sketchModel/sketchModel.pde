import fpstracker.core.*;
import org.json.JSONObject;
import org.json.JSONArray;

PerfTracker pt;

//config
String configPath = "_based/";
String configFileName = "config.json";
PGraphics ctx;

//control & UI
boolean pause;
boolean debug;

void settings() {
  if (args != null) {
    configPath       = args[0];
    configFileName   = args[1];
  } else {
    println("No config passed as arguments. Load based config file");
  }
  loadConfig(configPath+configFileName);
  if(!CONFIG.topBar) fullScreen(P3D);
  else size(250, 250, P3D);
  smooth(CONFIG.smooth);
  PJOGL.setIcon(configPath+"ico.png");
}

void setup() {

  //init surface
  surface.setSize(CONFIG.width, CONFIG.height);
  surface.setLocation(CONFIG.windowX, CONFIG.windowY);
  frameRate(CONFIG.fps);
  ctx = createGraphics(CONFIG.originalWidth, CONFIG.originalHeight, P3D); 
  
  pt = new PerfTracker(this, 120);
}

void draw() {
  //compute here
  Time.update(this, pause);
  computeBuffer(ctx);
  
  //draw here
  image(ctx, 0, 0, width, height);
  
  if (debug) {
    String uiText = CONFIG.appname + " — "+
                    "Time: "+Time.time + "\n"+
                    "Pause: "+pause;
                    
    float uiTextMargin = 20;
    float uiTextWidth = textWidth(uiText) + uiTextMargin * 2;
    pushStyle();
    fill(0);
    noStroke();
    rect(100, 0, uiTextWidth, 60);
    fill(255);
    text(uiText, 120, 20);
    popStyle();
    pt.display(0, 0);
  } else {
    pt.displayOnTopBar(CONFIG.appname);
  }
}

void computeBuffer(PGraphics ctx){
  ctx.beginDraw();
  ctx.background(240);
  ctx.ellipse(width/2, height/2, 255, 255);
  ctx.endDraw();
}

void keyPressed() {
  switch(key) {
  case 'p' :
  case 'P' :
    pause = !pause;
    break;
  case 'd' :
  case 'D' :
    debug = !debug;
    break;
  case 's':
  case 'S':
    String filename = year()+""+month()+""+day()+""+"_"+hour()+""+minute()+""+second()+""+millis()+"_"+CONFIG.simplifiedName+".png";
    ctx.save(CONFIG.exportPath+filename);
    break;

  }
}
