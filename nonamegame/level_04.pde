
class LevelFour extends BaseScene {

  int corners_touched;
  RGB player_color = new RGB(0, 0, 255, 255);
  RGB wall_color = new RGB(255, 0, 0, 255);

  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);


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
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    //background(255, 255, 255);
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
      for (int i = 0; i < collectables.size(); i++) {
        Entity e = collectables.get(i);
        e.active = true;
      }
      background(255, 255, 255);
    }
  }
  
  boolean checkWinCondition() {
    return player_color.g >  254f;
  }

  void collidePlayerAgainstCollectables(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        Entity player = p.a;

        p.b.active = false;

        Shape bshape = ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

        if (bshape.getColor() == color_green) {        
          player_color.g += 15;
          player_color.b -= 15;
        } else if (bshape.getColor()  == color_blue) {        
          player_color.g -= 15;
          player_color.b += 15;
        }


      }
    }
  }
  

}