String BEHAVIOR_SYSTEM = "BehaviorSystem";

class BehaviorSystem extends System {

  ArrayList<Entity> entity_buffer;
  BehaviorSystem(World w) {
    super(BEHAVIOR_SYSTEM, w);
    entity_buffer = new ArrayList<Entity>();
  }

  void updateBehaviors(float dt) {

    if (this.world.entity_manager.component_store.containsKey(BEHAVIOR)) {

      entity_buffer.clear();

      for (Entity e : this.world.entity_manager.component_store.get(BEHAVIOR).keySet()) {

        if (e.active) {
          // Add to buffer in case behavior causes entity to remove itself
          entity_buffer.add(e);
        }
      }

      printDebug("Entity buffer has: " + entity_buffer.size() + " Entries");

      for (int i = 0; i < entity_buffer.size(); i++) {

          printDebug("Grabbing behavior");

          Behavior b = (Behavior) (entity_buffer.get(i)).getComponent(BEHAVIOR);

          for (BehaviorCallback behavior_callback : b.behaviors) {


            behavior_callback.update(dt);
          }

      }
    }
  }

}
