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

			println("Motion Found for : " + e);

			if (this.world.entity_manager.component_store.get(TRANSFORM).containsKey(e)) {
				println("Transform Found for : " + e);

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

		    println("Accelerating entity: " + acceleration_effect_x + ", " + acceleration_effect_y);

		}

	
		if (movement.drag.x != 0 || movement.drag.y != 0) {


			float drag_x = movement.drag.x * dt;
			float drag_y = movement.drag.y * dt;

		 	if (movement.velocity.x > 0) {
		        
		        movement.velocity.x = movement.velocity.x - drag_x;

		        if (movement.velocity.x < 0) {
		        	movement.velocity.x = 0;
		        }

		    } else if (movement.velocity.x < 0) {

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

		    } else if (movement.velocity.y < 0) {

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

			println("Moving entity: " + movement_x + ", " + movement_y);

		}


	}



}
