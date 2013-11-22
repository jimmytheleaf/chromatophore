
class LevelOne extends BaseScene {

  int corners_touched;

  LevelOne(World _w) {
    super(LEVEL_ONE, _w);
    corners_touched = 0;
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, 330, 170, 300, 300, new RGB(0, 0, 0, 255));
      PLAYER_UTILS.addMotion(player, 500, 200, 200, 1);
      PLAYER_UTILS.addSpaceshipMovement(player, 100);

      setUpWalls(this.world, new RGB(0, 0, 0, 255));
      background(255, 255, 255);
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    //background(255, 255, 255);
    super.draw();

    textSize(75);
    
    fill(255, 255, 255, 255);

    text("" + corners_touched, 40, 140);

    if (checkWinCondition()) {

       fill(255, 255, 255, 255);
      text("THE WINNER IS YOU", 40, 340); 
      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 


    }

     if (won) {
        if (this.world.clock.total_time - this.win_time > 3) {
          this.world.scene_manager.setCurrentScene(LEVEL_GATEWAY);
        }
    }

  }

  boolean checkWinCondition() {
    return corners_touched == 4;
  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, false);

    this.updateWinCondition();

  }

  void updateWinCondition() {

    color black = color(0, 0, 0, 255);
    loadPixels();

    corners_touched = 0;
    
    if (getPixel(181, 21) == black) {
      corners_touched++;
    }

    if (getPixel(181, 619) == black) {
      corners_touched++;
    }

    if (getPixel(779, 21) == black) {
      corners_touched++;
    }

    if (getPixel(779, 619) == black) {
      corners_touched++;
    }
  }

}