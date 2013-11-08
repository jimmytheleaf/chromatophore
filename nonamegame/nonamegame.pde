float[] zbc = {147, 176, 205};

int x = 1;
int y = 1;

boolean z = false;

float max_x;
float max_y;

int square_size = 160;
int divisor = 1;

int width = 960;
int height = 640;

int lastMouseX;
int lastMouseY;

void setup() 
{

  size(960, 640, P3D);
  background(63, 63, 63);
  lastMouseX = 0;
  lastMouseY = 0;
}

void draw() 
{
  
  background(63, 63, 63);
  constrain(divisor, 1, 10);  
  divisor = constrain(divisor, 1, 10);  
  float unit_length = square_size / divisor;

  max_x = width / unit_length;
  max_y = height / unit_length;
    
  x = constrain(x, 0, int(max_x - 1));
  y = constrain(y, 0, int(max_y - 1));
  
  fill (70, 70, 70);
  
  if (z) {
    
/*
    for (int i = 0; i < width; i += unit_length) {
    
      for (int j = 0; j < height; j += unit_length) {
      
        for (int k = 0; k < height; k += unit_length) {
          
          pushMatrix();
          noFill();

          translate(j * unit_length, k * unit_length);
          box(unit_length, unit_length, unit_length);
          popMatrix();

        }      
    }
    }
  */
  
    pushMatrix();
    fill(zbc[0], zbc[1], zbc[2]);
    noFill();
    scale(0.5);
    translate(width/2, height / 2);
    translate(x * unit_length, y * unit_length);
    box(unit_length);
    popMatrix();
  
  } else {
  
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

  }

  char biga = 'A';
  char littlea = 'a';
  int diff = 'a' - 'A';
  text(biga, 100, 100);
  text(littlea, 100, 200);
  text(char(biga + diff), 100, 300);
  
  if (mouseX != lastMouseX) {
    println(mouseX);
    lastMouseX = mouseX;
  }
  if (mouseY != lastMouseX) {
    println(mouseY);
    lastMouseX = mouseY;
  }
  

}

void keyPressed() {
  println(key);
  println();
  
  key = normalizeInput(key);
  
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
  
  if (key == 'Z') {
    z = !z;
  }

  print(max_x);
  print(max_y);
  
}
  
