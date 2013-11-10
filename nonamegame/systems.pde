class BehaviorSystem extends System {

  BehaviorSystem(World w) {
    super(BEHAVIOR_SYSTEM, w);
  }

  void updateBehaviors(float dt) {

    if (this.world.entity_manager.component_store.containsKey(BEHAVIOR)) {
      for (Entity e : this.world.entity_manager.component_store.get(BEHAVIOR).keySet()) {
        Behavior b = (Behavior) e.getComponent(BEHAVIOR);

        for (BehaviorCallback behavior_callback : b.behaviors) {
          behavior_callback.update(dt);
        }
      }
    }
  }
}

class InputSystem extends System {

  HashMap<Integer, String> input_to_action;

  HashMap<String, Boolean> pressed_actions;
  HashMap<String, Boolean> held_actions;

  InputSystem(World w) {
    super(INPUT_SYSTEM, w);
    input_to_action = new HashMap<Integer, String>();
    pressed_actions = new HashMap<String, Boolean>();
    held_actions = new HashMap<String, Boolean>();

  }

  void registerInput(int key, String action) {
    input_to_action.put(key, action);
  }

  void keyPressed(int key) {

  	printDebug("Key pressed called on " + (char) key);
  	
    if (input_to_action.containsKey(key)) {
      String action = input_to_action.get(key);
      pressed_actions.put(action, true);
      held_actions.put(action, true);
    }
  }

  void keyReleased(int key) {
  	printDebug("Key released called on " + (char) key);
    if (input_to_action.containsKey(key)) {
      String action = input_to_action.get(key);
      held_actions.remove(action);
    }
  }

   boolean actionPressed(String action) {
  	return pressed_actions.containsKey(action);
  }

  boolean actionHeld(String action) {
  	return held_actions.containsKey(action);
  }

  void updateInputs(float dt) {
  	
    if (this.world.entity_manager.component_store.containsKey(INPUT_RESPONSE)) {
      for (Entity e : this.world.entity_manager.component_store.get(INPUT_RESPONSE).keySet()) {
        InputResponse r = (InputResponse) e.getComponent(INPUT_RESPONSE);

        for (InputResponseFunction response_func : r.responses) {
          response_func.update(this);
        }
      }
    }
  

    this.pressed_actions = new HashMap<String, Boolean>();

  }
}





class TweenSystem extends System {

  HashMap<Tween, TweenVariable> tweens;

  TweenSystem(World w) {
    super(TWEEN_SYSTEM, w);
    tweens = new HashMap<Tween, TweenVariable>();
  }

  void addTween(float dur, TweenVariable variable, float target, Easing easing_function) {

    Tween tween = new Tween(variable.initial(), target, dur, easing_function);
    tweens.put(tween, variable);
  }

  void update(float dt) {

    Tween[] to_remove = new Tween[tweens.size()];
    int index = 0;

    for (Tween tween : tweens.keySet()) {

      TweenVariable variable = tweens.get(tween);

      tween.update(dt);
      variable.setValue(tween.value);

      if (tween.finished()) {
        to_remove[index] = tween;
        index++;
      }
    }

    for (int i = 0; i < index; i++) {
      tweens.remove(to_remove[i]);
    }
  }
}


class MovementSystem extends System {

  MovementSystem(World w) {
    super(MOVEMENT_SYSTEM, w);
  }

  void updateMovables(float dt) {

    // Bizarre way to get around including Set

      // Entities with motion
    for (Entity e : this.world.entity_manager.component_store.get(MOTION).keySet()) {

      if (this.world.entity_manager.component_store.get(TRANSFORM).containsKey(e)) {

        Transform t = (Transform) e.getComponent(TRANSFORM);
        Motion m = (Motion) e.getComponent(MOTION);
        this.update(t, m, dt);
      }
    }
  }

  void update (Transform transform, Motion movement, float dt) {


    if (movement.acceleration.x != 0 || movement.acceleration.y != 0 ) {
      float acceleration_effect_x = movement.acceleration.x * dt;
      float acceleration_effect_y = movement.acceleration.y * dt;

      movement.velocity.x =  movement.velocity.x  + acceleration_effect_x;
      movement.velocity.y =  movement.velocity.y  + acceleration_effect_y;

    }


    if (movement.drag.x != 0 || movement.drag.y != 0) {


      float drag_x = movement.drag.x * dt;
      float drag_y = movement.drag.y * dt;

      if (movement.velocity.x > 0) {

        movement.velocity.x = movement.velocity.x - drag_x;

        if (movement.velocity.x < 0) {
          movement.velocity.x = 0;
        }
      } 
      else if (movement.velocity.x < 0) {

        movement.velocity.x = movement.velocity.x + drag_x;

        if (movement.velocity.x > 0) {
          movement.velocity.x = 0;
        }
      }


      if (movement.velocity.y > 0) {

        movement.velocity.y = movement.velocity.y - drag_y;

        if (movement.velocity.y < 0) {
          movement.velocity.y = 0;
        }
      } 
      else if (movement.velocity.y < 0) {

        movement.velocity.y = movement.velocity.y + drag_y;

        if (movement.velocity.y > 0) {
          movement.velocity.y = 0;
        }
      }
    }

    movement.cap();

    if (movement.velocity.x != 0 || movement.velocity.y != 0) {

      float movement_x = movement.velocity.x  * dt;
      float movement_y = movement.velocity.y  * dt;

      transform.move(movement_x, movement_y);

    }
  }
}

