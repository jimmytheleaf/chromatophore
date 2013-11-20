
interface BehaviorCallback {
	void update(float dt);
}

interface Collidable {
	Shape getShape();
}

interface InputResponseFunction {

	void update(InputSystem input_system);
}

interface Drawable {
	public void draw();
	public String toString();
}