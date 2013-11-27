
class LevelCredits extends BaseScene {

  Entity fade;


  LevelCredits(World _w) {
    super("Final", _w);
  }

  void init() {

      super.init();   
      this.world.clock.stop();

      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 6, true);
  }


  void draw() {

    this.world.clock.start();
    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(0, 0, 0);
    fill(48, 166, 109, 200);
    rect(LEFT_X, TOP_Y, 600, 600);


    textAlign(CENTER);
    textSize(75);    
    fill(203, 203, 203, 255);
    text("Chromatophore", 0, TOP_Y, width, height);
    textSize(30);
    text("by Jim Fingal", 0, BOTTOM_Y - 75, width, height);

    super.draw();
  }


  void update(float dt) {
    super.update(dt);
  }

}
