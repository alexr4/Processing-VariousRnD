PGraphics buffer;
int scale = 10;



void settings() {
  size(4500 / scale, 255, P3D);
}

void setup() {
  buffer = createGraphics(width * scale, 255, P3D);
}


void draw() {
  background(0);
  int[] rawData = new int[4500];
  int[] modData = new int[4500];
  int row = height/3;

  for (int i =0; i<rawData.length; i++) {
    rawData[i] = i;
    modData[i] = rawData[i] % 255;
  }

  buffer.beginDraw();
  buffer.background(0, 1);
  for (int i =0; i<rawData.length; i++) {
    float normData = (float)rawData[i]/ 4500.0;
    int rawDatai4500Map = (int) (normData * 255);
    
    int modDatai = modData[i];
    
    int modIndex = rawData[i] / 255;
    float modIndexAsAlpha = (modIndex / 17.0) * 255;
    int modIndexRetreived = int((modIndexAsAlpha / 255.0) * 17.0);
    float retrievedData = ((modDatai + 256 * modIndexRetreived) / 4500.0) * 255;

    buffer.stroke(rawDatai4500Map);
    buffer.line(i, 0 * row, i, row * 1);

    buffer.stroke(modDatai, modDatai, modIndexAsAlpha);//, modIndexAsAlpha);
    buffer.line(i, row * 1, i, row * 2);

    buffer.stroke(retrievedData);
    buffer.line(i, row * 2, i, row * 3);
  }
  buffer.endDraw();

  image(buffer, 0, 0, width, height);
  
  fill(255, 255, 0);
  text("Raw data from 0 to 4500", 20, 20 + row * 0);
  text("Mod data from 0 to 255\nand Mod index as alpha from 0 to 255", 20, 20 + row * 1);
  text("Raw data from 0 to 4500 retreived from Mod data\nand Mod index stocked as alpha value", 20, 20 + row * 2);
  
  surface.setTitle("FPS : "+round(frameRate));
  noLoop();
}
