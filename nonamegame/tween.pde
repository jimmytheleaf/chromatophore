

class Tween {

	float initial_value;
	float final_value;
	float dur;
	Easing easing_function;
	float change;
	float elapsed;

	float value;

	Tween(float _initial_value, float _final_value, float _duration, Easing _easing_function) {

		this.initial_value = _initial_value;
		this.final_value = _final_value;
		this.dur = _duration;
		this.easing_function = _easing_function;

		this.change = this.final_value - this.initial_value;

		this.elapsed = 0;
		this.value = this.initial_value;
	}

	void update(float dt) {

		this.elapsed += dt;

		if (this.finished()) {

			this.value = this.final_value;
		
		} else {

			this.value = easing_function.ease(this.elapsed, this.initial_value, this.change, this.dur);

		}

	}

	boolean finished() {

		return this.elapsed > this.dur;
	
	}
}

interface TweenVariable {

 	public	float initial();
	public  void setValue(float value);

}


// Easing Functions

// Cribbed from: https://github.com/EmmanuelOga/easing/blob/master/lib/easing.lua

interface Easing {
	float ease(float t, float b, float c, float d);
}

static class EasingFunctions {

	public static Easing linear = new Easing() {

		float ease(float t, float b, float c, float d) {
	  		return c * t / d + b;
		}

	};

	public static Easing outBounce = new Easing() {

		float ease(float t, float b, float c, float d) {
			
			t = t / d;
			
			if (t < 1 / 2.75) {
			    
			    return c * (7.5625 * t * t) + b;
			
			} 
			else if (t < 2 / 2.75) {

			    t = t - (1.5 / 2.75);
			    return c * (7.5625 * t * t + 0.75) + b;
			
			} 
			else if (t < 2.5 / 2.75) {
			
			    t = t - (2.25 / 2.75);
			    return c * (7.5625 * t * t + 0.9375) + b;
			
			}
			else {

			    t = t - (2.625 / 2.75);
			    return c * (7.5625 * t * t + 0.984375) + b;
			}
				
		}

	};

	public static Easing inCirc = new Easing() {

		float ease(float t, float b, float c, float d) {
	  		t = t / d;
  			return(-c * (sqrt(1 - pow(t, 2)) - 1) + b);
		}

	};

	public static Easing outCirc = new Easing() {

		float ease(float t, float b, float c, float d) {
 			t = t / d - 1;
  			return(c * sqrt(1 - pow(t, 2)) + b);
  		}

	};

	public static Easing inCubic = new Easing() {

		float ease(float t, float b, float c, float d) {
 			t = t / d;
			return c * pow(t, 3) + b;
  		}

	};

	public static Easing outCubic = new Easing() {

		float ease(float t, float b, float c, float d) {
 			t = t / d - 1;
		  	return c * (pow(t, 3) + 1) + b;
  		}

	};

}
