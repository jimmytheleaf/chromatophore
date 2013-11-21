
class BaseScene extends Scene {


	BaseScene(String _name, World _w) {
		super(_name, _w);
	}

	void update(float dt) {

	  TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);
	  tween_system.update(dt);

	  InputSystem input_system = (InputSystem) this.world.getSystem(INPUT_SYSTEM);
	  input_system.updateInputs(dt);

	  BehaviorSystem behavior_system = (BehaviorSystem) this.world.getSystem(BEHAVIOR_SYSTEM);
	  behavior_system.updateBehaviors(dt);


    SpringSystem springs = (SpringSystem) this.world.getSystem(SPRING_SYSTEM);
    springs.update(dt);

    PhysicsSystem physics = (PhysicsSystem) this.world.getSystem(PHYSICS_SYSTEM);
    physics.update(dt);

	  MovementSystem movement_system = (MovementSystem) this.world.getSystem(MOVEMENT_SYSTEM);
	  movement_system.updateMovables(dt);

    // Handle Collisions in child class

	}

	void draw() {

    // Extended class responsible for updating
		RenderingSystem rendering_system = (RenderingSystem) this.world.getSystem(RENDERING_SYSTEM);
		rendering_system.drawDrawables();

	}

}

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


class LevelThree extends BaseScene {

  RGB world_color = new RGB(63, 63, 63, 255);

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

  }

  void updateWinCondition() {

  }

  boolean checkWinCondition() {
    return world_color.r >  254f;
  }

}



/*
class TestLevel extends BaseScene {


	TestLevel(World _w) {
		super(TEST_LEVEL, _w);
	}

	void init() {

  		super.init();	  
      setUpPlayer(this.world);
      setUpWalls(this.world, new RGB(zbc[2], zbc[0], zbc[1], 255));

	}

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, true);

  }

	void draw() {

	  background(63, 63, 63);
	  super.draw();

	}

}
*/

void checkJumpability(Entity player, ArrayList<CollisionPair> collisions) {

    boolean jumpable = false;

    for (CollisionPair p : collisions) {

        if (p.a == player && p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {
          jumpable = true; 
        }
    }

    Jumper j = (Jumper) player.getComponent(JUMPER);
    j.jumpable = jumpable;


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
        } 


      }

    }
  }
  

}


void collidePlayerAgainstWalls(ArrayList<CollisionPair> collisions, boolean bounce) {
    collidePlayerAgainstWalls(collisions, bounce, null);
}


void collidePlayerAgainstWalls(ArrayList<CollisionPair> collisions, boolean bounce, RGB world_color) {

  if (collisions.size() > 0) {
      printDebug("Detected collisions: " + collisions.size());

      for (CollisionPair p : collisions) {

        if (p.a == world.getTaggedEntity(TAG_PLAYER)) {

          Entity player = p.a;
          Transform t = (Transform) player.getComponent(TRANSFORM);
          Shape player_shape = ((ShapeComponent) player.getComponent(SHAPE)).shape;
          Motion m = (Motion) player.getComponent(MOTION);

          if (p.b == world.getTaggedEntity(TAG_WALL_LEFT)) {

            printDebug("Collided: PLAYER and LEFT WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;
            
            if (bounce) {
              m.velocity.x = -m.velocity.x;
            }

            if (player_shape instanceof Circle) {
              t.pos.x = wall.pos.x + wall.width + ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.x = wall.pos.x + wall.width;
            }

            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }


          } else if (p.b == world.getTaggedEntity(TAG_WALL_RIGHT)) {
            printDebug("Collided: PLAYER and RIGHT WALL");

            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.x = -m.velocity.x;
            }

            if (player_shape instanceof Circle) {
              t.pos.x = wall.pos.x - ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.x = wall.pos.x - ((Rectangle) player_shape).width;

            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }

          } else if (p.b == world.getTaggedEntity(TAG_WALL_TOP)) {

            printDebug("Collided: PLAYER and TOP WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.y = -m.velocity.y;
            }

            if (player_shape instanceof Circle) {
              t.pos.y = wall.pos.y + wall.height + ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.y = wall.pos.y + wall.height;
            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }

          } else if (p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            printDebug("Collided: PLAYER and BOTTOM WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.y = -m.velocity.y;
            }

            if (player_shape instanceof Circle) {
              t.pos.y = wall.pos.y - ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.y = wall.pos.y - ((Rectangle) player_shape).height;
            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }

          }

        }

      }
    }

}
