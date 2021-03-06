

class World {

    EntityManager entity_manager;
    SystemManager system_manager;
    TagManager tag_manager;
    GroupManager group_manager;
    SceneManager scene_manager;

    ViewPort view_port;
    Clock clock;

    World() {
    	this(DEFAULT_WIDTH, DEFAULT_HEIGHT);
    }

    World(int width, int height) {
      
      // Entity management
      this.entity_manager = new EntityManager(this);
      this.tag_manager = new TagManager();
      this.group_manager = new GroupManager();

      // Systems and scenes
      this.system_manager = new SystemManager();      
      this.scene_manager = new SceneManager();
      
   	  this.view_port = new ViewPort(width, height);
   	  this.clock = new Clock();
      
    }

    void resetEntities() {
      this.entity_manager = new EntityManager(this);
      this.tag_manager = new TagManager();
      this.group_manager = new GroupManager();

    }


    void setSystem(System s) {
    	this.system_manager.addSystem(s);
    }

    System getSystem(String name) {
      return this.system_manager.getSystem(name);
    }

    void stopClock() {
      this.clock.stop();
    }

    void startClock() {
      this.clock.start();
    }

    float updateClock() {

    	clock.update();

  		/*
		if (clock.ticks % 50 == 0) {
		   printDebug(clock.dt);
		   printDebug(clock.fps());
		} 
		*/
		

    	return clock.dt;
    }

    Entity tagEntity(Entity entity, String tag) {
    	tag_manager.registerEntity(tag, entity);
    	return entity;
    }

    Entity getTaggedEntity(String tag) {
    	return tag_manager.getEntity(tag);
    }

    void removeEntity(Entity entity) {
      this.entity_manager.removeEntityReferencesAndComponents(entity);
      this.group_manager.clearEntityFromGroups(entity);
      entity = null;
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
  boolean running;
  float total_time;

	Clock() {

		this.start_time = millis();
		this.last_time = this.start_time;
		this.now = this.start_time;
		this.dt = 0;
		this.ticks = 0;
    this.running = true;
    this.total_time = 0;

	}

	void update() {
		
    if (this.running) {
  		ticks++;

  		this.now = millis();
  		this.dt = (this.now - this.last_time) / 1000.0;
  		this.last_time = this.now;
      this.total_time += this.dt;
    }

	}

  void stop() {
    this.running = false;
  }

  void start() {
    this.running = true;
  }

	float fps() {
		return 1 / this.dt;
	}

}
