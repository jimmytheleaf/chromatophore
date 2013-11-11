
int[] zbc = {147, 176, 205};

float bitwiseR(int rgb) {
  return rgb >> 16 & 0xFF;
}

float bitwiseG(int rgb) {
  return rgb >> 8 & 0xFF;
}

float bitwiseB(int rgb) {
  return rgb & 0xFF;
}


interface IColor {  
  
   int toRaw();
   void setFromRaw(int full);
}

class TwoTone implements IColor {
  
  boolean on;
  
  TwoTone(boolean on) {
     this.on = on; 
  }
   int toRaw() {
     if (on) {
       return color(255);
     } else {
       return color(0);
     }
   }
   
   void setFromRaw(int full) {
     int value = int((bitwiseR(full) + bitwiseG(full) + bitwiseB(full)) / 3);
     if (value > 128) {
       this.on = true;
     } else {
       this.on = false;
     } 
   }

}


class Greyscale implements IColor {
 
   int value;
   float alpha;
   
   Greyscale(int value) {
      this.value = constrain(value, 0, 255);
      this.alpha = 255;
   }
  
   int toRaw() {
     return color(this.value, this.value, this.value, this.alpha);
   }
   
   void setFromRaw(int full) {
     
      // Average RGB values
      this.value = int((bitwiseR(full) + bitwiseG(full) + bitwiseB(full)) / 3);
      this.alpha = alpha(full);
 
   }
  
}


class RGB implements IColor {
 
   int r;
   int g;
   int b;
   int a; 
   
  RGB(int raw) {
    this.setFromRaw(raw);
  }

   RGB(int r, int g, int b, int a) {
   
      this.r = constrain(r, 0, 255);
      this.g = constrain(g, 0, 255);
      this.b = constrain(b, 0, 255);
      this.a = constrain(a, 0, 255);

   }
  
   int toRaw() {
     return color(this.r, this.g, this.b, this.a);
   }
   
   void setFromRaw(int full) {
  
     this.r = int(bitwiseR(full));
     this.g = int(bitwiseG(full));
     this.b = int(bitwiseB(full));
     this.a = int(alpha(full));
  
   }
  
}

class HSB implements IColor {

  int h;
  int s;
  int b;
  int a;
 
  HSB(int raw) {
    this.h = 0;
    this.s = 0;
    this.b = 0;
    this.a = 0;

    this.setFromRaw(raw);
  }

  HSB(int _hue, int _saturation, int _brightness) {
    this(_hue, _saturation, _brightness, 255);
  }
  
  HSB(int _hue, int _saturation, int _brightness, int _alpha) {
      this.h = _hue;
      this.s = _saturation;
      this.b = _brightness;
      this.a = _alpha;
  }
  
   // Stay in RGB most of the time
  int toRaw() {
    colorMode(HSB, 360, 100, 100, 255);
    int c = color(this.h, this.s, this.b, this.a);
    colorMode(RGB, 255, 255, 255, 255);
    return c;
  }
  
  void setFromRaw(int raw) {

      colorMode(HSB, 360, 100, 100, 255);
      this.h = int(hue(raw));
      this.s = int(saturation(raw));
      this.b = int(brightness(raw));
      this.a = int(alpha(raw));
      colorMode(RGB, 255, 255, 255, 255);
  }
  
}




interface Harmony {
  ArrayList<IColor> generate(IColor clr);
}

class IdentityHarmony implements Harmony {


  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>(); 
    HSB hsb = new HSB(clr.toRaw());
    list.add(hsb);
    return list;
  }
}

class TriadHarmony implements Harmony {

  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>(); 
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 120 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 240 % 360, hsb.s, hsb.b));  
    return list;
  }
}



class MonochromeHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 20 % 100, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 40 % 100, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 60 % 100, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 80 % 100, hsb.b)); 
    return list;
  }
}
class AnalagousHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h - 40 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h - 20 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 20 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 40 % 360, hsb.s, hsb.b));
    return list;  
  }
}

class ShadeHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 20 % 100));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 40 % 100));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 60 % 100));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 80 % 100));
    return list;
  }
}
