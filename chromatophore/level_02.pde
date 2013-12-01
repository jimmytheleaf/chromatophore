
class LevelTwo extends BaseScene {

  RGB world_color = new RGB(0, 0, 0, 255);
  RGB red_color = new RGB(255, 0, 0, 255);

  AudioPlayer hit;
  AudioPlayer land;

  Entity fade;

  boolean transitioning_out = false;

  Rectangle player_right_edge; 
  Rectangle player_left_edge;

  LevelTwo(World _w) {
    super(LEVEL_TWO, _w);
  }

  void init() {

      super.init();
      
      this.world.updateClock();
      this.world.stopClock();

      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, 405, 20, 150, 150, world_color);
      PLAYER_UTILS.addMotion(player, 1000, 1000, 0, 1);
      PLAYER_UTILS.addPlatformerMovement(player, 100, 1000);
      PLAYER_UTILS.addGravity(player, 0, 600);
      PLAYER_UTILS.addConstrainToWorldBehavior(player);

      setUpWalls(this.world, world_color);

      setUpPlatform(this.world, 405, 170, 150, 10, new RGB(63, 63, 63, 255));

      hit = audio_manager.getSound(SOUND_L2HIT);
      land = audio_manager.getSound(SOUND_L2LAND);

      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);

      player_left_edge = new Rectangle(405, 40, 20, 110);
      player_right_edge = new Rectangle(535, 40, 20, 110);
      player_left_edge.setColor(red_color);
      player_right_edge.setColor(red_color);


  }


  void draw() {

    this.world.startClock();

    background(255, 255, 255);
    super.draw();
    
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

    // Debug
    // player_left_edge.draw();
    // player_right_edge.draw();
  }

  void update(float dt) {

    super.update(dt);

    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      checkJumpability(world.getTaggedEntity(TAG_PLAYER), collisions);
      collidePlayerAgainstWalls(collisions, false);
      collidePlayerAgainstPlatform(collisions, world_color);

      this.updateWinCondition();


      if (!hit.isPlaying()) {
        hit.rewind();
      }

      if (!land.isPlaying()) {
        land.rewind();
      }
    }
  }

  void updateWinCondition() {

  }

  boolean checkWinCondition() {
    return world_color.r >  254f;
  }

  
  void checkJumpability(Entity player, ArrayList<CollisionPair> collisions) {

      Jumper j = (Jumper) player.getComponent(JUMPER);

      for (CollisionPair p : collisions) {

          if (p.a == player && p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            if (!j.jumpable) {
              j.jumpable = true;
              land.play();
            } 
          }
      }

  }




  void collidePlayerAgainstPlatform(ArrayList<CollisionPair> collisions, RGB world_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && p.b == world.getTaggedEntity(TAG_PLATFORM)) {

        Entity player = p.a;
        Transform t = (Transform) player.getComponent(TRANSFORM);
        Motion m = (Motion) player.getComponent(MOTION);

        Rectangle player_shape = (Rectangle) ((ShapeComponent) player.getComponent(SHAPE)).shape;

        Rectangle platform_shape = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

        player_left_edge.pos.x = player_shape.pos.x;
        player_left_edge.pos.y = player_shape.pos.y + 20;
        player_right_edge.pos.x =  player_shape.pos.x + player_shape.width - 20; 
        player_right_edge.pos.y =  player_shape.pos.y + 20;

        // TODO fix horizontal collision
        if (player_shape instanceof Rectangle && collision_system.rectangleCollision(player_shape, platform_shape)) {

            // Right
            if (collision_system.rectangleCollision(player_right_edge, platform_shape)) {
              
              m.velocity.x = 0;
              player_shape.pos.x = platform_shape.pos.x - player_shape.width;

            // Left
            } else if (collision_system.rectangleCollision(player_left_edge, platform_shape)) {
              
              m.velocity.x = 0;
              player_shape.pos.x = platform_shape.pos.x + platform_shape.width;

            // Bottom
            } else if (m.velocity.y > 0 && player_shape.pos.y + (0.5 * player_shape.height) < platform_shape.pos.y)  {
              
                t.pos.y = platform_shape.pos.y - ((Rectangle)player_shape).height;
                m.velocity.y = 0;
          
            // Top
            } else if (m.velocity.y < 0  && player_shape.pos.y + 10 > platform_shape.pos.y)  {
                
                t.pos.y = platform_shape.pos.y + platform_shape.height;
                m.velocity.y = -m.velocity.y;

                world_color.r += 30;
                world_color.g += 30;
                world_color.b += 30;
                hit.play();
              }



        }

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
