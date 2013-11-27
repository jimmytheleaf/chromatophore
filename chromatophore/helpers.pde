int CAPS_DIFF = 'a' - 'A';

char normalizeInput(char key) {
  
  if (key >= 'a' && key <= 'z') {
   return char(key - CAPS_DIFF);
  }
  
  return key; 
  
}


color getPixel(int x, int y) {
  return pixels[x + y * width]; 
}

int randomint(int min, int max) {
	return int(random(min, max));
}

