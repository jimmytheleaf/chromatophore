class Rectangle {

  int x;
  int y; 
  int width; 
  int height;
  Greyscale c;

  Rectangle(int x, int y, int width, int height, Greyscale _c) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.c = _c;
  }

  void draw() {
    fill(c.toFullColor());
    rect(this.x, this.y, this.width, this.height);
  }

}