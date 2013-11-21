String MOTION = "Motion";

class Motion extends Component {

	Vec2 velocity = new Vec2(0, 0);
	Vec2 acceleration  = new Vec2(0, 0);
	Vec2 drag = new Vec2(0, 0);
	float min_speed = 0;
	float max_speed = 1000000;
	float min_acceleration = 0;
	float max_acceleration = 10000000;
	float damping = 1;

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

