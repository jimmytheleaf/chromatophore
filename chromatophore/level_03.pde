
class LevelThree extends BaseScene {

  RGB world_color = new RGB(63, 63, 63, 255);
  Vec2 center = new Vec2(480, 320);
  AudioOutput out;
  SineWave sine;
  Entity fade;
  boolean transitioning_out = false;

  LevelThree(World _w) {
    super(LEVEL_THREE, _w);
  }

  void init() {

      super.init();
      
      this.world.updateClock();
      this.world.stopClock();

      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, 480, 320, 100, world_color);
      PLAYER_UTILS.addMotion(player, 1000, 0, 0, .98f);
      PLAYER_UTILS.addPhysics(player, 1);
      //PLAYER_UTILS.addForceMovement(player, 141.7);
      PLAYER_UTILS.addForceMovement(player, 500);

      Entity mount = setUpSpringMount(world, 480, 320, 10000f);

      SpringSystem springs = (SpringSystem) this.world.getSystem(SPRING_SYSTEM);

      springs.addSpring(mount, player, 0.7, 0.06, 1);

      setUpWalls(this.world, world_color);
      // get a line out from Minim, default bufferSize is 1024, default sample rate is 44100, bit depth is 16
      out = minim.getLineOut(Minim.STEREO);
      // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
      sine = new SineWave(440, 0.5, out.sampleRate());
  
      // set the portamento speed on the oscillator to 200 milliseconds
      sine.portamento(100);
  
      // add the oscillator to the line out
      out.addSignal(sine);
      //out.addSignal(sine2);
      //out.addSignal(sine3);
      out.mute();

      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);



  }


  void draw() {

    this.world.startClock();
 

    background(255, 255, 255);
    super.draw();

    textSize(75);
    
    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 

    }

    if (won) {
      triggerTransition();
    }

    this.world.updateClock();
    this.update(this.world.clock.dt);

  }

  void update(float dt) {

    SpringSystem springs = (SpringSystem) this.world.getSystem(SPRING_SYSTEM);
    springs.update(dt);

    PhysicsSystem physics = (PhysicsSystem) this.world.getSystem(PHYSICS_SYSTEM);
    physics.update(dt);

    super.update(dt);

    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

        CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
        ArrayList<CollisionPair> collisions = collision_system.getCollisions();

        collidePlayerAgainstWalls(collisions, true, this.world_color);

        this.updateWinCondition();

        Entity player = world.getTaggedEntity(TAG_PLAYER);
        ShapeComponent sc = (ShapeComponent) player.getComponent(SHAPE);
        Circle c = (Circle) sc.shape;

        Transform t = (Transform) player.getComponent(TRANSFORM);    
        float distance = t.pos.dist(center);
        c.radius = 100 * (distance / 250);


        if (distance > 10) {
          out.unmute();

          float frequency = 440.0;
          //int interval = int(distance / 25);

          if (distance < 50) {
            frequency *= (6/5.0);
          } else  if (distance < 100) {
            frequency *= (5/4.0);
          } else  if (distance < 150) {
            frequency *= (4/3.0);
          } else  if (distance < 200) {
            frequency *= (3/2.0);
          } else {
            frequency *= 2.0;
          }

          sine.setFreq(frequency);
          //sine2.setFreq(frequency * (5/4)); // Major Third
          // sine3.setFreq(frequency * (3/2)); // Perfect fifth

        } else {
          //out.mute();
        }

    }
   

  }

  void updateWinCondition() {

  }

  boolean checkWinCondition() {
    return world_color.r >  254f;
  }

  void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      addVolumeFader(out, 3, false);
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() {
                                  out.mute();
                                  out.clearSignals();
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
         
    }
  }

}
