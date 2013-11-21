
class LevelThree extends BaseScene {

  RGB world_color = new RGB(63, 63, 63, 255);
  Vec2 center = new Vec2(480, 320);

  LevelThree(World _w) {
    super(LEVEL_THREE, _w);
  }

  void init() {

      super.init();
      
      this.world.updateClock();
      this.world.stopClock();

      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, 480, 320, 100, world_color);
      PLAYER_UTILS.addMotion(player, 1000, 0, 0, .98f);
      PLAYER_UTILS.addPhysics(player, 1);
      PLAYER_UTILS.addForceMovement(player, 130);

      Entity mount = setUpSpringMount(world, 480, 320, 10000f);

      SpringSystem springs = (SpringSystem) this.world.getSystem(SPRING_SYSTEM);

      springs.addSpring(mount, player, 0.7, 0.06, 1);

      setUpWalls(this.world, world_color);

      background(255, 255, 255);


  }


  void draw() {

    this.world.startClock();
    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(255, 255, 255);
    super.draw();

    textSize(100);
    
    if (checkWinCondition()) {
      fill(0, 0, 0, 255);
      text("THE WINNER IS YOU", 40, 340); 

    }

  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, true, this.world_color);

    this.updateWinCondition();

    Entity player = world.getTaggedEntity(TAG_PLAYER);
    ShapeComponent sc = (ShapeComponent) player.getComponent(SHAPE);
    Circle c = (Circle) sc.shape;

    Transform t = (Transform) player.getComponent(TRANSFORM);


    c.radius = 100 * (t.pos.dist(center) / 250);

  }

  void updateWinCondition() {

  }

  boolean checkWinCondition() {
    return world_color.r >  254f;
  }

}