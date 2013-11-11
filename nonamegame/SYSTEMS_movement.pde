String MOVEMENT_SYSTEM = "MovementSystem";

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