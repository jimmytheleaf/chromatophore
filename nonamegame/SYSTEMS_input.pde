String INPUT_SYSTEM = "InputSystem";


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
