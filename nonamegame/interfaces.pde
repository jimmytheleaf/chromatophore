
interface BehaviorCallback {
	void update(float dt);
}

interface Collidable {
	public boolean collidesWith(Collidable collidable);
}

interface InputResponseFunction {

	void update(InputSystem input_system);
}

interface Drawable {
	public void draw();
}