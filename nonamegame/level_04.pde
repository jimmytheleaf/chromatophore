
class LevelFour extends BaseScene {

  int corners_touched;

  LevelFour(World _w) {
    super(LEVEL_FOUR, _w);
    corners_touched = 0;
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, 330, 170, 10, 10, new RGB(0, 0, 0, 255));
      PLAYER_UTILS.addMotion(player, 500, 0, 0, .05);
      PLAYER_UTILS.addSpaceshipMovement(player, 100);

      setUpWalls(this.world, new RGB(0, 0, 0, 255));
      background(255, 255, 255);
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    //background(255, 255, 255);
    super.draw();

    textSize(100);
    
    fill(255, 255, 255, 255);

    text("" + corners_touched, 40, 140);
    printDebug("Corners Touched: " + corners_touched);
    if (corners_touched == 4) {
      printDebug("WIN");
      text("THE WINNER IS YOU", 40, 340); 
    }

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