import fpstracker.core.*;
PerfTracker pt;

ArrayList<PVector> tmpPointsList;
int nbPoints = 1000;

int TMPDIM;

Box aabb;
Box range;
OcTree octree;

boolean pause;

void settings(){
    size(800, 800, P3D);
    smooth(8);
}

void setup(){
    pt = new PerfTracker(this, 120);

    TMPDIM = width;
    aabb = new Box(0, 0, 0, TMPDIM, TMPDIM, TMPDIM);
    range = new Box(0, 0, 0, TMPDIM*0.25, TMPDIM*0.25, TMPDIM*0.25);
    octree = new OcTree(aabb, 8);

    tmpPointsList = new ArrayList<PVector>();
    for(int i=0; i<nbPoints; i++){
        float x = random(-TMPDIM*0.5, TMPDIM*0.5);
        float y = random(-TMPDIM*0.5, TMPDIM*0.5);
        float z = random(-TMPDIM*0.5, TMPDIM*0.5);
        octree.insert(new Point(x, y, z));

        tmpPointsList.add(new PVector(x, y,z));
    }
}

void draw(){
    //computation
    Time.update(this, pause);

    float bx = noise(Time.time * 0.000125) * 2.0 - 1.0;
    float by = noise(Time.time * 0.0005) * 2.0 - 1.0;
    float bz = noise(Time.time * 0.000250) * 2.0 - 1.0;

    bx *= TMPDIM * 0.5;
    by *= TMPDIM * 0.5;
    bz *= TMPDIM * 0.5;

    range.x = bx;
    range.y = by;
    range.z = bz;

    ArrayList<Point> debugQueryPoint = octree.query(range); 

    background(0);
    pushMatrix();
    translate(width/2, height/2, -TMPDIM);
    rotateY(Time.time * 0.0001);
    rotateX(Time.time * 0.000125);

    color otc = color(0, 0, 255);
    color otpc = color(0, 127, 255);
    octree.debug(g, 4.0, otc, otpc);
    
    stroke(255, 255, 0);
    noFill();
    strokeWeight(1);
    pushMatrix();
    translate(range.x, range.y, range.z);
    box(range.w, range.h, range.d);
    popMatrix();
    strokeWeight(6);
    for(Point p : debugQueryPoint){
        point(p.x, p.y, p.z);
    }

    strokeWeight(2);
    stroke(255);
    noFill();
    for(PVector p : tmpPointsList){
        Point pt = new Point(p.x, p.y, p.z);
        
        point(p.x, p.y, p.z);
    }
    popMatrix();

    pt.display(0, 0);
}


void keyPressed() {
    switch(key){
        case 'p' :
        case 'P' :
            pause = !pause;
        break;
    }
}
