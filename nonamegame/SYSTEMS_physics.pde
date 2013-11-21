String PHYSICS_SYSTEM = "PhysicsSystem";

class PhysicsSystem extends System {

  Vec2 force_buffer;

  PhysicsSystem(World w) {
    super(PHYSICS_SYSTEM, w);
    force_buffer = new Vec2(0, 0);
  }


  void update(float dt) {


    HashMap<Entity, Component> physics_store = this.world.entity_manager.component_store.get(PHYSICS);

    if (physics_store != null) {

      for (Entity e : physics_store.keySet()) {

        if (this.world.entity_manager.component_store.get(MOTION).containsKey(e)) {

          Physics p = (Physics) physics_store.get(e);
          Motion m = (Motion) e.getComponent(MOTION);


          this.applyForces(p, m);
        }
      }
    }
  }

  void applyForces(Physics p, Motion m) {

    force_buffer.x = p.forces.x;
    force_buffer.y = p.forces.y;

    force_buffer.multiply(p.invmass);

    m.acceleration.add(force_buffer);

    p.clearForces();

  }

}