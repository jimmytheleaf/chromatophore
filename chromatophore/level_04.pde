
class LevelFour extends BaseScene {

  int corners_touched;
  RGB player_color = new RGB(0, 0, 255, 255);
  RGB wall_color = new RGB(255, 0, 0, 255);

  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);
  RGB color_white = new RGB(255, 255, 255, 255);

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();


  AudioPlayer pu1;
  AudioPlayer pu2;

  Entity fade;
  boolean transitioning_out = false;


  LevelFour(World _w) {
    super(LEVEL_FOUR, _w);
    corners_touched = 0;
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, int(center.x), int(center.y), 20, player_color);
      PLAYER_UTILS.addMotion(player, 500, 0, 0, .05);
      PLAYER_UTILS.addSpaceshipMovement(player, 100);

      setUpCollectables(world, 25, color_green);
      setUpCollectables(world, 25, color_blue);

      setUpWalls(this.world, wall_color);
      background(255, 255, 255);

      pu1 = audio_manager.getSound(SOUND_L4PU1);
      pu2 = audio_manager.getSound(SOUND_L4PU2);
  }


  void draw() {

   
    super.draw();

    textSize(75);
    
    //fill(255, 255, 255, 255);

    if (checkWinCondition()) {

      // fill(0, 0, 0, 255);
      //text("THE WINNER IS YOU", 40, 340); 
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

    super.update(dt);


    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      collidePlayerAgainstWalls(collisions, false);
      collidePlayerAgainstCollectables(collisions, player_color);

      this.checkResetCondition();



      if (!pu1.isPlaying()) {
        pu1.rewind();
      }

      if (!pu2.isPlaying()) {
        pu2.rewind();
      }
    }
  }

  void checkResetCondition() {

    ArrayList<Entity> collectables = this.world.group_manager.getEntitiesInGroup(GROUP_COLLECTABLES);

    boolean all_inactive = true;
    for (int i = 0; i < collectables.size(); i++) {
      Entity e = collectables.get(i);
      if (e.active) {
        all_inactive = false;
        break;
      } else {
        remove_buffer.add(e);
      }
    }

    for (int i = 0; i < remove_buffer.size(); i++) {
        world.removeEntity(remove_buffer.get(i));
    }

    remove_buffer.clear();

    if (all_inactive) {
      setUpCollectables(world, 25, color_green);
      setUpCollectables(world, 25, color_blue);
      background(255, 255, 255);
    }

  }
  
  boolean checkWinCondition() {
    return player_color.g >  254f;
  }

  void collidePlayerAgainstCollectables(ArrayList<CollisionPair> collisions, RGB player_color) {

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        Entity player = p.a;

        p.b.active = false;

        Shape bshape = ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

        if (bshape.getColor() == color_green) {        
          player_color.g += 15;
          player_color.b -= 15;
          
          if (pu1.isPlaying()) {
            pu1.rewind();
          }
          pu1.play();

        } else if (bshape.getColor()  == color_blue) {        
          player_color.g -= 15;
          player_color.b = constrain(player_color.b + 15, 0, 255);
          if (pu2.isPlaying()) {
            pu2.rewind();
          }
          pu2.play();
        }

        bshape.setColor(color_white);
        bshape.draw(); // cheating

      }
    }
  }

   void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
    }
  }
  

}
