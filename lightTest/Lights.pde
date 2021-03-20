import java.lang.Object;

//-----------------------------
//
// lights Component
//
//-----------------------------
/*UPDATE :
 1 - Add material behaviors
 2 - add debuger view 
 */

final static public int LIGHT = 0;
final static public int AMBIENTLIGHT = 1;
final static public int POINTLIGHT = 2;
final static public int DIRECTIONNALLIGHT = 3;
final static public int SPOTLIGHT = 4;

class Light
{

  public int KIND;
  public int type; //0 : fill light, 1 : key light, 2 : rim light, 3 : other 
  public PVector location;

  public float x, y, z, red, green, blue, sred, sgreen, sblue;
  public color rgb;
  public color specular;
  public float fconstant, flinear, fquadratic;

  Light()
  {
    this.initLight(0, new PVector(), color(128, 128, 128), color(0), 1, 0, 0);
  }

  Light(PVector loc_)
  {
    this.initLight(0, loc_, color(128, 128, 128), color(0), 1, 0, 0);
  }

  Light(PVector loc_, color rgb_)
  {
    this.initLight(0, loc_, rgb_, color(0), 1, 0, 0);
  }

  Light(PVector loc_, color rgb_, color specular_)
  {
    this.initLight(0, loc_, rgb_, specular_, 1, 0, 0);
  }

  Light(PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    this.initLight(0, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
  }

  Light(int type_, PVector loc_, color rgb_)
  {
    this.initLight(type_, loc_, rgb_, color(0), 1, 0, 0);
  }

  Light(int type_, PVector loc_, color rgb_, color specular_)
  {
    this.initLight(type_, loc_, rgb_, specular_, 1, 0, 0);
  }

  Light(int type_, PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    this.initLight(type_, loc_, rgb_, specular_, fconstant_, flinear_, fquadratic_);
  }

  private void initLight(int type_, PVector loc_, color rgb_, color specular_, float fconstant_, float flinear_, float fquadratic_)
  {
    this.type = type_;
    this.location = loc_.copy();
    this.rgb = rgb_;
    this.specular = specular_;

    this.x = location.x;
    this.y = location.y;
    this.z = location.z;

    this.red = (rgb >> 16) & 0xFF; 
    this.green = (rgb >> 8) & 0xFF;
    this.blue = rgb & 0xFF; 
    this.sred = (specular >> 16) & 0xFF; 
    this.sgreen = (specular >> 8) & 0xFF;
    this.sblue = specular & 0xFF; 

    this.fconstant = fconstant_;
    this.flinear = flinear_;
    this.fquadratic = fquadratic_;

    this.initKind();
  }

  private void initKind() {
    String className = getClassType();
    if (className.equals("Light")) {
      KIND = LIGHT;
    } else if (className.equals("AmbientLight") ) {
      KIND = AMBIENTLIGHT;
    } else if (className.equals("PointLight")) {
      KIND = POINTLIGHT;
    } else if (className.equals("DirectionLight")) {
      KIND = DIRECTIONNALLIGHT;
    } else if (className.equals("SpotLight")) {
      KIND = SPOTLIGHT;
    }
  }

  //METHODS
  public void displayLight()
  {
    this.displayLight(g);
  }

  public void displayLight(PGraphics buffer)
  {
  }

  private void lights() {
    this.lights(g);
  }

  private void lights(PGraphics buffer) {  
    buffer.ambientLight(this.red, this.green, this.blue); 
    buffer.directionalLight(this.red, this.green, this.blue, 0, 0, -1);
    buffer.lightFalloff( this.fconstant, this.flinear, this.fquadratic);
    buffer.lightSpecular( this.sred, this.sgreen, this.sblue);
  }

  public void showDebugLight()
  {
    this.showDebugLight(g);
  }

  public void showDebugLight(PGraphics buffer)
  {
    buffer.pushStyle();
    buffer.pushMatrix();
    buffer.translate( this.location.x, this.location.y, this.location.z);
    buffer.strokeWeight(10);
    buffer.stroke( this.rgb);
    buffer.point(0, 0, 0);
    buffer.popMatrix();
    buffer.popStyle();
  }

  public void rotateLightAround(PVector target, PVector axis, float angle, float distance)
  {
    PVector nl = PVector.add(target, location);
    PVector newPosition = MathsVector.computeRodrigueRotation(axis, nl, angle);
    newPosition.mult(distance);
    newPosition.add(target);
    this.setPosition(newPosition);
  }

  //set
  public void setPosition(PVector pos_)
  {
    this.location = pos_.copy();
  }

  public void setColor(color rgb_)
  {
    this.rgb = rgb_;
  }

  public void setFallOff(float fconstant_, float flinear_, float fquadratic_)
  {
    this.fconstant = fconstant_;
    this.flinear = flinear_;
    this.fquadratic = fquadratic_;
  }

  //get
  public PVector getLightPosition()
  {
    return  this.location.copy();
  }

  public color getLightColor()
  {
    return  this.rgb;
  }

  public int getLightType()
  {
    return  this.type;
  }

  public float[] getFallOff()
  {
    float[] falloff = {fconstant, flinear, fquadratic};
    return falloff;
  }

  String getClassType() {
    String className = this.getClass().getSimpleName(); 
    return className;
  }
}