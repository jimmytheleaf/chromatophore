String BEHAVIOR = "Behavior";

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
