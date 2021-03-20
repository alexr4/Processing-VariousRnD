class AmbientLight extends Light
{
  AmbientLight()
  {
    super();
  }
  AmbientLight(color rgb_)
  {
    super(0, new PVector(), rgb_, color(0), 1, 0, 0);
  }
  
  AmbientLight(color rgb_, color spec_)
  {
    super(0, new PVector(), rgb_, spec_, 1, 0, 0);
  }
  
  AmbientLight(color rgb_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, new PVector(), rgb_, color(0), fconstant_, flinear_, fquadratic_);
  }
  
  AmbientLight(color rgb_, color spec_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, new PVector(), rgb_, spec_, fconstant_, flinear_, fquadratic_);
  }

  @Override public void displayLight(PGraphics buffer)
  {
    buffer.lightFalloff(this.fconstant, this.flinear, this.fquadratic);
    buffer.ambientLight(this.red, this.green, this.blue);
    buffer.lightSpecular(this.sred, this.sgreen, this.sblue);
  }
}

class PointLight extends Light
{
  PointLight()
  {
    super();
  }

  PointLight(PVector loc_)
  {
    super(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
  }

  PointLight(PVector loc_, color rgb_)
  {
    super(0, loc_, rgb_, color(0), 1, 0, 0);
  }

  PointLight(PVector loc_, color rgb_, color specular_)
  {
    super(0, loc_, rgb_, specular_, 1, 0, 0);
  }

  PointLight(PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
  }

  PointLight(int type_, PVector loc_, color rgb_)
  {
    super(type_, loc_, rgb_, color(0), 1, 0, 0);
  }

  PointLight(int type_, PVector loc_, color rgb_, color specular_)
  {
    super(type_, loc_, rgb_, specular_, 1, 0, 0);
  }

  PointLight(int type_, PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
  }

  @Override public void displayLight(PGraphics buffer)
  {
    buffer.lightFalloff(this.fconstant, this.flinear, this.fquadratic);
    buffer.pointLight(this.red, this.green, this.blue, this.location.x, this.location.y, this.location.z);
    buffer.lightSpecular(this.sred, this.sgreen, this.sblue);
  }

  public void setFallOff(float fconstant_, float flinear_, float fquadratic_)
  {
    this.fconstant = fconstant_;
    this.flinear = flinear_;
    this.fquadratic = fquadratic_;
  }

  public float[] getFallOff()
  {
    float[] falloff = {fconstant, flinear, fquadratic};
    return falloff;
  }
}

class DirectionLight extends Light
{
  private PVector debugLine;
  private float debugLineLength;
  private PVector skyPosition;
  private float skyDistance;

