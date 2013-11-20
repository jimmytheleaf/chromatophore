

 class PlayerUtils {

	Entity getNewPlayerEntity(World world) {

	  Entity player = world.entity_manager.newEntity();
	  world.tagEntity(player, TAG_PLAYER);
	  return player;

	}

	void addRectangleShape(Entity player, int x, int y, int w, int h, IColor c) {

	  	Transform t = new Transform(x, y);
	  	player.addComponent(t);

		final Shape player_shape = new Rectangle(t.pos, w, h).setColor(c);
	 	player.addComponent(new ShapeComponent(player_shape, 0));

	}

	void addMotion(Entity player, int max_speed, int drag_x, int drag_y) {

	  	  Motion m = new Motion();
		  m.max_speed = max_speed;
		  m.drag.x = drag_x;
		  m.drag.y = drag_y;

		  player.addComponent(m);

	}

	void addGravity(Entity player, int x, int y) {

	  	  Gravity g = new Gravity(x, y);
		  player.addComponent(g);

	}

	void addSpaceshipMovement(final Entity player, final int responsiveness) {

		InputResponse r = new InputResponse(); 

  		r.addInputResponseFunction(new InputResponseFunction() {
      		
      		public void update(InputSystem input_system) {

		        Motion m = (Motion) player.getComponent(MOTION);

		          if (input_system.actionHeld(ACTION_UP)) {
		            if (m.velocity.y >= 0) {
		               m.velocity.y = 0;
		            }
		            m.velocity.y -= responsiveness;

		            // printDebug("Action Held: UP");
		          } else if (input_system.actionHeld(ACTION_DOWN)) {
		            
		            if (m.velocity.y <= 0) {
		              m.velocity.y = 0;
		            }
		             m.velocity.y += responsiveness;

		            // printDebug("Action Held: DOWN");

		          }

		          if (input_system.actionHeld(ACTION_LEFT)) {
		            if (m.velocity.x >= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x -= responsiveness;
		            // printDebug("Action Held: LEFT");

		          } else if (input_system.actionHeld(ACTION_RIGHT)) {
		            if (m.velocity.x <= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x += responsiveness;
		            // printDebug("Action Held: RIGHT");

		          }

		      }
	  });

	  player.addComponent(r);

	}


	 void addPlatformerMovement(final Entity player, final int responsiveness, final int jump_power) {

		InputResponse r = new InputResponse(); 

  		r.addInputResponseFunction(new InputResponseFunction() {
      		
      		public void update(InputSystem input_system) {

		        Motion m = (Motion) player.getComponent(MOTION);

		          if (input_system.actionHeld(ACTION_UP)) {
		            

		            Jumper j = (Jumper) player.getComponent(JUMPER);

		            if (j.jumpable) {

		            	if (m.velocity.y >= 0) {
		               		m.velocity.y = 0;
		            	}
		            	m.velocity.y -= jump_power;

		            	j.jumpable = false;
					}
		          } 

		          if (input_system.actionHeld(ACTION_LEFT)) {
		            if (m.velocity.x >= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x -= responsiveness;
		            // printDebug("Action Held: LEFT");

		          } else if (input_system.actionHeld(ACTION_RIGHT)) {
		            if (m.velocity.x <= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x += responsiveness;
		            // printDebug("Action Held: RIGHT");

		          }

		      }
	  });

	  player.addComponent(r);

	  player.addComponent(new Jumper());
	}

}

PlayerUtils PLAYER_UTILS = new PlayerUtils();



void addCircleShape(Entity player, int x, int y, int radius, IColor c) {

  	Transform t = new Transform(x, y);
  	player.addComponent(t);

	final Shape player_shape = new Circle(t.pos, radius).setColor(c);
 	player.addComponent(new ShapeComponent(player_shape, 0));

}



void setUpPlayer(World world) {

  final Entity player = PLAYER_UTILS.getNewPlayerEntity(world);


  Motion m = new Motion();
  m.max_speed = 500;
  m.drag.x = 200;
  m.drag.y = 200;

  player.addComponent(m);


 

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