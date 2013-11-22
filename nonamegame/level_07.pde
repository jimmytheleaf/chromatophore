
class LevelSeven extends BaseScene {

  RGB player_color = new RGB(0, 255, 100, 255);
  RGB color_grey = new RGB(63, 63, 63, 255);
  RGB color_dark_grey = new RGB(21, 21, 21, 255);

  RGB color_red = new RGB(255, 0, 0, 255);
  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);
  RGB color_black = new RGB(0, 0, 0, 255);
  RGB color_white = new RGB(255, 255, 255, 255);
  RGB bullet_color = new RGB(147, 176, 205, 255);

  RGB collectable_color = new RGB(0, 0, 0, 255);

  RGB wall_color = color_grey;
  RGB bg = color_dark_grey;

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  Transform player_transform;
  int walls_hit = 0;

  int NUM_COLLECTABLES = 100;

  LevelSeven(World _w) {
    super(LEVEL_SEVEN, _w);
  }

  void init() {


      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, int(center.x), int(center.y), 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);

      player_transform = (Transform) player.getComponent(TRANSFORM);


      setUpCollectables(world, NUM_COLLECTABLES, collectable_color, true);
      setUpMovingShooter(world, LEFT_X + 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, RIGHT_X - 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, RIGHT_X - 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, RIGHT_X - 300, TOP_Y + 300, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, LEFT_X + 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, LEFT_X + 150, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, LEFT_X + 75, BOTTOM_Y - 150, TWO_PI, 100f, bullet_color, 10);

      setUpWalls(this.world, wall_color);
      background(bg.r, bg.g, bg.b);
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(bg.r, bg.g, bg.b);
    super.draw();

    textSize(75);
    
    fill(255, 255, 255, 255);

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
          this.world.scene_manager.setCurrentScene(gateway);
        }
    }

  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    levelSevenWallCollisions(collisions);
    handleLevelCollisions(collisions, player_color);

    this.checkResetCondition();

    bullet_color.r += randomint(-20, 20);
    bullet_color.g += randomint(-20, 20);
    bullet_color.b += randomint(-20, 20);

    if (bullet_color.r < 0 || bullet_color.r > 255) {
      bullet_color.r = 127;
    }
    if (bullet_color.g < 0 || bullet_color.g > 255) {
      bullet_color.g = 127;
    }

    if (bullet_color.g < 0 || bullet_color.g > 255) {
      bullet_color.g = 127;
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

      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      setUpCollectables(world, NUM_COLLECTABLES, collectable_color, true);
      background(255, 255, 255);
    }
  }
  
  boolean checkWinCondition() {
    return player_transform.pos.x < 0 || player_transform.pos.x > width || player_transform.pos.y < 0 || player_transform.pos.y > height;
  }

  void handleLevelCollisions(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        p.b.active = false;
        
        player_color.r = randomint(0, 255);
        player_color.g = randomint(0, 255);
        player_color.b = randomint(0, 255);
        

      } else if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_BULLETS)) {

        Pool<Entity> pool = ((PoolComponent) p.b.getComponent(POOL)).pool;
        pool.giveBack(p.b);
     
        player_color.r = randomint(0, 255);
        player_color.g = randomint(0, 255);
        player_color.b = randomint(0, 255);

      }
    }
  }

  void levelSevenWallCollisions(ArrayList<CollisionPair> collisions) {

  if (collisions.size() > 0) {
      //printDebug("Detected collisions: " + collisions.size());

      for (CollisionPair p : collisions) {

        if (p.a == world.getTaggedEntity(TAG_PLAYER)) {

          Entity player = p.a;
          Transform t = (Transform) player.getComponent(TRANSFORM);
          Shape player_shape = ((ShapeComponent) player.getComponent(SHAPE)).shape;
          Motion m = (Motion) player.getComponent(MOTION);

          if (p.b == world.getTaggedEntity(TAG_WALL_LEFT) || p.b == world.getTaggedEntity(TAG_WALL_RIGHT) || 
            p.b == world.getTaggedEntity(TAG_WALL_TOP) || p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            RGB wall_color = new RGB(0, 0, 0, 0);
            wall_color.setFromRaw(wall.getColor().toRaw());
      

            if (wall_color.r > 0) {  

              wall_color.r -=5;
              wall_color.g -=5;
              wall_color.b -=5;

              t.pos.x = LEFT_X + 300;
              t.pos.y = TOP_Y + 300;

              wall.setColor(wall_color);
            }

          } 

        }

      }
    }

}


  

}