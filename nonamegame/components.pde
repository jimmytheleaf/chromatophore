
class Transform extends Component {

	Vec2 pos = new Vec2(0, 0);
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

class Motion extends Component {

	Vec2 velocity = new Vec2(0, 0);
	Vec2 acceleration  = new Vec2(0, 0);
	Vec2 drag = new Vec2(0, 0);
	float min_speed = 0;
	float max_speed = 1000000;
	float min_acceleration = 0;
	float max_acceleration = 10000000;

	boolean active;

	Motion() { 
  		super(MOTION);
		this.active = true;
	}

	Motion accelerate(float dx, float dy) {
		this.acceleration.x += dx;
		this.acceleration.y += dy;
		return this;
	}

	Motion stop() {

		this.velocity.zero();
		this.acceleration.zero();
		return this;
	}

	Motion cap() {

		if (this.acceleration.len() > this.max_acceleration) {

			this.acceleration.scaleTo(this.max_acceleration);

		} else if (this.acceleration.len() < this.min_acceleration) {
	    
	        this.acceleration.scaleTo(this.min_acceleration);

		}


		if (this.velocity.len() > this.max_speed) {

			this.velocity.scaleTo(this.max_speed);

		} else if (this.velocity.len() < this.min_speed) {
	    
          this.velocity.scaleTo(this.min_speed);

		}

		return this;
	}

}


interface BehaviorCallback {
	void update(float dt);
}

class Behavior extends Component {

	ArrayList<BehaviorCallback> behaviors;

	Behavior() {
		super(BEHAVIOR);
		this.behaviors = new ArrayList<BehaviorCallback>();
	}

	Behavior addBehavior(BehaviorCallback c) {
		this.behaviors.add(c);
		return this;
	}

	Behavior reset() {
		this.behaviors = new ArrayList<BehaviorCallback>();
  		return this;
	}

}

interface InputResponseFunction {

	void update(InputSystem input_system);
}

class InputResponse extends Component {

	ArrayList<InputResponseFunction> responses;

	InputResponse() {
		super(INPUT_RESPONSE);
		this.responses = new ArrayList<InputResponseFunction>();
	}

	InputResponse addInputResponseFunction(InputResponseFunction f) {
		this.responses.add(f);
		return this;
	}

	InputResponse reset() {
		this.responses = new ArrayList<InputResponseFunction>();
  		return this;
	}

}


