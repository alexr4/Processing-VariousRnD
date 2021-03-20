static public class CONFIG {
  static public int width, height, originalWidth, originalHeight, windowX, windowY, fps = 60;
  static public float aspectRatio;
  static public int smooth = 8;
  static public float scale;
  static public String appname, exportPath, simplifiedName;
  static public boolean  topBar;
  static public PGraphics ctx;
}

private void loadConfig(String configfile) {
  try {
    JSONObject config       = new JSONObject(loadJSONObject(configfile).toString());
    JSONObject output       = config.getJSONObject("output");

    CONFIG.appname              = config.getString("title");
    CONFIG.originalWidth        = output.getInt("width");
    CONFIG.originalHeight       = output.getInt("height");
    CONFIG.scale                = (float) output.getDouble("scale");
    CONFIG.fps                  = output.getInt("fps");
    CONFIG.windowX              = output.getInt("x");
    CONFIG.windowY              = output.getInt("y");
    CONFIG.smooth               = output.getInt("smooth");
    CONFIG.topBar               = output.getBoolean("topBar");
    CONFIG.width                = round(CONFIG.originalWidth * CONFIG.scale);
    CONFIG.height               = round(CONFIG.originalHeight * CONFIG.scale);
    CONFIG.exportPath           = output.getString("exportPath");
    CONFIG.simplifiedName       = CONFIG.appname.replaceAll("[^a-zA-Z0-9]", "");
    CONFIG.aspectRatio          = (float)CONFIG.width / (float)CONFIG.height;

    println(CONFIG.appname+" config ready.\n"+
      "Visual Output: "+ CONFIG.width + "x" + CONFIG.height + "\tTarget FPS: " + CONFIG.fps + "\tPosition: " + CONFIG.windowX + "x" + CONFIG.windowY);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
}
