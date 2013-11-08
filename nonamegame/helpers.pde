int CAPS_DIFF = 'a' - 'A';

char normalizeInput(char key) {
  
  if (key >= 'a' && key <= 'z') {
   return char(key - CAPS_DIFF);
  }
  
  return key; 
  
}
