
int x = 1;
int y = 1;

float max_x;
float max_y;

int square_size = 160;
int divisor = 1;

int width = 960;
int height = 640;

World world;

Entity player;



Rectangle this_rectangle = new Rectangle(0, 0, 960, 640, new Greyscale(0));

void setup() 
{

  size(960, 640);
  runTests();

  world = new World(960, 640);




  TweenSystem tween_system = new TweenSystem(world);
  MovementSystem movement_system = new MovementSystem(world);
  BehaviorSystem behavior_system = new BehaviorSystem(world);
  InputSystem input_system = new InputSystem(world);

  world.setSystem(tween_system);
  world.setSystem(movement_system);
  world.setSystem(behavior_system);
  world.setSystem(input_system);


  input_system.registerInput('W', ACTION_UP);
  input_system.registerInput('S', ACTION_DOWN);
  input_system.registerInput('A', ACTION_LEFT);
  input_system.registerInput('D', ACTION_RIGHT);

  player = world.entity_manager.newEntity();
  player.addComponent(new Transform(500, 500));

  Motion m = new Motion();
  m.max_speed = 500;
  // m.drag.x = 100;
  // m.drag.y = 100;

  player.addComponent(m);

  Behavior b = new Behavior();

  final Entity player_closure = player;
  b.addBehavior(new BehaviorCallback() {
      public void update(float dt) {
        Transform t = (Transform) player_closure.getComponent(TRANSFORM);
        Motion m = (Motion) player_closure.getComponent(MOTION);

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

  player.addComponent(b);

  InputResponse r = new InputResponse(); 

  r.addInputResponseFunction(new InputResponseFunction() {
      public void update(InputSystem input_system) {

        Motion m = (Motion) player_closure.getComponent(MOTION);

          if (input_system.actionHeld(ACTION_UP)) {
            if (m.velocity.y >= 0) {
               m.velocity.y = -100;
               m.acceleration.y = 0;
            }
            m.acceleration.y -= 50;

            // printDebug("Action Held: UP");
          } else if (input_system.actionHeld(ACTION_DOWN)) {
            
            if (m.velocity.y <= 0) {
              m.velocity.y = 100;
              m.acceleration.y = 0;
            }
            m.acceleration.y += 50;

            // printDebug("Action Held: DOWN");

          }

          if (input_system.actionHeld(ACTION_LEFT)) {
            if (m.velocity.x >= 0) {
              m.velocity.x = -100;
              m.acceleration.x = 0;
            }
            m.acceleration.x -= 50;
            // printDebug("Action Held: LEFT");

          } else if (input_system.actionHeld(ACTION_RIGHT)) {
            if (m.velocity.x <= 0) {
              m.velocity.x = 100;
              m.acceleration.x = 0;
            }
            m.acceleration.x += 10;
            // printDebug("Action Held: RIGHT");

          }

      }
  });

  player.addComponent(r);



  tween_system.addTween(3, new TweenVariable() {
                              public float initial() { return this_rectangle.c.alpha; }
                              public void setValue(float value) { this_rectangle.c.alpha = value; }  
                          }, 1.0, EasingFunctions.linear);

}

void draw() 
{
  world.updateClock();

  TweenSystem tween_system = (TweenSystem) world.getSystem(TWEEN_SYSTEM);
  tween_system.update(world.clock.dt);

  MovementSystem movement_system = (MovementSystem) world.getSystem(MOVEMENT_SYSTEM);
  movement_system.updateMovables(world.clock.dt);

  BehaviorSystem behavior_system = (BehaviorSystem) world.getSystem(BEHAVIOR_SYSTEM);
  behavior_system.updateBehaviors(world.clock.dt);


  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.updateInputs(world.clock.dt);

  background(63, 63, 63);

  
  constrain(divisor, 1, 10);  
  divisor = constrain(divisor, 1, 10);  
  float unit_length = square_size / divisor;

  max_x = width / unit_length;
  max_y = height / unit_length;
    
  x = constrain(x, 0, int(max_x - 1));
  y = constrain(y, 0, int(max_y - 1));
  
  fill (70, 70, 70);
  
  for (int i = 0; i < width; i += unit_length) {
    
    for (int j = 0; j < height; j += unit_length) {
    
      if (i == 0 && j > 0) {
        line(0,j,width,j);
        
      } else if (j == 0 && i > 0) {
        
        line(i,0,i,height);

      }
      
    }
  
  }
  
  fill(zbc[0], zbc[1], zbc[2]);

  Transform t = (Transform) world.entity_manager.getComponent(player, TRANSFORM);
  Vec2 player_position = t.pos;
  ellipse(player_position.x, player_position.y, 100, 100);


  // Player
  rect(x * unit_length, y * unit_length, unit_length, unit_length);
  
  this_rectangle.draw();


  /*
  if (mouseX != lastMouseX) {
    printDebug(mouseX);
    lastMouseX = mouseX;
  }
  if (mouseY != lastMouseX) {
    printDebug(mouseY);
    lastMouseX = mouseY;
  }
  */
  

}

void keyReleased() {

  key = normalizeInput(key);

  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.keyReleased(key);
}

void keyPressed() {
  
  key = normalizeInput(key);

  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.keyPressed(key);

  /*
  Motion m = (Motion) world.entity_manager.getComponent(player, MOTION);

  // TODO: http://processing.org/reference/keyCode.html
  if (key == INPUT_UP) {
    y--;
    if (m.velocity.y >= 0) {
      m.velocity.y = -100;
    }
    m.acceleration.y -= 50;
  } else if (key == INPUT_DOWN) {
    y++;
    if (m.velocity.y <= 0) {
      m.velocity.y = 100;
    }
    m.acceleration.y += 50;
  } else if (key == INPUT_LEFT) {
    x--;
    if (m.velocity.x >= 0) {
      m.velocity.x = -100;
    }
    m.acceleration.x -= 50;
  } else if (key == INPUT_RIGHT) {
    x++;
    if (m.velocity.x <= 0) {
      m.velocity.x = 100;
    }
    m.acceleration.x += 10;
  }
  */
  
  if (key == 'I') {
    divisor++;
  } else if (key == 'K') {
    divisor--;
  }
  
}
  
