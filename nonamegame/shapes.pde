
class Shape {

  Vec2 pos;

  Shape(Vec2 _position) {
    this.pos = _position;
  }

  Shape(float x, float y) {
    this.pos = new Vec2(x, y);
  }

}



class Rectangle extends Shape {

  int width; 
  int height;
  Greyscale c;

  Rectangle(float x, float y, int width, int height, Greyscale _c) {
    super(x, y);
    this.width = width;
    this.height = height;
    this.c = _c;
  }

  void draw() {
    fill(c.toFullColor());
    rect(this.pos.x, this.pos.y, this.width, this.height);
  }

}
