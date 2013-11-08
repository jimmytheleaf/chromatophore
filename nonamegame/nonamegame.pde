
int x = 1;
int y = 1;

float max_x;
float max_y;

int square_size = 160;
int divisor = 1;

int width = 960;
int height = 640;

World world;

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
    println(c.alpha);
  }

}

Rectangle this_rectangle = new Rectangle(0, 0, 960, 640, new Greyscale(0));

void setup() 
{

  size(960, 640);
  runTests();

  world = new World(960, 640);

  TweenSystem tween_system = new TweenSystem();

  world.setSystem(tween_system);

  tween_system.addTween(3, new TweenVariable() {
                              public float initial() { return this_rectangle.c.alpha; }
                              public void setValue(float value) { this_rectangle.c.alpha = value; }  
                          }, 1.0, EasingFunctions.linear);

}

void draw() 
{
  world.updateClock();

  TweenSystem tween_system = (TweenSystem) world.getSystem("TweenSystem");
  tween_system.update(world.clock.dt);


  background(63, 63, 63);

  
  constrain(divisor, 1, 10);  
  divisor = constrain(divisor, 1, 10);  
  float unit_length = square_size / divisor;

  max_x = width / unit_length;
  max_y = height / unit_length;
    
  x = constrain(x, 0, int(max_x - 1));
  y = constrain(y, 0, int(max_y - 1));
  
  fill (70, 70, 70);
  
  for (int i = 0; i < width; i += unit_length) {
    
    for (int j = 0; j < height; j += unit_length) {
    
      if (i == 0 && j > 0) {
        line(0,j,width,j);
        
      } else if (j == 0 && i > 0) {
        
        line(i,0,i,height);

      }
      
    }
  
  }
  
  fill(zbc[0], zbc[1], zbc[2]);

  // Player
  rect(x * unit_length, y * unit_length, unit_length, unit_length);
  
  this_rectangle.draw();


  /*
  if (mouseX != lastMouseX) {
    println(mouseX);
    lastMouseX = mouseX;
  }
  if (mouseY != lastMouseX) {
    println(mouseY);
    lastMouseX = mouseY;
  }
  */
  

}

void keyPressed() {
  
  key = normalizeInput(key);
  println(key);

  // TODO: http://processing.org/reference/keyCode.html
  if (key == INPUT_UP) {
    y--;
  } else if (key == INPUT_DOWN) {
    y++;
  } else if (key == INPUT_LEFT) {
    x--;
  } else if (key == INPUT_RIGHT) {
    x++;
  }
  
  if (key == 'I') {
    divisor++;
  } else if (key == 'K') {
    divisor--;
  }
  
}
  
