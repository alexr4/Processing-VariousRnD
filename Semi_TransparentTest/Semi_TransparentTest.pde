
size(300, 200, P2D);
//background(204);
smooth(8);

PImage t = loadImage("encodedPosBuffer.png");
color red = color(255, 0, 0);
color blue = color(0, 0, 255);
PGraphics pg = createGraphics(100, 200);
PGraphics pg2 = createGraphics(100, 200, P2D);

pg.beginDraw();
// pg.background(255, 0)
pg.noStroke();
pg.fill(red, 128);
pg.rect(0, 0, 100, 200);

pg.noStroke();
pg.fill(blue, 128);
pg.ellipse(pg.width/2, pg.height/2, 50, 50);
//pg.image(t, 0, 0);
pg.endDraw();
/*
pg2.beginDraw();
 //pg2.background(204, 0);
 pg2.noStroke();
 pg2.fill(red, 128);
 pg2.rect(0, 0, 100, 200);
 //pg2.image(t, 0, 0);
 pg2.endDraw();
 */
pg2.beginDraw();
/*
pg2.blendMode(MULTIPLY);
 pg2.background(255, 0);
 */
pg2.clear();
pg2.blendMode(REPLACE);
//PGL pgl = pg2.beginPGL();
//pgl.blendEquation(PGL.FUNC_ADD);
//pgl.blendFunc(PGL.DST_COLOR, PGL.ONE_MINUS_SRC_ALPHA);
//pgl.blendFunc(PGL.DST_COLOR, PGL.ONE_MINUS_CONSTANT_ALPHA);
//pgl.blendFunc(PGL.DST_COLOR, PGL.ONE_MINUS_CONSTANT_COLOR);
//pgl.blendFunc(PGL.SRC_COLOR, PGL.ONE_MINUS_DST_COLOR);
//pgl.blendFunc(PGL.DST_COLOR, PGL.ONE_MINUS_SRC_COLOR);
//pgl.blendFunc(PGL.DST_COLOR, PGL.ONE);
// all your drawing
pg2.noStroke();
pg2.fill(red, 128);
pg2.rect(0, 0, 100, 200);

//pg2.blendMode(BLEND);
pg2.noStroke();
pg2.fill(blue, 128);
pg2.ellipse(pg2.width/2, pg2.height/2, 50, 50);

//pg2.flush();
//endPGL();
pg2.endDraw();


image(pg, 0, 0);
image(pg2, 100, 0);

noStroke();
fill(red, 128);
rect(200, 0, 100, 200);
noStroke();
fill(blue, 128);
ellipse(250, height/2, 50, 50);
//image(t, 200, 0);

fill(255);
text("Processing 3.4", 10, 30);
text("PGraphics\nJava2D", 10, height-30);
text("PGraphics\nP2D", 110, height-30);
text("Rect\nP2D", 210, height-30);

save("P3.4.png");
