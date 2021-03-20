import fpstracker.core.*;

PerfTracker pt;

PShader shader;

void settings(){
    size(1280, 720, P2D);
    smooth(8);
}

void setup(){
    pt = new PerfTracker(this, 120);

    ArrayList<String> defines = new ArrayList<String>();
    defines.add("#define PI 3.1415926535897932384626433832795");
    
    shader = loadIncludeFragment(this, "shader.glsl", true, defines);
}

void draw(){
    background(127);

    shader(shader);
    rect(0, 0, width, height);

    resetShader();
    pt.display(0, 0);
}