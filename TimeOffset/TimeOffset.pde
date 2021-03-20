void setup() {
  size(1000, 500);
}

void draw() {

  randomSeed(1);
  background(127);
  noStroke();
  int offset = 1000;
  float h = 50;
  float xoffset =  (float)(width * 0.5)/offset;

  float offsetT = norm(mouseX, 0, width);

  for (int i=0; i<offset; i++) {
    float normi = (float)i/(float)offset;
    float normiSwitch = 1.0 - abs(normi * 2.0 - 1.0);

    float normiO = (normi) / offsetT;
    float normiS = (normiO > 1.0) ? 0.0 : normiO; 
    float normiE = (normiO > 1.0) ? 1.0 - ((normi - offsetT) / (1.0 - offsetT)) : 0.0;
    float normiOffset = normiS + normiE;


    float x = i * xoffset;
    float y = 0;
    noStroke();
    rectMode(CORNER);
    fill(normi * 255);
    rect(x, y, xoffset, h);
    fill(normiSwitch * 255);
    rect(x, h, xoffset, h);
    fill(normiS * 255);
    rect(x, h * 2, xoffset, h);
    fill(normiE * 255);
    rect(x, h * 3, xoffset, h);
    fill(normiOffset * 255);
    rect(x, h * 4, xoffset, h);

    //shape exemple
    rectMode(CENTER);
    fill(100);
    rect(x, h * 8, xoffset, h * 2 * normiOffset);
    if (i % 100 == 0) {
      noFill();
      stroke(0);
      rect(x, h*8, h * 2 * normiOffset, h * 2 * normiOffset);
    }

    //shape 2 exemples
    float yr = (random(1) * 2.0 - 1.0)  * normiOffset * h * 0.5;
    rectMode(CENTER);
    fill(100);
    //rect(x + width / 2, h * 8, xoffset, h * 2 * normiOffset);
    if (i % 25 == 0) {
      noFill();
      stroke(0);
      pushMatrix();
      translate(width * 0.5 + x, h * 8 + yr);
      rotate(random(TWO_PI) * normiOffset);
      rect(0, 0, h * 2 * normiOffset, h * 2 * normiOffset);
      popMatrix();
    }
  }

  fill(255);
  textAlign(LEFT);
  text("Object scale variation along to joints", 20, h * 6.5);
  text("HIP", 20, h * 7.5);
  textAlign(RIGHT);
  text("KNEE", width * 0.5 - 20, h * 7.5);
  
  text("HIP", width * 0.5 + 20, h * 7.5);
  textAlign(RIGHT);
  text("KNEE", width - 20, h * 7.5);
}

void keyPressed() {
  if (key == 's') {
    saveFrame(frameCount+".png");
  }
}
