
abstract class Shape implements Drawable, Collidable {

  final Vec2 pos;
  IColor clr;

  // When called with this, we get a final reference pointing
  // to some other vector. Allows us to e.g. have the shape track 
  // a transform's position.
  Shape(Vec2 _position) {
    this.pos = _position;
  }

  Shape(float x, float y) {
    this.pos = new Vec2(x, y);
  }

  Shape setColor(IColor _c) {
    this.clr = _c;
    return this;
  }
  
  IColor getColor() {
    return this.clr;
  }

  public abstract void draw();
  public abstract void drawAroundOrigin();
  public abstract Vec2 centerPosition();

  // public abstract boolean collidesWith(Collidable collidable)

}

class Point extends Shape {

  Point(float x, float y) {
    super(x, y);
  }

  Point(Vec2 _position) {
    super(_position);
  }

  void draw() {
    fill(this.getColor().toRaw());
    point(this.pos.x, this.pos.y);
  }

  void drawAroundOrigin() {
    fill(this.getColor().toRaw());
    point(0, 0);
  }

  String toString() {
      return "Point: (" + this.pos.x + ", " + this.pos.y + ")";
  }

  Vec2 centerPosition() {
    return this.pos;
  }

}


class Rectangle extends Shape  {

  int width; 
  int height;
  private Vec2 center_vec;

  Rectangle(Vec2 pos, int width, int height) {
    super(pos);
    this.width = width;
    this.height = height;
    this.center_vec = new Vec2(pos.x + this.width/2, pos.y + this.height/2);
  }
  Rectangle(float x, float y, int width, int height) {
    super(x, y);
    this.width = width;
    this.height = height;
  }

  void draw() {
    rectMode(CORNER);
    fill(this.getColor().toRaw());
    rect(this.pos.x, this.pos.y, this.width, this.height);
  }

  void drawAroundOrigin() {
    rectMode(CENTER);
    fill(this.getColor().toRaw());
    rect(0, 0, this.width, this.height);
  }


  String toString() {
      return "Rectangle: (" + this.pos.x + ", " + this.pos.y + ", w=" + this.width + " h=" + this.height + ")";
  }

  // Keep one object, recalculate whenever called
  Vec2 centerPosition() {
    this.center_vec.x = this.pos.x + this.width/2;
    this.center_vec.y = this.pos.y + this.height/2;
    return this.center_vec;
  }

}

class Circle extends Shape {

  float radius;

  Circle(float x, float y, float radius) {
    super(x, y);
    this.radius = radius;
  }
  
  Circle(Vec2 pos, float radius) {
    super(pos);
    this.radius = radius;
  }

  void draw() {
    fill(this.getColor().toRaw());
    ellipse(this.pos.x, this.pos.y, this.radius * 2, this.radius * 2);
  }

  void drawAroundOrigin() {
    fill(this.getColor().toRaw());
    ellipse(0, 0, this.radius * 2, this.radius * 2);
  }

   Vec2 centerPosition() {
    return this.pos;
  }

  String toString() {
      return "Circle: (" + this.pos.x + ", " + this.pos.y + ", r= " + this.radius + ")";
  }
  
}





class TextBox extends Rectangle  {

 String content;
 int size;

TextBox(Vec2 pos, int width, int height, String content, int size) {
    super(pos, width, height);
    this.content = content;
    this.size = size;
  }

  void draw() {
    textSize(this.size);    
    fill(this.getColor().toRaw());
    text(this.content, this.pos.x, this.pos.y, this.width, this.height); 
  }

  void drawAroundOrigin() {
    rectMode(CENTER);
    textSize(this.size);    
    fill(this.getColor().toRaw());
    text(this.content, 0, 0, this.width, this.height); 
  }


  String toString() {
      return "Text: (" + this.pos.x + ", " + this.pos.y + ", w=" + this.width + " h=" + this.height + ", text=" + this.content + ", size=" + this.size + " color=" + this.getColor() + ")";
  }


}
