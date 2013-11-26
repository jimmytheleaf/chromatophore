
class LevelTitle extends BaseScene {

  float start = 0;
  boolean fadein = false;
  boolean fadeout = false;

  AudioPlayer chimes;
  Entity fade;


  LevelTitle(World _w) {
    super(LEVEL_TITLE, _w);
  }

  void init() {
      super.init();   
      this.world.clock.stop();

      fade = fullScreenFadeBox(world, true);

      chimes = audio_manager.getSound(SOUND_CHIMES);
      chimes.loop();
      chimes.play();
      chimes.setGain(-60); // Java
      chimes.setVolume(0); // Javascript
      addVolumeFader(chimes, 4.5, true);

      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { addFadeEffect(fade, 3, true); 
                                    printDebug("Running fade in effect");
                                }
                              }, 1.5);
      schedule_system.doAfter(new ScheduleEntry() {   
                                public void run() { 
                                  addFadeEffect(fade, 5, false);
                                  addVolumeFader(chimes, 5, false);
                                    printDebug("Running fade in effect");

                                }
                              }, 10);

      final LevelGateway gwy = gateway;
      schedule_system.doAfter(new ScheduleEntry() { public void run() {  world.scene_manager.setCurrentScene(gwy); } } , 15);

  }


  void draw() {

    this.world.clock.start();
    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(63, 63, 63);

    textSize(75);    
    fill(zbc[2], zbc[1], zbc[0], 255);
    text("Chromatophore", 40, 240);

    textSize(30);
    text("by Jim Fingal", 80, 340);

    super.draw();
  }


  void update(float dt) {
    super.update(dt);
  }

}