  DirectionLight()
  {
    super(0, new PVector(0, 0, -1), color(128, 128, 128), color(0), 1, 0, 0);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(float skyDistance_)
  {
    super(0, new PVector(0, 0, -1), color(128, 128, 128), color(0), 1, 0, 0);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_)
  {
    super(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, float skyDistance_)
  {
    super(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }


  DirectionLight(color rgb_)
  {
    super(0, new PVector(0, 0, -1), rgb_, color(0), 1, 0, 0);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, color rgb_)
  {
    super(0, loc_, rgb_, color(0), 1, 0, 0);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, color rgb_, float skyDistance_)
  {
    super(0, loc_, rgb_, color(0), 1, 0, 0);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }



  DirectionLight(color rgb_, float skyDistance_)
  {
    super(0, new PVector(0, 0, -1), rgb_, color(0), 1, 0, 0);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, color rgb_, color specular_)
  {
    super(0, loc_, rgb_, specular_, 1, 0, 0);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, color rgb_, color specular_, float skyDistance_)
  {
    super(0, loc_, rgb_, specular_, 1, 0, 0);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_, float skyDistance_)
  {
    super(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(int type_, PVector loc_, color rgb_, float skyDistance_)
  {
    super(type_, loc_, rgb_, color(0), 1, 0, 0);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(int type_, PVector loc_, color rgb_)
  {
    super(type_, loc_, rgb_, color(0), 1, 0, 0);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }


  DirectionLight(int type_, PVector loc_, color rgb_, color specular_)
  {
    super(type_, loc_, rgb_, specular_, 1, 0, 0);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(int type_, PVector loc_, color rgb_, color specular_, float skyDistance_)
  {
    super(type_, loc_, rgb_, specular_, 1, 0, 0);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(int type_, PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(int type_, PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_, float skyDistance_)
  {
    super(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  private void initSkyPosition(float skyDistance_)
  {
    this.skyPosition = this.location.copy();
    this.skyDistance = skyDistance_;
    this.skyPosition.mult(this.skyDistance * -1);
  }

  private void initDebugLine()
  {
    this.debugLine = this.location.copy();
    this.debugLineLength = 25;
    this.debugLine.mult(this.debugLineLength);
  }

  @Override public void displayLight(PGraphics buffer)
  {
    buffer.directionalLight(this.red, this.green, this.blue, this.location.x, this.location.y, this.location.z);
    buffer.lightSpecular(this.sred, this.sgreen, this.sblue);
  }


  @Override public void showDebugLight(PGraphics buffer)
  {
    showDebugLight(buffer, 0, 0, 0);
  }

  public void showDebugLight(float x, float y, float z)
  {
    showDebugLight(g, x, y, z);
  }

  public void showDebugLight(PGraphics buffer, float x, float y, float z) {
    buffer.pushStyle();
    buffer.strokeWeight(10);
    buffer.stroke(this.red, this.green, this.blue);
    buffer.point(x, y, z);
    buffer.strokeWeight(1);
    buffer.line(x, y, z, x + this.debugLine.x, y + this.debugLine.y, z + this.debugLine.z);
    buffer.popStyle();
  }

  public void showLightFromSkyPosition() {
    showLightFromSkyPosition(g, 0, 0, 0);
  }

  public void showLightFromSkyPosition(float x, float y, float z) {
    showLightFromSkyPosition(g, x, y, z);
  }

  public void showLightFromSkyPosition(PGraphics buffer) {
    showLightFromSkyPosition(buffer, 0, 0, 0);
  }

  public void showLightFromSkyPosition(PGraphics buffer, float x, float y, float z) {
    buffer.stroke(this.red, this.green, this.blue);
    buffer.line(x, y, z, this.skyPosition.x, this.skyPosition.y, this.skyPosition.z);
  }

  public void rotateLightAround(PVector axis, float angle)
  {
    PVector nl = PVector.add(new PVector(), location);
    PVector newPosition = MathsVector.computeRodrigueRotation(axis, nl, angle);
    super.setPosition(newPosition);
    this.initSkyPosition(this.skyDistance);
    this.initDebugLine();
  }

  public void setSkyPosition(PVector sk)
  {
    skyPosition = sk.copy();
  }

  public void setNewAxis(PVector l)
  {    
    super.initLight(type, l, color(this.red, this.green, this.blue), color(this.sred, this.sgreen, this.sblue), 1, 0, 0);
    this.initSkyPosition(skyDistance);
    this.initDebugLine();
  }

  public PVector getSkyPosition()
  {
    return skyPosition;
  }
}

class SpotLight extends Light
{
  public PVector dir;
  public float theta;
  public float coeff;

  SpotLight()
  {
    super(0, new PVector(0, 0, 50), color(128, 128, 128), color(0), 1, 0, 0);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }

  SpotLight(PVector loc_)
  {
    super(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }
    
  SpotLight(PVector loc_, PVector dir_)
  {
    super(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
    initSpot(dir_, radians(60), 600);
  }
  
  SpotLight(PVector loc_, PVector dir_, float theta_)
  {
    super(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
    initSpot(dir_, theta_, 600);
  }
  
  SpotLight(PVector loc_, PVector dir_, float theta_, float coeff_)
  {
    super(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
    initSpot(dir_, theta_, coeff_);
  }

  SpotLight(PVector loc_, color rgb_)
  {
    super(0, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }

  SpotLight(PVector loc_, PVector dir_, color rgb_)
  {
    super(0, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(dir_, radians(60), 600);
  }

  SpotLight(PVector loc_, PVector dir_, float theta_, color rgb_)
  {
    super(0, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(dir_, theta_, 600);
  }

  SpotLight(PVector loc_, PVector dir_, float theta_, float coeff_, color rgb_)
  {
    super(0, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(dir_, theta_, coeff_);
  }

  SpotLight(PVector loc_, color rgb_, color specular_)
  {
    super(0, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }
  
  SpotLight(PVector loc_, PVector dir_, color rgb_, color specular_)
  {
    super(0, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(dir_, radians(60), 600);
  }
  
  SpotLight(PVector loc_, PVector dir_, float theta_, color rgb_, color specular_)
  {
    super(0, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(dir_, theta_, 600);
  }
  
  SpotLight(PVector loc_, PVector dir_, float theta_, float coeff_, color rgb_, color specular_)
  {
    super(0, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(dir_, theta_, coeff_);
  }

  SpotLight(PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }

  SpotLight(PVector loc_, color rgb_, PVector dir_,color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(dir_, radians(60), 600);
  }

  SpotLight(PVector loc_, color rgb_, PVector dir_, float theta_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(dir_, theta_, 600);
  }

  SpotLight(PVector loc_, color rgb_, PVector dir_, float theta_, float coeff_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(dir_, theta_, coeff_);
  }

  SpotLight(int type_, PVector loc_, color rgb_)
  {
    super(type_, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }

  SpotLight(int type_, PVector loc_, PVector dir_, color rgb_)
  {
    super(type_, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(dir_, radians(60), 600);
  }

  SpotLight(int type_, PVector loc_, PVector dir_, float theta_, color rgb_)
  {
    super(type_, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(dir_, theta_, 600);
  }

  SpotLight(int type_, PVector loc_, PVector dir_, float theta_, float coeff_, color rgb_)
  {
    super(type_, loc_, rgb_, color(0), 1, 0, 0);
    initSpot(dir_, theta_, coeff_);
  }


  SpotLight(int type_, PVector loc_, color rgb_, color specular_)
  {
    super(type_, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }
  
  SpotLight(int type_, PVector loc_, PVector dir_, color rgb_, color specular_)
  {
    super(type_, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(dir_, radians(60), 600);
  }
  
  SpotLight(int type_, PVector loc_, PVector dir_, float theta_, color rgb_, color specular_)
  {
    super(type_, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(dir_, theta_, 600);
  }
  
  SpotLight(int type_, PVector loc_, PVector dir_, float theta_, float coeff, color rgb_, color specular_)
  {
    super(type_, loc_, rgb_, specular_, 1, 0, 0);
    initSpot(dir_, theta_, coeff);
  }

  SpotLight(int type_, PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(new PVector(0, 0, -1), radians(60), 600);
  }

  SpotLight(int type_, PVector loc_, PVector dir_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(dir_, radians(60), 600);
  }

  SpotLight(int type_, PVector loc_, PVector dir_, float theta_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(dir_, theta_, 600);
  }

  SpotLight(int type_, PVector loc_, PVector dir_, float theta_, float coeff_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    super(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
    initSpot(dir_, theta_, coeff_);
  }

  private void initSpot(PVector dir_, float theta_, float coeff_) {
    this.dir = dir_.copy();
    this.theta = theta_;
    this.coeff = coeff_;
    println(dir, theta, coeff, degrees(theta));
  }

  //METHODS
  @Override public void displayLight(PGraphics buffer)
  {
    buffer.lightFalloff(this.fconstant, this.flinear, this.fquadratic);
    buffer.spotLight(this.red, this.green, this.blue, this.location.x, this.location.y, this.location.z, this.dir.x, this.dir.y, this.dir.z, this.theta, 0.0);//this.coeff);
    buffer.lightSpecular(this.sred, this.sgreen, this.sblue);
  }

  @Override public void showDebugLight(PGraphics buffer)
  {
    buffer.pushStyle();
    buffer.pushMatrix();
    buffer.translate( this.location.x, this.location.y, this.location.z);
    buffer.strokeWeight(10);
    buffer.stroke( this.rgb);
    buffer.point(0, 0, 0);
    buffer.strokeWeight(1);
    buffer.line(0, 0, 0, -dir.x * 25, -dir.y * 25, -dir.z * 25);
    buffer.popMatrix();
    buffer.popStyle();
  }
}