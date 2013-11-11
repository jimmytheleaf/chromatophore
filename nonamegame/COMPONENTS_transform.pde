String TRANSFORM = "Transform";

class Transform extends Component {

	final Vec2 pos;
	int z;

	Transform(int x, int y) {
  		super(TRANSFORM);
  		this.pos = new Vec2(x, y);
		this.z = 1;
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

}
