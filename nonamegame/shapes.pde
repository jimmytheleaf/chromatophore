
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

}


class Rectangle extends Shape  {

  int width; 
  int height;

  Rectangle(Vec2 pos, int width, int height) {
    super(pos);
    this.width = width;
    this.height = height;
  }
  Rectangle(float x, float y, int width, int height) {
    super(x, y);
    this.width = width;
    this.height = height;
  }

  void draw() {
    fill(this.getColor().toRaw());
    rect(this.pos.x, this.pos.y, this.width, this.height);
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
  
}
