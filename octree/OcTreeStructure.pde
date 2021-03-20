class Point{
    float x,y,z;

    Point(float x, float y, float z){
        this.x = x;
        this.y = y;
        this.z = z;
    }
}

class Box{
    float x,y,z,w,h,d;

    Box(float x, float y, float z, float w, float h, float d){
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
        this.h = h;
        this.d = d;
    }

    boolean contains(Point p){
        return (
            p.x > this.x - this.w * 0.5 &&
            p.x < this.x + this.w * 0.5 &&
            p.y > this.y - this.h * 0.5 &&
            p.y < this.y + this.h * 0.5 &&
            p.z > this.z - this.d * 0.5 &&
            p.z < this.z + this.d * 0.5
        );
    }

    boolean intersect(Box range){
        return !(
            range.x - range.w > this.x + this.w ||
            range.x + range.w < this.x - this.w ||
            range.y - range.h > this.y + this.h ||
            range.y + range.h < this.y - this.h ||
            range.z - range.d > this.z + this.d ||
            range.z + range.d < this.z - this.d
        );
    }
}

class OcTree{
    Box aabb;
    int capacity;
    ArrayList<Point> pointList = new ArrayList<Point>();

    OcTree NEF, SEF, SWF, NWF; //Front Octree (NorthEast, SouthEast, SouthWest, NorthWest)
    OcTree NEB, SEB, SWB, NWB; //Front Octree (NorthEast, SouthEast, SouthWest, NorthWest)

    boolean divided;

    OcTree(Box aabb, int capacity){
        this.aabb = aabb;
        this.capacity = capacity;
        this.pointList = new ArrayList<Point>();
    }

    boolean insert(Point point){
        boolean inserted = false;
        if(this.aabb.contains(point)){
            if(pointList.size() < this.capacity){
                pointList.add(point);
                inserted = true;
            }else{
                if(!divided){
                    this.subdivide();
                }

                if(this.NEF.insert(point)){
                    inserted = true;
                }else if(this.SEF.insert(point)){
                    inserted = true;
                }else if(this.SWF.insert(point)){
                    inserted = true;
                }else if(this.NWF.insert(point)){
                    inserted = true;
                }else if(this.NEB.insert(point)){
                    inserted = true;
                }else if(this.SEB.insert(point)){
                    inserted = true;
                }else if(this.SWB.insert(point)){
                    inserted = true;
                }else if(this.NWB.insert(point)){
                    inserted = true;
                }

                if(pointList.size() > this.capacity){
                    println("WARNING:\t"+this.pointList.size()+" is outsitde the edge of "+this.capacity);
                }
            }
        }else{
        }

        return inserted;
    }

    private void subdivide(){
        Box aabbNEF = new Box(this.aabb.x + this.aabb.w * 0.25, this.aabb.y - this.aabb.h * 0.25, this.aabb.z - this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);
        Box aabbSEF = new Box(this.aabb.x + this.aabb.w * 0.25, this.aabb.y + this.aabb.h * 0.25, this.aabb.z - this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);
        Box aabbSWF = new Box(this.aabb.x - this.aabb.w * 0.25, this.aabb.y + this.aabb.h * 0.25, this.aabb.z - this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);
        Box aabbNWF = new Box(this.aabb.x - this.aabb.w * 0.25, this.aabb.y - this.aabb.h * 0.25, this.aabb.z - this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);
        Box aabbNEB = new Box(this.aabb.x + this.aabb.w * 0.25, this.aabb.y - this.aabb.h * 0.25, this.aabb.z + this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);
        Box aabbSEB = new Box(this.aabb.x + this.aabb.w * 0.25, this.aabb.y + this.aabb.h * 0.25, this.aabb.z + this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);
        Box aabbSWB = new Box(this.aabb.x - this.aabb.w * 0.25, this.aabb.y + this.aabb.h * 0.25, this.aabb.z + this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);
        Box aabbNWB = new Box(this.aabb.x - this.aabb.w * 0.25, this.aabb.y - this.aabb.h * 0.25, this.aabb.z + this.aabb.d * 0.25, this.aabb.w * 0.5, this.aabb.h * 0.5, this.aabb.d * 0.5);

        
       this.NEF = new OcTree(aabbNEF, capacity); 
       this.SEF = new OcTree(aabbSEF, capacity);
       this.SWF = new OcTree(aabbSWF, capacity);
       this.NWF = new OcTree(aabbNWF, capacity);
       this.NEB = new OcTree(aabbNEB, capacity);
       this.SEB = new OcTree(aabbSEB, capacity);
       this.SWB = new OcTree(aabbSWB, capacity);
       this.NWB = new OcTree(aabbNWB, capacity);

       this.divided = true;
    }

    ArrayList<Point> query(Box range){
        ArrayList<Point> found = new ArrayList<Point>();
        if(!this.aabb.intersect(range)){
        }else{
            for(Point p : this.pointList){
                if(range.contains(p)){
                    found.add(p);
                }
            }

            if(this.divided){
                found.addAll(this.NEF.query(range));
                found.addAll(this.SEF.query(range));
                found.addAll(this.SWF.query(range));
                found.addAll(this.NWF.query(range));
                found.addAll(this.NEB.query(range));
                found.addAll(this.SEB.query(range));
                found.addAll(this.SWB.query(range));
                found.addAll(this.NWB.query(range));
            }
        }
        return found;
    }

    public void debug(PGraphics ctx, float size, color aabbc, color pc){
        ctx.pushStyle();
        ctx.strokeWeight(1.0);
        ctx.noFill();
        ctx.stroke(aabbc);
        ctx.pushMatrix();
        ctx.translate(this.aabb.x, this.aabb.y, this.aabb.z);
        ctx.box(this.aabb.w, this.aabb.h, this.aabb.d);
        ctx.popMatrix();

        ctx.noFill();
        ctx.stroke(pc);
        ctx.strokeWeight(size);
        for (Point p : pointList) {
            ctx.point(p.x, p.y, p.z);
        }
        ctx.popStyle();
        if(divided){
            this.NEF.debug(ctx, size, aabbc, pc);
            this.SEF.debug(ctx, size, aabbc, pc);
            this.SWF.debug(ctx, size, aabbc, pc);
            this.NWF.debug(ctx, size, aabbc, pc);
            this.NEB.debug(ctx, size, aabbc, pc);
            this.SEB.debug(ctx, size, aabbc, pc);
            this.SWB.debug(ctx, size, aabbc, pc);
            this.NWB.debug(ctx, size, aabbc, pc);
        }
    }
}