String SPRING_SYSTEM = "SpringSystem";


class Spring {

  Entity a;
  Entity b;
  float stiffness;
  float damping;
  float target_length;

  Spring(Entity a, Entity b, float stiffness, float damping, float target_length) {
    this.a = a;
    this.b = b;
    this.stiffness = stiffness;
    this.damping = damping;
    this.target_length = target_length;
  }

  String toString() {

    return "Spring: (" + a + " and " + b + 
            ", stiffness: " + this.stiffness + 
            ", damping: " + this.damping + 
            ", target_length: " + this.target_length + ")";
  }

}


class SpringSystem extends System {

  ArrayList<Spring> springs;

  Vec2 point_buffer;
  Vec2 velocity_buffer;
  Vec2 force_buffer;

  SpringSystem(World w) {
    super(SPRING_SYSTEM, w);
    springs = new ArrayList<Spring>();
    point_buffer = new Vec2(0, 0);
    velocity_buffer = new Vec2(0, 0);
    force_buffer = new Vec2(0, 0);
  }

  void addSpring(Entity a, Entity b, float stiffness, float damping, float target_length) {
    Spring s = new Spring(a, b, stiffness, damping, target_length);
    springs.add(s);
  }

  void update(float dt) {

    for (Spring s : springs) {

        Entity a = s.a;
        Entity b = s.b;

        Physics a_physics = (Physics) a.getComponent(PHYSICS);
        Physics b_physics = (Physics) b.getComponent(PHYSICS);

        Transform a_transform = (Transform) a.getComponent(TRANSFORM);
        Transform b_transform = (Transform) b.getComponent(TRANSFORM);

        Motion a_motion = (Motion) a.getComponent(MOTION);
        Motion b_motion = (Motion) b.getComponent(MOTION);

        float len = a_transform.pos.dist(b_transform.pos);    

        // Only pull, don't push

        if (len >= s.target_length) {

            printDebug("Pulling with spring: " + s);

            // TODO: attach to middle. For now just happens to work that it's a circle
            point_buffer.x = a_transform.pos.x - b_transform.pos.x;
            point_buffer.y = a_transform.pos.y - b_transform.pos.y;

            point_buffer.divide(len);
            point_buffer.multiply(len - s.target_length);

            velocity_buffer = b_motion.velocity.subtract(a_motion.velocity);

            force_buffer.x = point_buffer.x * s.stiffness - (velocity_buffer.x * s.damping);
            force_buffer.y = point_buffer.y * s.stiffness - (velocity_buffer.y * s.damping);

            printDebug("Applying force to first entity: " + force_buffer);
            b_physics.applyForce(force_buffer);

            force_buffer.negative();

            printDebug("Applying force to second entity: " + force_buffer);
            a_physics.applyForce(force_buffer);

        }

    }


  }

}