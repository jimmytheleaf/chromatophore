

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


	void addCircleShape(Entity player, int x, int y, int radius, IColor c) {

	  	Transform t = new Transform(x, y);
	  	player.addComponent(t);

		final Shape player_shape = new Circle(t.pos, radius).setColor(c);
	 	player.addComponent(new ShapeComponent(player_shape, 1));

	}

	void addPhysics(Entity player, float mass) {

	  	Physics p = new Physics(mass);
	  	player.addComponent(p);

	}

	void addMotion(Entity player, int max_speed, int drag_x, int drag_y, float damping) {

	  	  Motion m = new Motion();
		  m.max_speed = max_speed;
		  m.drag.x = drag_x;
		  m.drag.y = drag_y;
		  m.damping = damping;

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

	void addSpaceshipMovementRandomControls(final Entity player, final int responsiveness) {

		InputResponse r = new InputResponse(); 

		final ArrayList<MotionChanger> motions = new ArrayList<MotionChanger>();

		motions.add(new MotionChanger() {
			public void updateMotion(Motion m) {
				 if (m.velocity.y >= 0) {
	               m.velocity.y = 0;
	            }
	            m.velocity.y -= responsiveness;
	            printDebug("Moving down");
			}
		});

		motions.add(new MotionChanger() {
			public 	void updateMotion(Motion m) {
					if (m.velocity.y <= 0) {
	              m.velocity.y = 0;
	            }
	            m.velocity.y += responsiveness;
	            printDebug("Moving up");

				}
			});

			motions.add(new MotionChanger() {
				public void updateMotion(Motion m) {
					if (m.velocity.x >= 0) {
	              m.velocity.x = 0;
	            }
	            m.velocity.x -= responsiveness;
	           	printDebug("Moving left");

				}
			});

			motions.add(new MotionChanger() {
				public void updateMotion(Motion m) {
				if (m.velocity.x <= 0) {
	              m.velocity.x = 0;
	            }
	            m.velocity.x += responsiveness;
	           	printDebug("Moving Right");
				}
			});

		final HashMap<String, Integer> action_maps = new HashMap<String, Integer>();

		final ArrayList<String> actions = new ArrayList<String>();
		actions.add(ACTION_UP);
		actions.add(ACTION_RIGHT);
		actions.add(ACTION_DOWN);
		actions.add(ACTION_LEFT);

  		r.addInputResponseFunction(new InputResponseFunction() {

  			int current_index = 0;

      		public void update(InputSystem input_system) {

      			Motion m = (Motion) player.getComponent(MOTION);

      			for (int i = 0; i < actions.size(); i++) {
      				String a = actions.get(i);
      				if (input_system.actionPressed(a)) {
      					action_maps.put(a, current_index);
      					printDebug("Mapping action " + a + " to impact " + i);

      					current_index++;
      					if (current_index >= actions.size()) {
      						current_index = 0;
      					}

      				} else if (action_maps.containsKey(a) && !input_system.actionHeld(a)) {
      					action_maps.remove(a);
      					printDebug("Released action " + a);

      				}

      				if (input_system.actionHeld(a)) {
      					MotionChanger motion_changer = motions.get(action_maps.get(a));
      					motion_changer.updateMotion(m);
      				}
      			}

		     }
	  });

	  player.addComponent(r);

	}



	void addForceMovement(final Entity player, final float force) {

		InputResponse r = new InputResponse(); 

  		r.addInputResponseFunction(new InputResponseFunction() {
      		
      		public void update(InputSystem input_system) {

		        Physics p = (Physics) player.getComponent(PHYSICS);

		        boolean up_or_down = false;
		        boolean left_or_right = false;

		        if (input_system.actionHeld(ACTION_UP)) {

		          	p.applyForce(0, -force);
		          	up_or_down = true;
	
		        } else if (input_system.actionHeld(ACTION_DOWN)) {
		            
		           	p.applyForce(0, force);
		          	up_or_down = true;

		          } 

		          if (input_system.actionHeld(ACTION_LEFT)) {

		           	p.applyForce(-force, 0);
		           	left_or_right = true;

		          } else if (input_system.actionHeld(ACTION_RIGHT)) {
		           	
		           	p.applyForce(force, 0);
		          	left_or_right = true;
		          }

		          if (up_or_down && left_or_right) {
		          	p.normalizeForces(force);
		          }

		      }
	  });

	  player.addComponent(r);

	}


	void addPlatformerMovement(final Entity player, final int responsiveness, final int jump_power) {

		InputResponse r = new InputResponse(); 

		final AudioPlayer jump = audio_manager.getSound(SOUND_L2JUMP);

  		r.addInputResponseFunction(new InputResponseFunction() {
      		


      		public void update(InputSystem input_system) {

      			if (!jump.isPlaying()) {
			      jump.rewind();
			    }
		        Motion m = (Motion) player.getComponent(MOTION);

		          if (input_system.actionHeld(ACTION_UP)) {
		            
		            Jumper j = (Jumper) player.getComponent(JUMPER);

		            if (j.jumpable) {

		            	if (m.velocity.y >= 0) {
		               		m.velocity.y = 0;
		            	}
		            	m.velocity.y -= jump_power;

		            	j.jumpable = false;
		            	jump.play();
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


	void addConstrainToWorldBehavior(final Entity player) {
		Behavior b = new Behavior();

		  b.addBehavior(new BehaviorCallback() {
		      public void update(float dt) {
		        Transform t = (Transform) player.getComponent(TRANSFORM);

		        if (t.pos.x <= LEFT_X) {
		          t.pos.x = LEFT_X;
		        }

		        if (t.pos.x >= RIGHT_X) {
		          t.pos.x = RIGHT_X;
		        }

		        if (t.pos.y <= TOP_Y) {
		          t.pos.y = TOP_Y;
		        }

		        if (t.pos.y >= BOTTOM_Y) {
		          t.pos.y = BOTTOM_Y;
		        }
		      }
		  });

		  player.addComponent(b);

	}

}

PlayerUtils PLAYER_UTILS = new PlayerUtils();






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

        if (t.pos.x <= LEFT_X) {
          t.pos.x = LEFT_X;
          m.velocity.x = -m.velocity.x;
        }

        if (t.pos.x >= RIGHT_X) {
          t.pos.x = RIGHT_X;
          m.velocity.x = -m.velocity.x;
        }

        if (t.pos.y <= TOP_Y) {
          t.pos.y = TOP_Y;
          m.velocity.y = -m.velocity.y;
        }

        if (t.pos.y >= BOTTOM_Y) {
          t.pos.y = BOTTOM_Y;
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
