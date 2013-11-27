String GRAVITY = "Gravity";

class Gravity extends Component {

	Vec2 force;

	Gravity(float x, float y) { 
  		super(GRAVITY);
		this.force = new Vec2(x, y);
	}

}

