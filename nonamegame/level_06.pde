
class LevelSix extends BaseScene {

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

  RGB wall_color = color_dark_grey;
  RGB bg = color_grey;

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  int NUM_COLLECTABLES = 4;


  AudioPlayer hit;
  AudioPlayer pickup;


  LevelSix(World _w) {
    super(LEVEL_SIX, _w);
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

      setUpCollectables(world, NUM_COLLECTABLES, collectable_color, true);
      setUpShooter(world, LEFT_X + 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 25);
      setUpShooter(world, RIGHT_X - 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 25);
      setUpShooter(world, RIGHT_X - 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 25);
      setUpShooter(world, LEFT_X + 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 25);

      setUpWalls(this.world, wall_color);
      background(bg.r, bg.g, bg.b);


      hit = audio_manager.getSound(SOUND_L5HIT);
      pickup = audio_manager.getSound(SOUND_L5PU);
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

    collidePlayerAgainstWalls(collisions, true);
    handleLevelCollisions(collisions, player_color);

    this.checkResetCondition();


    if (!hit.isPlaying()) {
      hit.rewind();
    }

    if (!pickup.isPlaying()) {
      pickup.rewind();
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
    return player_color.r >  254f;
  }

  void handleLevelCollisions(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        p.b.active = false;
        // Play a sound
         if (pickup.isPlaying()) {
            pickup.rewind();
          }
          pickup.play();

      } else if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_BULLETS)) {

        Pool<Entity> pool = ((PoolComponent) p.b.getComponent(POOL)).pool;
        pool.giveBack(p.b);
        player_color.r += 15;
        player_color.g -= 5;
        player_color.b -= 5;

        if (hit.isPlaying()) {
            hit.rewind();
        }
        hit.play();
      }
    }
  }


  

}