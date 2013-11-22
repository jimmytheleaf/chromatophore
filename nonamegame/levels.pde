Vec2 center = new Vec2(480, 320);

class BaseScene extends Scene {

  boolean won;
  float win_time = 0;


	BaseScene(String _name, World _w) {
		super(_name, _w);
    won = false;
	}

	void update(float dt) {

	  TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);
	  tween_system.update(dt);

	  InputSystem input_system = (InputSystem) this.world.getSystem(INPUT_SYSTEM);
	  input_system.updateInputs(dt);

	  BehaviorSystem behavior_system = (BehaviorSystem) this.world.getSystem(BEHAVIOR_SYSTEM);
	  behavior_system.updateBehaviors(dt);

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
      //printDebug("Detected collisions: " + collisions.size());

      for (CollisionPair p : collisions) {

        if (p.a == world.getTaggedEntity(TAG_PLAYER)) {

          Entity player = p.a;
          Transform t = (Transform) player.getComponent(TRANSFORM);
          Shape player_shape = ((ShapeComponent) player.getComponent(SHAPE)).shape;
          Motion m = (Motion) player.getComponent(MOTION);

          if (p.b == world.getTaggedEntity(TAG_WALL_LEFT)) {

            //printDebug("Collided: PLAYER and LEFT WALL");
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
            //printDebug("Collided: PLAYER and RIGHT WALL");

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

           // printDebug("Collided: PLAYER and TOP WALL");
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

            // printDebug("Collided: PLAYER and BOTTOM WALL");
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
