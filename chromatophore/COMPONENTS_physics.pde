String PHYSICS = "Physics";

class Physics extends Component {

  float damping;
  float mass;
  float invmass;
  Vec2 forces;

  Physics(float mass) {
    super(PHYSICS);

    this.mass = mass;
    this.invmass = 1/mass;

    damping = .98;

    forces = new Vec2(0, 0);
  }

  void applyForce(Vec2 force) {
    forces.x += force.x;
    forces.y += force.y;
  }

  void applyForce(float x, float y) {
    forces.x += x;
    forces.y += y;
  }

  void clearForces() {
    forces.x = 0;
    forces.y = 0;
  }

  void normalizeForces(float force) {

    forces.scaleTo(force);
  }

}
