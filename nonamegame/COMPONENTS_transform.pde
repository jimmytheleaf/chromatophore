String TRANSFORM = "Transform";

class Transform extends Component {

  final Vec2 pos;
  float theta;

  Transform(int x, int y) {
    super(TRANSFORM);
    this.pos = new Vec2(x, y);
    this.theta = 0;
  }

  Transform move(float x, float y) {
    this.pos.x += x;
    this.pos.y += y;
    return this;
  }

  Transform moveTo(float x, float y) {
    this.pos.x = x;
    this.pos.y = y;
    return this;
  }

  Transform rotate(float delta) {
    this.theta += delta;
    return this;
  }

  Transform rotateTo(float new_theta) {
    this.theta = new_theta;
    return this;
  }

  float getRotation() {
    return this.theta;
  }

}
