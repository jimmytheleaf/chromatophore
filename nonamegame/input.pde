
char INPUT_UP = 'W';
char INPUT_DOWN = 'S';
char INPUT_LEFT = 'A';
char INPUT_RIGHT = 'D';

int diff = 'a' - 'A';

char normalizeInput(char key) {
  
  if (key >= 'a' && key <= 'z') {
   return char(key - diff);
  }
  
  return key; 
  
}
