import fpstracker.core.*;

PerfTracker pt;

PShader shader;

void settings(){
    float w = 3;
    float h = 8;
    float s = 125;
    size(floor(w*s), floor(h*s), P2D);
    smooth(8);
}

void setup(){
    pt = new PerfTracker(this, 120);

    shader = loadIncludeFragment(this, "shader.glsl", false);
    //surface.setLocation(0, -1080);
}

void draw(){
    background(127);

    shader.set("time", millis());
    shader.set("mouse", (float)mouseX/width, (float)mouseY/height);
    shader(shader);
    rect(0, 0, width, height);

    resetShader();
    //pt.display(0, 0);
}
