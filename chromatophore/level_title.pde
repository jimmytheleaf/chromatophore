


class LevelTitle extends BaseScene {

  float start = 0;
  boolean fadein = false;
  boolean fadeout = false;

  PImage background_image;

  AudioPlayer chimes;
  Entity fade;

  final PixelationManager pixelation_manager = new PixelationManager(500);

  boolean first_draw = true;

  LevelTitle(World _w) {
    super(LEVEL_TITLE, _w);
  }

  void init() {
      super.init();   
      this.world.clock.stop();

      background_image = loadImage("title.png");


      fade = fullScreenFadeBox(world, false);

      
      
  }


  void draw() {

    this.world.clock.start();
    this.world.updateClock();
    this.update(this.world.clock.dt);

    if (first_draw) {

      first_draw = false;

      final TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);

      /* tween_system.addTween(6, new TweenVariable() {
                              public float initial() {           
                                return pixelation_manager.factor; }
                              public void setValue(float value) { 
                                pixelation_manager.factor = int(value); 
                              }  
                          }, 500, EasingFunctions.inCubic);
      */

      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);


      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                   tween_system.addTween(8, new TweenVariable() {
                                      public float initial() {           
                                        return pixelation_manager.factor; }
                                      public void setValue(float value) { 
                                        pixelation_manager.factor = int(value); 
                                      }  
                                   }, 4, EasingFunctions.outCubic);
                                }
                              }, 3);

  
       
     schedule_system.doAfter(new ScheduleEntry() {   
                                public void run() { 
                                  addFadeEffect(fade, 2, false);
                                  printDebug("Running fade out effect");

                                }
                              }, 9);
      

      final LevelGateway gwy = gateway;
      schedule_system.doAfter(new ScheduleEntry() { public void run() {  world.scene_manager.setCurrentScene(gwy); } } , 11);

    }

    background(63, 63, 63);
    image(background_image, 0, 0);

    textSize(75);    
    // fill(zbc[2], zbc[1], zbc[0], 255);

    //if (this.world.clock.)
    fill(255, 255, 255, 255);
    text("Chromatophore", 40, 140);

    textSize(30);
    text("by Jim Fingal", 80, 240);

    super.draw();

    renderPixelation(pixelation_manager.factor);


  }

  void renderPixelation(int pixelation_factor) {

    rectMode(CORNER);

    int x = 0;
    int square_width = width / pixelation_factor;

    if (pixelation_factor <  width / 3 ) {

      loadPixels();
      for (int i = 0; i < pixelation_factor; i++) {

        x = i * square_width;

        for (int y = 0; y < height; y += square_width) {

          color this_color = getPixel(x, y);
          fill(this_color);
          rect(x, y, square_width, square_width);

        }
        
      }


    }

  }


  void update(float dt) {
    super.update(dt);
  }

}


class PixelationManager {
  Integer factor;
  PixelationManager(int factor) {
    this.factor = factor;
  }
}
