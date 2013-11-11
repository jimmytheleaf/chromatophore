String BEHAVIOR_SYSTEM = "BehaviorSystem";

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
