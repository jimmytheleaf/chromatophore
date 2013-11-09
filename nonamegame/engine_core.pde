

class World {

    EntityManager entity_manager;
    SystemManager system_manager;
    ViewPort view_port;
    Clock clock;

    World() {
    	this(DEFAULT_WIDTH, DEFAULT_HEIGHT);
    }

    World(int width, int height) {
      
      this.entity_manager = new EntityManager();
      this.system_manager = new SystemManager();      
   	  this.view_port = new ViewPort(width, height);
   	  this.clock = new Clock();
    }

    void setSystem(System s) {
    	this.system_manager.addSystem(s);
    }

    System getSystem(String name) {
      return this.system_manager.getSystem(name);
    }

    float updateClock() {

    	clock.update();

  		
		if (clock.ticks % 50 == 0) {
		    println(clock.dt);
		    println(clock.fps());
		} 
		

    	return clock.dt;
    }

}

class ViewPort {
	int width;
	int height;

	ViewPort(int _width, int _height) {
		this.width = _width;
		this.height = _height;
	}

}


class Clock {

	int start_time;
	int last_time;
	int now;
	float dt;
	int ticks;

	Clock() {

		this.start_time = millis();
		this.last_time = this.start_time;
		this.now = this.start_time;
		this.dt = 0;
		this.ticks = 0;

	}

	void update() {
		
		ticks++;

		this.now = millis();
		this.dt = (this.now - this.last_time) / 1000.0;
		this.last_time = this.now;

	}

	float fps() {
		return 1 / this.dt;
	}

}
