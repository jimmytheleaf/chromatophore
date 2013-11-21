

class Vec2 {

	float x;
	float y;

	Vec2(float _x, float _y) {
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

	Vec2 multiply(float multiplier) {
		this.x *= multiplier;
		this.y *= multiplier;
		return this;
	}

	Vec2 divide(float divisor) {
		this.x = this.x / divisor;
		this.y = this.y / divisor;
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

	float dist2(float x, float y) {
		float dx = this.x - x;
		float dy = this.y - y;
		return (dx * dx + dy * dy);
	}

	float dist(float x, float y) {
		return sqrt(this.dist2(x, y));
	}

	Vec2 normalize() {

		float l = this.len();
	 	if ( l > 0) {
			this.x /=  l;
			this.y /= l;
		}
		return this;
	}

	Vec2 scaleTo(float dist) {
		this.normalize();
		this.multiply(dist);
  return this;
	}

	String toString() {
		return "VEC2(" + x + ", " + y + ")";
	}

}
