
class LevelFive extends BaseScene {

  RGB player_color = new RGB(0, 255, 0, 255);
  RGB wall_color = new RGB(63, 63, 63, 255);

  RGB color_red = new RGB(255, 0, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);


  LevelFive(World _w) {
    super(LEVEL_FIVE, _w);
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, int(center.x), int(center.y), 50, 75, player_color);
      PLAYER_UTILS.addMotion(player, 100, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);

      setUpCollectables(world, 2, color_red);
      setUpShooter(world, 300, 300, TWO_PI, 100f, color_blue);


      setUpWalls(this.world, wall_color);
      background(255, 255, 255);
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(255, 255, 255);
    super.draw();

    textSize(100);
    
    fill(255, 255, 255, 255);

    if (checkWinCondition()) {
      fill(0, 0, 0, 255);
      text("THE WINNER IS YOU", 40, 340); 
    }

  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, false);
    collidePlayerAgainstCollectables(collisions, player_color);

    this.checkResetCondition();

  }

  void checkResetCondition() {

    ArrayList<Entity> collectables = this.world.group_manager.getEntitiesInGroup(GROUP_COLLECTABLES);

    boolean all_inactive = true;
    for (int i = 0; i < collectables.size(); i++) {
      Entity e = collectables.get(i);
      if (e.active) {
        all_inactive = false;
        break;
      }
    }

    if (all_inactive) {
      setUpCollectables(world, 5, color_red);
      background(255, 255, 255);
    }
  }
  
  boolean checkWinCondition() {
    return player_color.r >  254f;
  }

  void collidePlayerAgainstCollectables(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        Entity player = p.a;

        p.b.active = false;

        Shape bshape = ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

        if (bshape.getColor() == color_red) {        
          player_color.r += 15;
          player_color.g -= 15;
        } 

      }
    }
  }
  

}