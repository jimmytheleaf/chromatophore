
class LevelFive extends BaseScene {

  RGB player_color = new RGB(0, 255, 0, 255);
  RGB wall_color = new RGB(63, 63, 63, 255);

  RGB color_red = new RGB(255, 0, 0, 255);
  RGB color_green = new RGB(0, 255, 0, 255);

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  int NUM_COLLECTABLES = 2;

  LevelFive(World _w) {
    super(LEVEL_FIVE, _w);
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, int(center.x), int(center.y), 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);

      setUpCollectables(world, NUM_COLLECTABLES, color_red);
      setUpShooter(world, LEFT_X + 75, TOP_Y + 75, TWO_PI, 100f, color_green, 14);
      setUpShooter(world, RIGHT_X - 75, BOTTOM_Y - 75, TWO_PI, 100f, color_green, 14);

      setUpWalls(this.world, wall_color);
      background(255, 255, 255);
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(255, 255, 255);
    super.draw();

    textSize(75);
    
    fill(255, 255, 255, 255);

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

    collidePlayerAgainstWalls(collisions, false);
    handleLevelCollisions(collisions, player_color);

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
      } else {
        remove_buffer.add(e);
      }
    }

    for (int i = 0; i < remove_buffer.size(); i++) {
        world.removeEntity(remove_buffer.get(i));
    }
    remove_buffer.clear();

    if (all_inactive) {
      setUpCollectables(world, NUM_COLLECTABLES, color_red);
      background(255, 255, 255);
    }
  }
  
  boolean checkWinCondition() {
    return player_color.r >  254f;
  }

  void handleLevelCollisions(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        Entity player = p.a;

        p.b.active = false;

        Shape bshape = ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

          player_color.r = constrain(player_color.r + 15, 0, 255);
          player_color.g = constrain(player_color.g - 15, 0, 255);

      } else if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_BULLETS)) {

        Pool<Entity> pool = ((PoolComponent) p.b.getComponent(POOL)).pool;
        pool.giveBack(p.b);
        
        player_color.r = constrain(player_color.r - 10, 0, 255);
        player_color.g = constrain(player_color.g + 10, 0, 255);

      }
    }
  }


  

}