
class LevelTwo extends BaseScene {

  RGB world_color = new RGB(0, 0, 0, 255);

  AudioPlayer hit;
  AudioPlayer land;

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

      setUpWalls(this.world, world_color);

      setUpPlatform(this.world, 405, 170, 150, 10, new RGB(63, 63, 63, 255));

      background(255, 255, 255);
      hit = audio_manager.getSound(SOUND_L2HIT);
      land = audio_manager.getSound(SOUND_L2LAND);

  }


  void draw() {

    this.world.startClock();
    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(255, 255, 255);
    super.draw();

    textSize(75);
    
    if (checkWinCondition()) {

       fill(0, 0, 0, 255);
      text("THE WINNER IS YOU", 40, 340); 
      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 
    }
     if (won) {
        if (this.world.clock.total_time - this.win_time > 3) {
          this.world.scene_manager.setCurrentScene(gateway);
        }
    }

  }

  void update(float dt) {

    super.update(dt);

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


      // TODO fix horizontal collision
      if (player_shape instanceof Rectangle) {

        if (collision_system.rectangleCollision(player_shape, platform_shape) &&
            m.velocity.y > 0)  {
            
            t.pos.y = platform_shape.pos.y - ((Rectangle)player_shape).height;
            m.velocity.y = 0;
        
        } else if (collision_system.rectangleCollision(player_shape, platform_shape) &&
            m.velocity.y < 0)  {
            
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

}
