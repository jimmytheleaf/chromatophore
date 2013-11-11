int width = 960;
int height = 640;

World world;

void setup() 
{

  size(960, 640);
  runTests();
  colorMode(RGB, 255, 255, 255, 255);

  world = new World(960, 640);

  final TweenSystem tween_system = new TweenSystem(world);
  MovementSystem movement_system = new MovementSystem(world);
  BehaviorSystem behavior_system = new BehaviorSystem(world);
  InputSystem input_system = new InputSystem(world);
  RenderingSystem rendering_system = new RenderingSystem(world);

  world.setSystem(tween_system);
  world.setSystem(movement_system);
  world.setSystem(behavior_system);
  world.setSystem(input_system);
  world.setSystem(rendering_system);

  input_system.registerInput('W', ACTION_UP);
  input_system.registerInput('S', ACTION_DOWN);
  input_system.registerInput('A', ACTION_LEFT);
  input_system.registerInput('D', ACTION_RIGHT);

  final Entity player = world.entity_manager.newEntity();

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
 player.addComponent(new RenderingComponent().addDrawable(player_shape));

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
   

  player.addComponent(b);

  /*

  */
  background(63, 63, 63);
  noStroke();
}

void update(float dt) {

  TweenSystem tween_system = (TweenSystem) world.getSystem(TWEEN_SYSTEM);
  tween_system.update(dt);

  MovementSystem movement_system = (MovementSystem) world.getSystem(MOVEMENT_SYSTEM);
  movement_system.updateMovables(dt);

  BehaviorSystem behavior_system = (BehaviorSystem) world.getSystem(BEHAVIOR_SYSTEM);
  behavior_system.updateBehaviors(dt);

  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.updateInputs(dt);
}


void draw() 
{
  world.updateClock();

  update(world.clock.dt);

  // background(63, 63, 63);
  
  
  RenderingSystem rendering_system = (RenderingSystem) world.getSystem(RENDERING_SYSTEM);
  rendering_system.drawDrawables();
  

  /*
  fill(zbc[0] + random(-20, 20), zbc[1]  + random(-20, 20), zbc[2]  + random(-20, 20));

  Transform t = (Transform) world.entity_manager.getComponent(player, TRANSFORM);
  Vec2 player_position = t.pos;
  ellipse(player_position.x, player_position.y, 100, 100);  
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

}
  
