float r(int rgb) {
  return rgb >> 16 & 0xFF;
}
float g(int rgb) {
  return rgb >> 8 & 0xFF;
}
float b(int rgb) {
  return rgb & 0xFF;
}

interface IColor {  
  
   int toFullColor();
   void setFromFullColor(int full);
}

class Greyscale implements IColor {
 
   int value;
   
   Greyscale(int value) {
      this.value = constrain(value, 0, 255);
   }
  
   int toFullColor() {
     return color(this.value, this.value, this.value);
   }
   
   void setFromFullColor(int full) {
     
      // Average RGB values
      this.value = int((r(full) + g(full) + b(full)) / 3);
 
   }
  
}


class FullColor implements IColor {
 
   int r;
   int g;
   int b; 
   
   FullColor(int r, int g, int b) {
   
      this.r = constrain(r, 0, 255);
      this.g = constrain(g, 0, 255);
      this.b = constrain(b, 0, 255);
   }
  
   int toFullColor() {
     return color(this.r, this.g, this.b);
   }
   
   void setFromFullColor(int full) {
  
     this.r = int(r(full));
     this.g = int(g(full));
     this.b = int(b(full));
  
   }
  
}
