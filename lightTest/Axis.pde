class Axis3D
{
  private PVector origin;
  private PVector axis;
  private float axisLength;
  private float phi = 0;

  Axis3D()
  {
    this.initAxis3D(new PVector(0, 0, 0), new PVector(1, 1, 1), 10);
  }

  Axis3D(float axisLength_)
  {
    this.initAxis3D(new PVector(0, 0, 0), new PVector(1, 1, 1), axisLength_);
  }

  Axis3D(PVector origin_)
  {
    this.initAxis3D(origin_, new PVector(1, 1, 1), 10);
  }

  Axis3D(PVector origin_, float axisLength_)
  {
    this.initAxis3D(origin_, new PVector(1, 1, 1), axisLength_);
  }

  Axis3D(PVector origin_, PVector axis_)
  {
    this.initAxis3D(origin_, axis_, 10);
  }

  Axis3D(PVector origin_, PVector axis_, float axisLength_)
  {
    this.initAxis3D(origin_, axis_, axisLength_);
  }


  private void initAxis3D(PVector origin_, PVector axis_, float axisLength_)
  {
    origin = origin_.copy();
    axis = axis_.copy();
    axisLength = axisLength_;
  }

  public void drawAxis(String colorMode)
  {
    color xAxis = color(255, 0, 0);
    color yAxis = color(0, 255, 0);
    color zAxis = color(0, 0, 255);

    if (colorMode == "rvb" || colorMode == "RVB")
    {
      xAxis = color(255, 0, 0);
      yAxis = color(0, 255, 0);
      zAxis = color(0, 0, 255);
    } else if (colorMode == "hsb" || colorMode == "HSB")
    {
      xAxis = color(0, 100, 100);
      yAxis = color(115, 100, 100);
      zAxis = color(215, 100, 100);
    }

    pushStyle();
    pushMatrix();
    translate(origin.x, origin.y, origin.z);
    rotate(phi, axis.x, axis.y, axis.z);
    strokeWeight(1);
    //x-axis
    stroke(xAxis); 
    line(0, 0, 0, axisLength, 0, 0);
    //y-axis
    stroke(yAxis); 
    line(0, 0, 0, 0, axisLength, 0);
    //z-axis
    stroke(zAxis); 
    line(0, 0, 0, 0, 0, axisLength);
    popMatrix();
    popStyle();
  }

  public void drawAxis(String colorMode, PGraphics buffer)
  {
    color xAxis = color(255, 0, 0);
    color yAxis = color(0, 255, 0);
    color zAxis = color(0, 0, 255);

    if (colorMode == "rvb" || colorMode == "RVB")
    {
      xAxis = color(255, 0, 0);
      yAxis = color(0, 255, 0);
      zAxis = color(0, 0, 255);
    } else if (colorMode == "hsb" || colorMode == "HSB")
    {
      xAxis = color(0, 100, 100);
      yAxis = color(115, 100, 100);
      zAxis = color(215, 100, 100);
    }

    buffer.pushStyle();
    buffer.pushMatrix();
    buffer.translate(origin.x, origin.y, origin.z);
    buffer.rotate(phi, axis.x, axis.y, axis.z);
    buffer.strokeWeight(1);
    //x-axis
    buffer.stroke(xAxis); 
    buffer.line(0, 0, 0, axisLength, 0, 0);
    //y-axis
    buffer.stroke(yAxis); 
    buffer.line(0, 0, 0, 0, axisLength, 0);
    //z-axis
    buffer.stroke(zAxis); 
    buffer.line(0, 0, 0, 0, 0, axisLength);
    buffer.popMatrix();
    buffer.popStyle();
  }

  public void updateAxis(PVector eye, PVector target)
  {
    PVector v0tov1 = PVector.sub(target, eye);

    //compute angle between two vectors
    PVector v0 = new PVector(0, 1, 0);
    PVector v1 = v0tov1.copy().normalize();

    float v0Dotv1 = PVector.dot(v0, v1);
    float phi_ = acos(v0Dotv1);
    PVector axis_ = v0.cross(v1);

    origin = eye.copy();
    axis = axis_;
    phi = phi_;
  }
}