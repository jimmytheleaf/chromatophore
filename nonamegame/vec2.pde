

class Vec2 {

	int x;
	int y;

	Vec2(int _x, int _y) {
		this.x = _x;
		this.y = _y;
	}

	Vec2 zero() {
		this.x = 0;
		this.y = 0;
		return this;
	}

	Vec2 copy(Vec2 other) {
		this.x = other.x;
		this.y = other.y;
		return this;
	}

	Vec2 add(Vec2 other) {
		this.x += other.x;
		this.y += other.y;
		return this;
	}
	
	Vec2 subtract(Vec2 other) {
		this.x -= other.x;
		this.y -= other.y;
		return this;
	}

	Vec2 multiply(Vec2 other) {
		this.x *= other.x;
		this.y *= other.y;
		return this;
	}

	Vec2 negative() {
		this.x = - this.x;
		this.y = - this.y;
		return this;
	}

	float len2() {
		return this.x * this.x + this.y * this.y;
	}
	
	float len() {
		return sqrt(this.len2());
	}

	float dist2(Vec2 other) {
		float dx = this.x - other.x;
		float dy = this.y - other.y;
		return (dx * dx + dy * dy);
	}

	float dist(Vec2 other) {
		return sqrt(this.dist2(other));
	}

}