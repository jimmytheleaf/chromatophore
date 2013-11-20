
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

	  MovementSystem movement_system = (MovementSystem) this.world.getSystem(MOVEMENT_SYSTEM);
	  movement_system.updateMovables(dt);

    // Handle Collisions in child class

	}

	void draw() {

	 	this.world.updateClock();

		update(this.world.clock.dt);

		// background(63, 63, 63);
		  
		  
		RenderingSystem rendering_system = (RenderingSystem) this.world.getSystem(RENDERING_SYSTEM);
		rendering_system.drawDrawables();

	}

}





class TestLevel extends BaseScene {


	TestLevel(World _w) {
		super(LEVEL_ONE, _w);
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

    if (collisions.size() > 0) {
      printDebug("Detected collisions: " + collisions.size());

      for (CollisionPair p : collisions) {

        if (p.a == world.getTaggedEntity(TAG_PLAYER)) {

          Entity player = p.a;

          Transform t = (Transform) player.getComponent(TRANSFORM);
          Circle player_shape = (Circle) ((ShapeComponent) player.getComponent(SHAPE)).shape;
          Motion m = (Motion) player.getComponent(MOTION);

          if (p.b == world.getTaggedEntity(TAG_WALL_LEFT)) {

            printDebug("Collided: PLAYER and LEFT WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;
            m.velocity.x = -m.velocity.x;
            t.pos.x = wall.pos.x + wall.width + player_shape.radius;

          } else if (p.b == world.getTaggedEntity(TAG_WALL_RIGHT)) {
            printDebug("Collided: PLAYER and RIGHT WALL");

            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;
            m.velocity.x = -m.velocity.x;
            t.pos.x = wall.pos.x - player_shape.radius;


          } else if (p.b == world.getTaggedEntity(TAG_WALL_TOP)) {

            printDebug("Collided: PLAYER and TOP WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;
            m.velocity.y = -m.velocity.y;
            t.pos.y = wall.pos.y + wall.height + player_shape.radius;

          } else if (p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            printDebug("Collided: PLAYER and BOTTOM WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;
            m.velocity.y = -m.velocity.y;
            t.pos.y = wall.pos.y - player_shape.radius;

          }  

        }

      }
    }


  }

	void draw() {

	  background(63, 63, 63);
	  super.draw();

	}

}

void setUpWalls(World world, IColor c) {

    Entity left = createRectangle(world, 0, 0, 180, 640, c);
    Entity right = createRectangle(world, 780, 0, 180, 640, c);
    Entity top = createRectangle(world, 0, 0, 960, 20, c);
    Entity bottom = createRectangle(world, 0, 620, 960, 20, c);

    world.tagEntity(left, TAG_WALL_LEFT);
    world.tagEntity(right, TAG_WALL_RIGHT);
    world.tagEntity(top, TAG_WALL_TOP);
    world.tagEntity(bottom, TAG_WALL_BOTTOM);

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    cs.watchCollision(player, left);
    cs.watchCollision(player, right);
    cs.watchCollision(player, top);
    cs.watchCollision(player, bottom);
}

Entity createRectangle(World world, int x, int y, int w, int h, IColor c) {

    final Entity rectangle = world.entity_manager.newEntity();
    Transform rt = new Transform(x, y);
    rectangle.addComponent(rt);

    final Shape rectangle_shape = new Rectangle(rt.pos, w, h).setColor(c);
    rectangle.addComponent(new ShapeComponent(rectangle_shape, 1));


    // rectangle.addComponent(new RenderingComponent().addDrawable(rectangle_shape, 1));
    // rectangle.addComponent(new Collider(rectangle_shape));

    return rectangle;
}


void setUpPlayer(World world) {

  final Entity player = world.entity_manager.newEntity();

  world.tagEntity(player, TAG_PLAYER);

  Transform t = new Transform(500, 500);
  player.addComponent(t);

  Motion m = new Motion();
  m.max_speed = 500;
  m.drag.x = 200;
  m.drag.y = 200;

  player.addComponent(m);

  InputResponse r = new InputResponse(); 

  r.addInputResponseFunction(new InputResponseFunction() {
      public void update(InputSystem input_system) {

        Motion m = (Motion) player.getComponent(MOTION);

          if (input_system.actionHeld(ACTION_UP)) {
            if (m.velocity.y >= 0) {
               m.velocity.y = 0;
            }
             m.velocity.y -= 100;

            // printDebug("Action Held: UP");
          } else if (input_system.actionHeld(ACTION_DOWN)) {
            
            if (m.velocity.y <= 0) {
              m.velocity.y = 0;
            }
             m.velocity.y += 100;

            // printDebug("Action Held: DOWN");

          }

          if (input_system.actionHeld(ACTION_LEFT)) {
            if (m.velocity.x >= 0) {
              m.velocity.x = 0;
            }
              m.velocity.x -= 100;
            // printDebug("Action Held: LEFT");

          } else if (input_system.actionHeld(ACTION_RIGHT)) {
            if (m.velocity.x <= 0) {
              m.velocity.x = 0;
            }
              m.velocity.x += 100;
            // printDebug("Action Held: RIGHT");

          }

      }
  });

  player.addComponent(r);

 final Shape player_shape = new Circle(t.pos, 50).setColor(new RGB(zbc[0], zbc[1], zbc[2], 255));

 player.addComponent(new ShapeComponent(player_shape, 0));

//  player.addComponent(new RenderingComponent().addDrawable(player_shape, 0));
// player.addComponent(new Collider(player_shape));

 Behavior b = new Behavior();


  b.addBehavior(new BehaviorCallback() {
      public void update(float dt) {
        Transform t = (Transform) player.getComponent(TRANSFORM);
        Motion m = (Motion) player.getComponent(MOTION);

        if (t.pos.x <= 0) {
          t.pos.x = 0;
          m.velocity.x = -m.velocity.x;
        }

        if (t.pos.x >= width) {
          t.pos.x = width;
          m.velocity.x = -m.velocity.x;
        }

        if (t.pos.y <= 0) {
          t.pos.y = 0;
          m.velocity.y = -m.velocity.y;
        }

        if (t.pos.y >= height) {
          t.pos.y = height;
          m.velocity.y = -m.velocity.y;
        }
      }
  });

 // Shift to analagous colors
 
 /* 
 b.addBehavior(new BehaviorCallback() {

      final HSB player_hsb = new HSB(player_shape.getColor().toRaw());
           
      ArrayList<IColor> analagous = new AnalagousHarmony().generate(player_hsb);
      int current = 0;
      HSB next_color = player_hsb;

      int i = 0;
      public void update(float dt) {

        player_shape.setColor(player_hsb);
        
        printDebug("Got here: " + ((HSB) player_shape.clr).h + " , " + next_color.h);

        if (((HSB) player_shape.clr).h == next_color.h) {
          printDebug("Got here: " + ((HSB) player_shape.clr).h + " , " + next_color.h);
          current++;
          if (current >= analagous.size()) {
            i++;
            current = 0;
          }


          next_color = new HSB(analagous.get(current).toRaw());

        
          tween_system.addTween(0.1, new TweenVariable() {
                              public float initial() {           
                                return ((HSB) player_shape.clr).h; }
                              public void setValue(float value) { 
                                ((HSB) player_shape.clr).h = int(value); 
                              }  
                          }, next_color.h, EasingFunctions.linear);
       
        }

      }
  });
  */

  player.addComponent(b);


}
