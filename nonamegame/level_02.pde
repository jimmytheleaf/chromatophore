
class LevelTwo extends BaseScene {

  RGB world_color = new RGB(0, 0, 0, 255);

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

  }

  void updateWinCondition() {

  }

  boolean checkWinCondition() {
    return world_color.r >  254f;
  }

}