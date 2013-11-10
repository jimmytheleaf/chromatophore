
int[] zbc = {147, 176, 205};

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
     int value = int((r(full) + g(full) + b(full)) / 3);
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
      this.value = int((r(full) + g(full) + b(full)) / 3);
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
  
     this.r = int(r(full));
     this.g = int(g(full));
     this.b = int(b(full));
     this.a = int(alpha(full));
  
   }
  
}

class HSB implements IColor {

  int hue;
  int saturation;
  int brightness;
  int alpha;
 
  HSB(int raw) {
    this.setFromRaw(raw);
  }

  HSB(int _hue, int _saturation, int _brightness) {
    this(_hue, _saturation, _brightness, 255);
  }
  
  HSB(int _hue, int _saturation, int _brightness, int _alpha) {
      this.hue = _hue;
      this.saturation = _saturation;
      this.brightness = _brightness;
      this.alpha = _alpha;
  }
  
   // Stay in RGB most of the time
  int toRaw() {
    colorMode(HSB, 360, 100, 100, 255);
    int c = color(this.hue, this.saturation, this.brightness, this.alpha);
    colorMode(RGB, 255, 255, 255, 255);
    return c;
  }
  
  void setFromRaw(int raw) {

      colorMode(HSB, 360, 100, 100, 255);
      this.hue = int(hue(raw));
      this.saturation = int(saturation(raw));
      this.brightness = int(brightness(raw));
      this.alpha = int(alpha(raw));
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
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue + 120 % 360, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue + 240 % 360, hsb.saturation, hsb.brightness));  
    return list;
  }
}



class MonochromeHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue, hsb.saturation + 20 % 100, hsb.brightness));
    list.add(new HSB(hsb.hue, hsb.saturation + 40 % 100, hsb.brightness));
    list.add(new HSB(hsb.hue, hsb.saturation + 60 % 100, hsb.brightness));
    list.add(new HSB(hsb.hue, hsb.saturation + 80 % 100, hsb.brightness)); 
    return list;
  }
}
class AnalagousHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.hue - 40 % 360, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue - 20 % 360, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue + 20 % 360, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue + 40 % 360, hsb.saturation, hsb.brightness));
    return list;  
  }
}

class ShadeHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness));
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness + 20 % 100));
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness + 40 % 100));
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness + 60 % 100));
    list.add(new HSB(hsb.hue, hsb.saturation, hsb.brightness + 80 % 100));
    return list;
  }
}




