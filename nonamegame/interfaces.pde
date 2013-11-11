
interface BehaviorCallback {
	void update(float dt);
}

interface Collidable {}

interface InputResponseFunction {

	void update(InputSystem input_system);
}

interface Drawable {
	public void draw();
}