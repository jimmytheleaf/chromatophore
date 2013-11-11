
String COLLIDER = "Collider";

class CollisionPair {

	Entity a;
	Entity b;

	CollisionPair(Entity _a, Entity _b) {
		this.a = _a;
		this.b = _b;
	}
}

class Collider extends Component {

	Collidable collidable;

	Collider(Collidable _collidable) {
		super(COLLIDER); // ha
		this.collidable = _collidable;
	}

}

