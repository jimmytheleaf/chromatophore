import ddf.minim.Minim;
import ddf.minim.AudioPlayer;
import ddf.minim.signals.*;
import ddf.minim.*;

int width = 960;
int height = 640;

final World world = new World(960, 640);
LevelGateway gateway;
LevelCredits credits;

Minim minim;
AudioManager audio_manager;

boolean playing;

void setup() 
{

  size(960, 640, P2D);
  //runTests();
  colorMode(RGB, 255, 255, 255, 255);
  rectMode(CORNER);
  frameRate(60);


  setUpSystems(world);

  background(63, 63, 63);
  noStroke();

  minim = new Minim(this);

  audio_manager = new AudioManager(minim);
  audio_manager.storeSound(SOUND_L1CORNER);
  audio_manager.storeSound(SOUND_L2JUMP);
  audio_manager.storeSound(SOUND_L2LAND);
  audio_manager.storeSound(SOUND_L2HIT);
  audio_manager.storeSound(SOUND_L4PU1);
  audio_manager.storeSound(SOUND_L4PU2);
  audio_manager.storeSound(SOUND_L5HIT);
  audio_manager.storeSound(SOUND_L5PU);
  audio_manager.storeSound(SOUND_L8BG);
  audio_manager.storeSound(SOUND_AMBIENCE);

  playing = false;

  credits = new LevelCredits(world);
  world.scene_manager.addScene(credits);

  gateway = new LevelGateway(world);
  world.scene_manager.addScene(gateway);

  LevelTitle title = new LevelTitle(world);
  world.scene_manager.addScene(title);

  AudioPlayer bgsound = audio_manager.getSound(SOUND_AMBIENCE);
  bgsound.play();
  bgsound.loop();

  // world.scene_manager.setCurrentScene(gateway);
  world.scene_manager.setCurrentScene(title);



}


void setUpSystems(World world) {

  TweenSystem tween_system = new TweenSystem(world);
  MovementSystem movement_system = new MovementSystem(world);
  BehaviorSystem behavior_system = new BehaviorSystem(world);
  InputSystem input_system = new InputSystem(world);
  RenderingSystem rendering_system = new RenderingSystem(world);
  CollisionSystem collision_system = new CollisionSystem(world);
  ScheduleSystem schedule_system = new ScheduleSystem(world);

  SpringSystem spring_system = new SpringSystem(world);
  PhysicsSystem physics_system = new PhysicsSystem(world);

  world.setSystem(tween_system);
  world.setSystem(movement_system);
  world.setSystem(behavior_system);
  world.setSystem(input_system);
  world.setSystem(rendering_system);
  world.setSystem(collision_system);
  world.setSystem(spring_system);
  world.setSystem(physics_system);
  world.setSystem(schedule_system);

  input_system.registerInput('W', ACTION_UP);
  input_system.registerInput('S', ACTION_DOWN);
  input_system.registerInput('A', ACTION_LEFT);
  input_system.registerInput('D', ACTION_RIGHT);

}

void update(float dt) {

  Scene current_scene = world.scene_manager.getCurrentScene();
  current_scene.update(dt);

}


void draw() 
{
  
  Scene current_scene = world.scene_manager.getCurrentScene();
  current_scene.draw();

}

void keyReleased() {

  key = normalizeInput(key);

  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.keyReleased(key);
}

void keyPressed() {
  
  key = normalizeInput(key);

  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.keyPressed(key);

}

void mouseClicked() {
 
  Scene current_scene = world.scene_manager.getCurrentScene();
  current_scene.mouseClicked();

}


class AudioManager {


  Minim minim;

  HashMap<String, AudioPlayer> sounds;

  AudioManager(Minim minim) {
    this.sounds = new HashMap<String, AudioPlayer>();
    this.minim = minim;
  }

  void storeSound(String filename) {
    AudioPlayer p = minim.loadFile(filename);
    p.setGain(-10);
    p.setVolume(0.5);
    sounds.put(filename, p);
  }

  AudioPlayer getSound(String filename) {
    return this.sounds.get(filename);
  }


}
String INPUT_SYSTEM = "InputSystem";


class InputSystem extends System {

  HashMap<Integer, String> input_to_action;

  HashMap<String, Boolean> pressed_actions;
  HashMap<String, Boolean> held_actions;

  InputSystem(World w) {
    super(INPUT_SYSTEM, w);
    input_to_action = new HashMap<Integer, String>();
    pressed_actions = new HashMap<String, Boolean>();
    held_actions = new HashMap<String, Boolean>();
  }

  void registerInput(int key, String action) {
    input_to_action.put(key, action);
  }

  void clearInput(int key) {
    input_to_action.remove(key);
  }

  void keyPressed(int key) {

    // printDebug("Key pressed called on " + (char) key);

    if (input_to_action.containsKey(key)) {
      String action = input_to_action.get(key);
      pressed_actions.put(action, true);
      held_actions.put(action, true);
    }
  }

  void keyReleased(int key) {
    // printDebug("Key released called on " + (char) key);
    if (input_to_action.containsKey(key)) {
      String action = input_to_action.get(key);
      held_actions.remove(action);
    }
  }

  boolean actionPressed(String action) {
    return pressed_actions.containsKey(action);
  }

  boolean actionHeld(String action) {
    return held_actions.containsKey(action);
  }

  void updateInputs(float dt) {

    if (this.world.entity_manager.component_store.containsKey(INPUT_RESPONSE)) {
      for (Entity e : this.world.entity_manager.component_store.get(INPUT_RESPONSE).keySet()) {

        if (e.active) {
          InputResponse r = (InputResponse) e.getComponent(INPUT_RESPONSE);

          for (InputResponseFunction response_func : r.responses) {
            response_func.update(this);
          }
        }
      }
    }


    this.pressed_actions = new HashMap<String, Boolean>();
  }
}


class Cell {

	private boolean default_state;
	private boolean next_state;
	private boolean alive;

	ArrayList<Cell> neighbors;

	Cell(boolean default_state) {
		this.default_state = default_state;
		this.alive = default_state;

		neighbors = new ArrayList<Cell>();
	}

	void setNextState(boolean next) {
		this.next_state = next;
	}

	void transitionState() {
		this.alive = next_state;
	}

	boolean getState() {
		return this.alive;
	}

	void setState(boolean val) {
		this.alive = val;
	}


	void addNeighbor(Cell cell) {
		this.neighbors.add(cell);
	}

	void invertState() {
		this.alive = !this.alive;
	}

	int countNeighbors() {
		int count = 0;
		for (int i = 0; i < neighbors.size(); i++) {
			if (neighbors.get(i).alive) {
				count++;
			}
		}
		return count;
	}

}

class CellGrid {

	private Cell[][] grid;
	int xsize;
	int ysize;

	CellGrid(int x, int y, boolean default_state) {
		this.xsize = x;
		this.ysize = y;

		grid = new Cell[x][y];


		for (int i = 0; i < x; i++) {
			for (int j = 0; j < y; j++) {
				grid[i][j] = new Cell(default_state);
			}
		}

		for (int i = 0; i < x; i++) {
			for (int j = 0; j < y; j++) {
				initializeNeigborLinks(i, j, grid[i][j]);
			}
		}

	}

	Cell getCell(int x, int y) {

		if (x >= 0 && x < xsize && y >= 0 && y < ysize) {
			return grid[x][y];
		} else {
			return null;
		}

	}

	void initializeNeigborLinks(int x, int y, Cell cell) {

		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {

				if (!(i == 0 && j == 0)) {
					int nx = x + i;
					int ny = y + j;

					Cell neighbor = getCell(nx, ny);
					if (neighbor != null) {
						cell.addNeighbor(neighbor);
					}
				}
			}

		}

	}

}


class Life {

	CellGrid cells;

	int tick = 0;

	int living = 0;

	Life(int x, int y) {
		this.cells = new CellGrid(x, y, false);
	}

	void turnOn(int x, int y) {
		this.setState(x, y, true);
	}

	void turnOn(float x, float y) {
		this.setState(int(x), int(y), true);
	}

	void setState(int x, int y, boolean value) {
			this.cells.getCell(x, y).setState(value);
	}

	void toggle(int x, int y) {
			this.cells.getCell(x, y).invertState();
	}

	void updateFrame() {
		tick++;

		living = 0;

		for (int x = 0; x < cells.xsize; x++) {
			for (int y = 0; y < cells.ysize; y++) {

				Cell cell = cells.getCell(x, y);

				int neighbor_count = cell.countNeighbors();

				if (birthCondition(neighbor_count)) {
					cell.setNextState(true);
				} else if (deathCondition(neighbor_count)) {
					cell.setNextState(false);
				} else if (stasisCondition(neighbor_count)) {
					cell.setNextState(cell.getState());
				}
			}
		}

		for (int x = 0; x < cells.xsize; x++) {
			for (int y = 0; y < cells.ysize; y++) {
				Cell cell = cells.getCell(x, y);
				cell.transitionState();
				if (cell.alive) {
					living++;
				}
			}
		}
	}


	boolean birthCondition(int neighbor_count) {
		return neighbor_count == 3;
	}

	boolean deathCondition(int neighbor_count) {
		return neighbor_count <=1 || neighbor_count >= 4;
	}

	boolean stasisCondition(int neighbor_count) {
		return neighbor_count == 3 || neighbor_count == 2;
	}


}





class MultiMap<K, V> {

	// This is dumb, but a way around including files so we can
	// export cleanly to processing.js
	HashMap<K, HashMap<V, Boolean>> map;

	MultiMap() {
		this.map = new HashMap<K, HashMap<V, Boolean>>();
	}

	/*
	V[] get(K key) {
		if (map.containsKey(key)) {
			// Yuck
      		return (V) this.map.get(key).keySet().toArray();
		} else {
			return null;
		}
	}

	void put(K key, V value) {
		if (map.containsKey(key)) {
			map.get(key).put(value, Boolean.TRUE);
		} else {
			map.put(key, new HashMap<V, Boolean>());
			map.get(key).put(value, Boolean.TRUE);
		}

	}
	*/
}

// Very simple pool
abstract class Pool<T> {

	ArrayList<T> used;
	ArrayList<T> available;
	int max_size;

	Pool(int size) {
		this.max_size = size;
		used = new ArrayList<T>();
		available = new ArrayList<T>();
	}

	public T getPoolObject() {

		T obj = null;

		if (available.size() > 0) {
			obj = available.get(0);
			available.remove(obj);
			used.add(obj);
			enableObject(obj);
		} else if (used.size() < max_size) {
			obj = createObject();
			used.add(obj);
		}

		return obj;
	}

	public void giveBack(T object) {
		recycleObject(object);
		used.remove(object);
		available.add(object);
	}

	protected abstract T createObject();
	protected abstract void recycleObject(T object);
	protected abstract void enableObject(T object);


}

int[] zbc = {147, 176, 205};

float bitwiseR(int rgb) {
  return rgb >> 16 & 0xFF;
}

float bitwiseG(int rgb) {
  return rgb >> 8 & 0xFF;
}

float bitwiseB(int rgb) {
  return rgb & 0xFF;
}


interface IColor {  
  
   int toRaw();
   void setFromRaw(int full);
}

class TwoTone implements IColor {
  
  boolean on;
  
  TwoTone(boolean on) {
     this.on = on; 
  }
   int toRaw() {
     if (on) {
       return color(255);
     } else {
       return color(0);
     }
   }
   
   void setFromRaw(int full) {
     int value = int((bitwiseR(full) + bitwiseG(full) + bitwiseB(full)) / 3);
     if (value > 128) {
       this.on = true;
     } else {
       this.on = false;
     } 
   }

}


class Greyscale implements IColor {
 
   int value;
   float alpha;
   
   Greyscale(int value) {
      this.value = constrain(value, 0, 255);
      this.alpha = 255;
   }
  
   int toRaw() {
     return color(this.value, this.value, this.value, this.alpha);
   }
   
   void setFromRaw(int full) {
     
      // Average RGB values
      this.value = int((bitwiseR(full) + bitwiseG(full) + bitwiseB(full)) / 3);
      this.alpha = alpha(full);
 
   }
  
}


class RGB implements IColor {
 
   int r;
   int g;
   int b;
   int a; 
   
  RGB(int raw) {
    this.setFromRaw(raw);
  }

   RGB(int r, int g, int b, int a) {
   
      this.r = constrain(r, 0, 255);
      this.g = constrain(g, 0, 255);
      this.b = constrain(b, 0, 255);
      this.a = constrain(a, 0, 255);

   }
  
   int toRaw() {
     return color(this.r, this.g, this.b, this.a);
   }
   
   void setFromRaw(int full) {
  
     this.r = int(bitwiseR(full));
     this.g = int(bitwiseG(full));
     this.b = int(bitwiseB(full));
     this.a = int(alpha(full));
  
   }
  
}

class HSB implements IColor {

  int h;
  int s;
  int b;
  int a;
 
  HSB(int raw) {
    this.h = 0;
    this.s = 0;
    this.b = 0;
    this.a = 0;

    this.setFromRaw(raw);
  }

  HSB(int _hue, int _saturation, int _brightness) {
    this(_hue, _saturation, _brightness, 255);
  }
  
  HSB(int _hue, int _saturation, int _brightness, int _alpha) {
      this.h = _hue;
      this.s = _saturation;
      this.b = _brightness;
      this.a = _alpha;
  }
  
   // Stay in RGB most of the time
  int toRaw() {

    colorMode(HSB, 360, 100, 100, 255);
    int c = color(this.h, this.s, this.b, this.a);
    colorMode(RGB, 255, 255, 255, 255);
  
    return c;

  }

  void setFromRaw(int raw) {

      colorMode(HSB, 360, 100, 100, 255);
      this.h = int(hue(raw));
      this.s = int(saturation(raw));
      this.b = int(brightness(raw));
      this.a = int(alpha(raw));
      colorMode(RGB, 255, 255, 255, 255);
  }
  
}




interface Harmony {
  ArrayList<IColor> generate(IColor clr);
}

class IdentityHarmony implements Harmony {


  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>(); 
    HSB hsb = new HSB(clr.toRaw());
    list.add(hsb);
    return list;
  }
}

class TriadHarmony implements Harmony {

  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>(); 
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 120 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 240 % 360, hsb.s, hsb.b));  
    return list;
  }
}



class MonochromeHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 20 % 100, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 40 % 100, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 60 % 100, hsb.b));
    list.add(new HSB(hsb.h, hsb.s + 80 % 100, hsb.b)); 
    return list;
  }
}
class AnalagousHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h - 40 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h - 20 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 20 % 360, hsb.s, hsb.b));
    list.add(new HSB(hsb.h + 40 % 360, hsb.s, hsb.b));
    return list;  
  }
}

class ShadeHarmony implements Harmony {
  ArrayList<IColor> generate(IColor clr) {
    ArrayList<IColor> list = new ArrayList<IColor>();
    HSB hsb = new HSB(clr.toRaw());
    list.add(new HSB(hsb.h, hsb.s, hsb.b));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 20 % 100));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 40 % 100));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 60 % 100));
    list.add(new HSB(hsb.h, hsb.s, hsb.b + 80 % 100));
    return list;
  }
}
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

String COLLIDER = "Collider";

class CollisionPair {

	Entity a;
	Entity b;

	CollisionPair(Entity _a, Entity _b) {
		this.a = _a;
		this.b = _b;
	}

	boolean involvesTheseEntities(Entity _a, Entity _b) {
		return (this.a == _a && this.b == _b) || (this.b == _a && this.a == _b);
	} 
}

class Collider extends Component {

	Collidable collidable;

	Collider(Collidable _collidable) {
		super(COLLIDER); // ha
		this.collidable = _collidable;
	}

}
String GRAVITY = "Gravity";

class Gravity extends Component {

	Vec2 force;

	Gravity(float x, float y) { 
  		super(GRAVITY);
		this.force = new Vec2(x, y);
	}

}

String INPUT_RESPONSE = "INPUT_RESPONSE";

class InputResponse extends Component {

	ArrayList<InputResponseFunction> responses;

	InputResponse() {
		super(INPUT_RESPONSE);
		this.responses = new ArrayList<InputResponseFunction>();
	}

	InputResponse addInputResponseFunction(InputResponseFunction f) {
		this.responses.add(f);
		return this;
	}

	InputResponse reset() {
		this.responses = new ArrayList<InputResponseFunction>();
  		return this;
	}

}
String JUMPER = "Jumper";

class Jumper extends Component {

	boolean jumpable;

	Jumper() { 
  		super(JUMPER);
		this.jumpable = false;
	}

}

String MOTION = "Motion";

class Motion extends Component {

	Vec2 velocity = new Vec2(0, 0);
	Vec2 acceleration  = new Vec2(0, 0);
	Vec2 drag = new Vec2(0, 0);
	float min_speed = 0;
	float max_speed = 1000000;
	float min_acceleration = 0;
	float max_acceleration = 10000000;
	float damping = 1;

	boolean active;

	Motion() { 
  		super(MOTION);
		this.active = true;
	}

	Motion accelerate(float dx, float dy) {
		this.acceleration.x += dx;
		this.acceleration.y += dy;
		return this;
	}

	Motion stop() {

		this.velocity.zero();
		this.acceleration.zero();
		return this;
	}

	Motion cap() {

		if (this.acceleration.len() > this.max_acceleration) {

			this.acceleration.scaleTo(this.max_acceleration);

		} else if (this.acceleration.len() < this.min_acceleration) {
	    
	        this.acceleration.scaleTo(this.min_acceleration);

		}


		if (this.velocity.len() > this.max_speed) {

			this.velocity.scaleTo(this.max_speed);

		} else if (this.velocity.len() < this.min_speed) {
	    
          this.velocity.scaleTo(this.min_speed);

		}

		return this;
	}

}

String PHYSICS = "Physics";

class Physics extends Component {

  float damping;
  float mass;
  float invmass;
  Vec2 forces;

  Physics(float mass) {
    super(PHYSICS);

    this.mass = mass;
    this.invmass = 1/mass;

    damping = .98;

    forces = new Vec2(0, 0);
  }

  void applyForce(Vec2 force) {
    forces.x += force.x;
    forces.y += force.y;
  }

  void applyForce(float x, float y) {
    forces.x += x;
    forces.y += y;
  }

  void clearForces() {
    forces.x = 0;
    forces.y = 0;
  }

  void normalizeForces(float force) {

    forces.scaleTo(force);
  }

}
String POOL = "Pool";

class PoolComponent extends Component {

	Pool<Entity> pool;

	PoolComponent(Pool<Entity> p) {
		super(POOL);
		this.pool = p;
	}
}
String RENDERING = "RenderingComponent";

class RenderingComponent extends Component {

  HashMap<Drawable, Integer> drawables_to_layer;

  RenderingComponent() {
    super(RENDERING);
    this.drawables_to_layer = new HashMap<Drawable, Integer>();
  }

  RenderingComponent addDrawable(Drawable d) {
    return this.addDrawable(d, 1);
  }

  RenderingComponent addDrawable(Drawable d, Integer layer) {
    this.drawables_to_layer.put(d, layer);
    return this;
  }

  RenderingComponent reset() {
    this.drawables_to_layer = new HashMap<Drawable, Integer>();
    return this;
  }
}
String SHAPE = "Shape";

class ShapeComponent extends Component {

  int z;
  Shape shape;
  boolean visible;
  boolean collideable;

  ShapeComponent(Shape s) {
    super(SHAPE);
    this.shape = s;
    this.z = 1;
    this.visible = true;
    this.collideable = true;
  }

  ShapeComponent(Shape s, int _z) {
    super(SHAPE);
    this.shape = s;
    this.z = _z;
    this.visible = true;
    this.collideable = true;
  }

}
String TRANSFORM = "Transform";

class Transform extends Component {

  final Vec2 pos;
  float theta;

  Transform(int x, int y) {
    super(TRANSFORM);
    this.pos = new Vec2(x, y);
    this.theta = 0;
  }

  Transform move(float x, float y) {
    this.pos.x += x;
    this.pos.y += y;
    return this;
  }

  Transform moveTo(float x, float y) {
    this.pos.x = x;
    this.pos.y = y;
    return this;
  }

  Transform rotate(float delta) {
    this.theta += delta;
    return this;
  }

  Transform rotateTo(float new_theta) {
    this.theta = new_theta;
    return this;
  }

  float getRotation() {
    return this.theta;
  }

}

boolean DEBUG = false;

void printDebug(String line) {
	if (DEBUG) {
		println(line);
	}
}

void printDebug(char c) {
	if (DEBUG) {
		println(c);
	}
}

void printDebug(float f) {
	if (DEBUG) {
		println(f);
	}
}
class Entity {
 
   int id;
   World world;
   boolean active;
  
   Entity(int _id, World w) {
      this.id = _id; 
      this.world = w;
      this.active = true;
   } 

    void addComponent(Component c) {
      this.world.entity_manager.addComponent(this, c);
   }

   Component getComponent(String name) {

      return this.world.entity_manager.getComponent(this, name);

   }
  
}

class Component {

  String name;
  boolean active;
  
  Component(String _name) {
    this.name = _name;
    this.active = true;
  }

}

class System {
  
  String name;
  World world;
  
  System(String _name, World _w) {
    this.name = _name;
    this.world = _w;
  }
  
}


class Scene {

  String name;
  final World world;
  boolean initialized;
  
  Scene(String _name, World _w) {
    this.name = _name;
    this.world = _w;
    this.initialized = false;
  }
  
  void init() {
    this.initialized = true;

  }
  
  void enter() {    
    if (!initialized) {
       this.init(); 
    }
  }
  
  void update(float dt) {
    // Implement by extending class
  }
  
  void draw() {
    // Implement by extending class
  }

  void mouseClicked() {
    // Implement by extending class
  }

  
  String getName() {
    return this.name;
  }


  
}


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
class EntityManager {
 
   int next_id;
   HashMap<String, HashMap<Entity, Component>> component_store;
   World world;

   EntityManager(World _w) {
      this.next_id = 1; 
      this.component_store = new HashMap<String, HashMap<Entity, Component>>();
      this.world = _w;
   }
   
   Entity newEntity() {
      Entity e = new Entity(next_id, world);  
      next_id++;
      return e;
   }

   void addComponent(Entity e, Component c) {

      HashMap<Entity, Component> store = this.component_store.get(c.name);
      if (store == null) {
        store = new HashMap<Entity, Component> ();
        component_store.put(c.name, store);
      }

      store.put(e, c);

   }

   Component getComponent(Entity e, String name) {

      if (this.component_store.containsKey(name)) {
          HashMap<Entity, Component> store = this.component_store.get(name);
          if (store.containsKey(e)) {
              return store.get(e);
          }

      }
      return null;

   }

   void removeEntityReferencesAndComponents(Entity entity) {

      for (String key : component_store.keySet()) {
          HashMap<Entity, Component> store = component_store.get(key);

          // Garbage collect component
          if (store.containsKey(entity)) {
            store.remove(entity);
          }
      }

   }
  
}

class SystemManager {

  HashMap<String, System> systems;
  
  SystemManager() {
    this.systems = new HashMap<String, System>();  
  }
  
  System addSystem(System s) {
    this.systems.put(s.name, s);
    return s;  
  }
  
  System getSystem(String name) {
    return this.systems.get(name);
  }

}

class SceneManager {

  HashMap<String, Scene> scenes;
  
  Scene current_scene;
  
  SceneManager() {
    this.scenes = new HashMap<String, Scene>();  
  }
  
  Scene addScene(Scene s) {
    this.scenes.put(s.getName(), s);
    return s;  
  }
  
  Scene getScene(String name) {
    return this.scenes.get(name);
  }

  void setCurrentScene(String name) {
    this.current_scene = this.scenes.get(name);
    this.current_scene.enter();
  }

  void setCurrentScene(Scene scene) {
    this.current_scene = scene;
    this.current_scene.enter();
  }

  Scene getCurrentScene() {
    return this.current_scene;
  }


}

class TagManager {

  HashMap<String, Entity> tag_to_entity;

  TagManager() {
    this.tag_to_entity = new HashMap<String, Entity>();
  }

  void registerEntity(String tag, Entity e) {
    this.tag_to_entity.put(tag, e);
  }

  Entity getEntity(String tag) {
    return this.tag_to_entity.get(tag);
  }

}

class GroupManager {

    HashMap<String, ArrayList<Entity>> group_to_entities;

    GroupManager() {
      group_to_entities = new HashMap<String, ArrayList<Entity>>();
    }

    void addEntityToGroup(Entity e, String group) {
      if (!group_to_entities.containsKey(group)) {
        group_to_entities.put(group, new ArrayList<Entity>());
      }
      group_to_entities.get(group).add(e);
    }

    ArrayList<Entity> getEntitiesInGroup(String group) {
      if (!group_to_entities.containsKey(group)) {
        group_to_entities.put(group, new ArrayList<Entity>());
      }
      return group_to_entities.get(group);
    }

    boolean isEntityInGroup(Entity e, String group) {
      ArrayList<Entity> entities =  group_to_entities.get(group);
      return entities != null && entities.contains(e);
    }

    void removeEntityFromGroup(Entity e, String group) {
      ArrayList<Entity> entities =  group_to_entities.get(group);
      if (entities != null) {
        entities.remove(e);
      }    
    }

    void clearEntityFromGroups(Entity e) {

      for (String group : group_to_entities.keySet()) {
        removeEntityFromGroup(e, group);
      }

    }

}


char INPUT_UP = 'W';
char INPUT_DOWN = 'S';
char INPUT_LEFT = 'A';
char INPUT_RIGHT = 'D';

String ACTION_UP = "Up";
String ACTION_DOWN = "Down";
String ACTION_LEFT = "Left";
String ACTION_RIGHT = "Right";


String TAG_PLAYER = "player";
String TAG_PLATFORM = "platform";
String TAG_WALL_TOP = "TOP";
String TAG_WALL_BOTTOM = "BOTTOM";
String TAG_WALL_LEFT = "LEFT";
String TAG_WALL_RIGHT = "RIGHT";
String TAG_SPRING_MOUNT = "springmount";

String GROUP_COLLECTABLES = "collectables";
String GROUP_BULLETS = "bullets";


String TEST_LEVEL = "testlevel";

String LEVEL_ONE = "l1";
String LEVEL_TWO = "l2";
String LEVEL_THREE = "l3";
String LEVEL_FOUR = "l4";
String LEVEL_FIVE = "l5";
String LEVEL_SIX = "l6";
String LEVEL_SEVEN = "l7";
String LEVEL_EIGHT = "l8";
String LEVEL_NINE = "l9";
String LEVEL_GATEWAY = "gateway";
String LEVEL_TITLE = "title";


String SOUND_L1CORNER = "l1corners.mp3";
String SOUND_L2JUMP = "l2jump.mp3";
String SOUND_L2LAND = "l2land.mp3";
String SOUND_L2HIT = "l2hit.mp3";
String SOUND_L4PU1 = "l4pickup1.mp3";
String SOUND_L4PU2 = "l4pickup2.mp3";
String SOUND_L5HIT = "l5hit.mp3";
String SOUND_L5PU = "l5pickup.mp3";
String SOUND_CHIMES = "chimes.mp3";
String SOUND_L8BG = "l8background.mp3";
String SOUND_AMBIENCE = "ambience.mp3";
int CAPS_DIFF = 'a' - 'A';

char normalizeInput(char key) {
  
  if (key >= 'a' && key <= 'z') {
   return char(key - CAPS_DIFF);
  }
  
  return key; 
  
}


color getPixel(int x, int y) {
  return pixels[x + y * width]; 
}

int randomint(int min, int max) {
	return int(random(min, max));
}


interface BehaviorCallback {
	void update(float dt);
}

interface Collidable {}

interface InputResponseFunction {

	void update(InputSystem input_system);
}

interface Drawable {
	public void draw();
	public String toString();
}


interface MotionChanger {
	void updateMotion(Motion m);
}

class LevelOne extends BaseScene {

  int corners_touched;
  Boolean[] corners;
  color black = color(0, 0, 0, 255);
  AudioPlayer audio_player;
  Entity fade;

  boolean transitioning_out = false;
  boolean cleared = false;

  LevelOne(World _w) {
    super(LEVEL_ONE, _w);
    corners_touched = 0;
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, 330, 170, 300, 300, new RGB(0, 0, 0, 255));
      PLAYER_UTILS.addMotion(player, 500, 200, 200, 1);
      PLAYER_UTILS.addSpaceshipMovement(player, 100);

      setUpWalls(this.world, new RGB(0, 0, 0, 255));
      audio_player = audio_manager.getSound(SOUND_L1CORNER);

      corners = new Boolean[4];
      corners[0] = false;
      corners[1] = false;
      corners[2] = false;
      corners[3] = false;

  }


  void draw() {
    if (!cleared) {
      cleared = true;
      background(255, 255, 255);
    }

    this.world.updateClock();
    this.update(this.world.clock.dt);

    //background(255, 255, 255);
    super.draw();

    textSize(75);
    
    fill(255, 255, 255, 255);
    text("" + corners_touched, 40, 140);

    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 
       // text(this.win_time, 40, 140); 
        //text(this.world.clock.total_time, 40, 440); 

    }

     if (won) {
        triggerTransition();
    }
    

  }

  boolean checkWinCondition() {
    return corners_touched == 4;
  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, false);

    if (!audio_player.isPlaying()) {
      audio_player.rewind();
    }
    
    this.updateWinCondition();

  }

  void updateWinCondition() {

    loadPixels();
    
    if (getPixel(181, 21) == black) {
      if (!corners[0]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[0] = true;
      }
    }

    if (getPixel(181, 619) == black) {
      if (!corners[1]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[1] = true;

      }    
    }

    if (getPixel(779, 21) == black) {
       if (!corners[2]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[2] = true;

      }
    }

    if (getPixel(779, 619) == black) {
       if (!corners[3]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[3] = true;
      }
    }
  }

  void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 4, false); 
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
    }
  }

}

class LevelTwo extends BaseScene {

  RGB world_color = new RGB(0, 0, 0, 255);
  RGB red_color = new RGB(255, 0, 0, 255);

  AudioPlayer hit;
  AudioPlayer land;

  Entity fade;

  boolean transitioning_out = false;

  Rectangle player_right_edge; 
  Rectangle player_left_edge;

  LevelTwo(World _w) {
    super(LEVEL_TWO, _w);
  }

  void init() {

      super.init();
      
      this.world.updateClock();
      this.world.stopClock();

      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, 405, 20, 150, 150, world_color);
      PLAYER_UTILS.addMotion(player, 1000, 1000, 0, 1);
      PLAYER_UTILS.addPlatformerMovement(player, 100, 1000);
      PLAYER_UTILS.addGravity(player, 0, 600);
      PLAYER_UTILS.addConstrainToWorldBehavior(player);

      setUpWalls(this.world, world_color);

      setUpPlatform(this.world, 405, 170, 150, 10, new RGB(63, 63, 63, 255));

      hit = audio_manager.getSound(SOUND_L2HIT);
      land = audio_manager.getSound(SOUND_L2LAND);

      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);

      player_left_edge = new Rectangle(405, 40, 20, 110);
      player_right_edge = new Rectangle(535, 40, 20, 110);
      player_left_edge.setColor(red_color);
      player_right_edge.setColor(red_color);


  }


  void draw() {

    this.world.startClock();

    background(255, 255, 255);
    super.draw();
    
    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 
    }
    
    if (won) {
        triggerTransition();
    }


    this.world.updateClock();
    this.update(this.world.clock.dt);

    // Debug
    // player_left_edge.draw();
    // player_right_edge.draw();
  }

  void update(float dt) {

    super.update(dt);

    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      checkJumpability(world.getTaggedEntity(TAG_PLAYER), collisions);
      collidePlayerAgainstWalls(collisions, false);
      collidePlayerAgainstPlatform(collisions, world_color);

      this.updateWinCondition();


      if (!hit.isPlaying()) {
        hit.rewind();
      }

      if (!land.isPlaying()) {
        land.rewind();
      }
    }
  }

  void updateWinCondition() {

  }

  boolean checkWinCondition() {
    return world_color.r >  254f;
  }

  
  void checkJumpability(Entity player, ArrayList<CollisionPair> collisions) {

      Jumper j = (Jumper) player.getComponent(JUMPER);

      for (CollisionPair p : collisions) {

          if (p.a == player && p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            if (!j.jumpable) {
              j.jumpable = true;
              land.play();
            } 
          }
      }

  }




  void collidePlayerAgainstPlatform(ArrayList<CollisionPair> collisions, RGB world_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && p.b == world.getTaggedEntity(TAG_PLATFORM)) {

        Entity player = p.a;
        Transform t = (Transform) player.getComponent(TRANSFORM);
        Motion m = (Motion) player.getComponent(MOTION);

        Rectangle player_shape = (Rectangle) ((ShapeComponent) player.getComponent(SHAPE)).shape;

        Rectangle platform_shape = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

        player_left_edge.pos.x = player_shape.pos.x;
        player_left_edge.pos.y = player_shape.pos.y + 20;
        player_right_edge.pos.x =  player_shape.pos.x + player_shape.width - 20; 
        player_right_edge.pos.y =  player_shape.pos.y + 20;

        // TODO fix horizontal collision
        if (player_shape instanceof Rectangle && collision_system.rectangleCollision(player_shape, platform_shape)) {

            // Right
            if (collision_system.rectangleCollision(player_right_edge, platform_shape)) {
              
              m.velocity.x = 0;
              player_shape.pos.x = platform_shape.pos.x - player_shape.width;

            // Left
            } else if (collision_system.rectangleCollision(player_left_edge, platform_shape)) {
              
              m.velocity.x = 0;
              player_shape.pos.x = platform_shape.pos.x + platform_shape.width;

            // Bottom
            } else if (m.velocity.y > 0 && player_shape.pos.y + (0.5 * player_shape.height) < platform_shape.pos.y)  {
              
                t.pos.y = platform_shape.pos.y - ((Rectangle)player_shape).height;
                m.velocity.y = 0;
          
            // Top
            } else if (m.velocity.y < 0  && player_shape.pos.y + 10 > platform_shape.pos.y)  {
                
                t.pos.y = platform_shape.pos.y + platform_shape.height;
                m.velocity.y = -m.velocity.y;

                world_color.r += 30;
                world_color.g += 30;
                world_color.b += 30;
                hit.play();
              }



        }

      }
    }
    

  }

   void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
    }
  }

}

class LevelThree extends BaseScene {

  RGB world_color = new RGB(63, 63, 63, 255);
  Vec2 center = new Vec2(480, 320);
  AudioOutput out;
  SineWave sine;
  Entity fade;
  boolean transitioning_out = false;

  AudioPlayer hit;

  LevelThree(World _w) {
    super(LEVEL_THREE, _w);
  }

  void init() {

      super.init();
      
      this.world.updateClock();
      this.world.stopClock();

      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, 480, 320, 100, world_color);
      PLAYER_UTILS.addMotion(player, 1000, 0, 0, .98f);
      PLAYER_UTILS.addPhysics(player, 1);
      //PLAYER_UTILS.addForceMovement(player, 141.7);
      PLAYER_UTILS.addForceMovement(player, 500);

      Entity mount = setUpSpringMount(world, 480, 320, 10000f);

      SpringSystem springs = (SpringSystem) this.world.getSystem(SPRING_SYSTEM);

      springs.addSpring(mount, player, 0.7, 0.06, 1);

      setUpWalls(this.world, world_color);

      /*

      // get a line out from Minim, default bufferSize is 1024, default sample rate is 44100, bit depth is 16
      out = minim.getLineOut(Minim.STEREO);
      // create a sine wave Oscillator, set to 440 Hz, at 0.5 amplitude, sample rate from line out
      sine = new SineWave(440, 0.5, out.sampleRate());
  
      // set the portamento speed on the oscillator to 200 milliseconds
      sine.portamento(100);
  
      // add the oscillator to the line out
      out.addSignal(sine);
      //out.addSignal(sine2);
      //out.addSignal(sine3);
      out.mute();
      */

      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);

      hit = audio_manager.getSound(SOUND_L5HIT);


  }


  void draw() {

    this.world.startClock();
 

    background(255, 255, 255);
    super.draw();

    textSize(75);
    
    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 

    }

    if (won) {
      triggerTransition();
    }

    this.world.updateClock();
    this.update(this.world.clock.dt);

  }

  void update(float dt) {

    SpringSystem springs = (SpringSystem) this.world.getSystem(SPRING_SYSTEM);
    springs.update(dt);

    PhysicsSystem physics = (PhysicsSystem) this.world.getSystem(PHYSICS_SYSTEM);
    physics.update(dt);

    super.update(dt);

    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

        CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
        ArrayList<CollisionPair> collisions = collision_system.getCollisions();

        collideOscillatorAgainstWalls(collisions, true, this.world_color);

        this.updateWinCondition();

        Entity player = world.getTaggedEntity(TAG_PLAYER);
        ShapeComponent sc = (ShapeComponent) player.getComponent(SHAPE);
        Circle c = (Circle) sc.shape;

        Transform t = (Transform) player.getComponent(TRANSFORM);    
        float distance = t.pos.dist(center);
        c.radius = 100 * (distance / 250);

        if (!hit.isPlaying()) {
          hit.rewind();
        }
        /*

        if (distance > 10) {
          out.unmute();

          float frequency = 440.0;
          //int interval = int(distance / 25);

          if (distance < 50) {
            frequency *= (6/5.0);
          } else  if (distance < 100) {
            frequency *= (5/4.0);
          } else  if (distance < 150) {
            frequency *= (4/3.0);
          } else  if (distance < 200) {
            frequency *= (3/2.0);
          } else {
            frequency *= 2.0;
          }

          sine.setFreq(frequency);
          //sine2.setFreq(frequency * (5/4)); // Major Third
          // sine3.setFreq(frequency * (3/2)); // Perfect fifth

        } else {
          //out.mute();
        }
        */
    }
   

  }

  void updateWinCondition() {

  }

  boolean checkWinCondition() {
    return world_color.r >  254f;
  }

  void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      // addVolumeFader(out, 3, false);
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() {
                                  //out.mute();
                                  //out.clearSignals();
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
         
    }
  }



  void collideOscillatorAgainstWalls(ArrayList<CollisionPair> collisions, boolean bounce, RGB world_color) {

  if (collisions.size() > 0) {
      //printDebug("Detected collisions: " + collisions.size());

      for (CollisionPair p : collisions) {

        if (p.a == world.getTaggedEntity(TAG_PLAYER)) {

          Entity player = p.a;
          Transform t = (Transform) player.getComponent(TRANSFORM);
          Shape player_shape = ((ShapeComponent) player.getComponent(SHAPE)).shape;
          Motion m = (Motion) player.getComponent(MOTION);

          if (p.b == world.getTaggedEntity(TAG_WALL_LEFT)) {

            //printDebug("Collided: PLAYER and LEFT WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;
            
            if (bounce) {
              m.velocity.x = -m.velocity.x;
            }

            if (player_shape instanceof Circle) {
              t.pos.x = wall.pos.x + wall.width + ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.x = wall.pos.x + wall.width;
            }

            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
              hit.play();
            }


          } else if (p.b == world.getTaggedEntity(TAG_WALL_RIGHT)) {
            //printDebug("Collided: PLAYER and RIGHT WALL");

            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.x = -m.velocity.x;
            }

            if (player_shape instanceof Circle) {
              t.pos.x = wall.pos.x - ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.x = wall.pos.x - ((Rectangle) player_shape).width;

            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
              hit.play();

            }

          } else if (p.b == world.getTaggedEntity(TAG_WALL_TOP)) {

           // printDebug("Collided: PLAYER and TOP WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.y = -m.velocity.y;
            }

            if (player_shape instanceof Circle) {
              t.pos.y = wall.pos.y + wall.height + ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.y = wall.pos.y + wall.height;
            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
              hit.play();

            }

          } else if (p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            // printDebug("Collided: PLAYER and BOTTOM WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.y = -m.velocity.y;
            }

            if (player_shape instanceof Circle) {
              t.pos.y = wall.pos.y - ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.y = wall.pos.y - ((Rectangle) player_shape).height;
            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
              hit.play();

            }

          }

        }

      }
    }

}

}

class LevelFour extends BaseScene {

  int corners_touched;
  RGB player_color = new RGB(0, 0, 255, 255);
  RGB wall_color = new RGB(255, 0, 0, 255);

  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);
  RGB color_white = new RGB(255, 255, 255, 255);

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();


  AudioPlayer pu1;
  AudioPlayer pu2;

  Entity fade;
  boolean transitioning_out = false;


  LevelFour(World _w) {
    super(LEVEL_FOUR, _w);
    corners_touched = 0;
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, int(center.x), int(center.y), 20, player_color);
      PLAYER_UTILS.addMotion(player, 500, 0, 0, .05);
      PLAYER_UTILS.addSpaceshipMovement(player, 100);

      setUpCollectables(world, 25, color_green);
      setUpCollectables(world, 25, color_blue);

      setUpWalls(this.world, wall_color);
      background(255, 255, 255);

      pu1 = audio_manager.getSound(SOUND_L4PU1);
      pu2 = audio_manager.getSound(SOUND_L4PU2);
  }


  void draw() {

   
    super.draw();

    textSize(75);
    
    //fill(255, 255, 255, 255);

    if (checkWinCondition()) {

      // fill(0, 0, 0, 255);
      //text("THE WINNER IS YOU", 40, 340); 
      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 
    }

     if (won) {
        triggerTransition();
    }

    this.world.updateClock();
    this.update(this.world.clock.dt);

  }

  void update(float dt) {

    super.update(dt);


    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      collidePlayerAgainstWalls(collisions, false);
      collidePlayerAgainstCollectables(collisions, player_color);

      this.checkResetCondition();



      if (!pu1.isPlaying()) {
        pu1.rewind();
      }

      if (!pu2.isPlaying()) {
        pu2.rewind();
      }
    }
  }

  void checkResetCondition() {

    ArrayList<Entity> collectables = this.world.group_manager.getEntitiesInGroup(GROUP_COLLECTABLES);

    boolean all_inactive = true;
    for (int i = 0; i < collectables.size(); i++) {
      Entity e = collectables.get(i);
      if (e.active) {
        all_inactive = false;
        break;
      } else {
        remove_buffer.add(e);
      }
    }

    for (int i = 0; i < remove_buffer.size(); i++) {
        world.removeEntity(remove_buffer.get(i));
    }

    remove_buffer.clear();

    if (all_inactive) {
      setUpCollectables(world, 25, color_green);
      setUpCollectables(world, 25, color_blue);
      background(255, 255, 255);
    }

  }
  
  boolean checkWinCondition() {
    return player_color.g >  254f;
  }

  void collidePlayerAgainstCollectables(ArrayList<CollisionPair> collisions, RGB player_color) {

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        Entity player = p.a;

        p.b.active = false;

        Shape bshape = ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

        if (bshape.getColor() == color_green) {        
          player_color.g += 15;
          player_color.b -= 15;
          
          if (pu1.isPlaying()) {
            pu1.rewind();
          }
          pu1.play();

        } else if (bshape.getColor()  == color_blue) {        
          player_color.g -= 15;
          player_color.b = constrain(player_color.b + 15, 0, 255);
          if (pu2.isPlaying()) {
            pu2.rewind();
          }
          pu2.play();
        }

        bshape.setColor(color_white);
        bshape.draw(); // cheating

      }
    }
  }

   void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
    }
  }
  

}

class LevelFive extends BaseScene {

  RGB player_color = new RGB(0, 255, 0, 255);
  RGB wall_color = new RGB(63, 63, 63, 255);

  RGB color_collect = new RGB(255, 0, 255, 255);
  RGB color_shooter = new RGB(0, 255, 255, 255);

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  int NUM_COLLECTABLES = 2;

  AudioPlayer hit;
  AudioPlayer pickup;


  Entity fade;
  boolean transitioning_out = false;



  LevelFive(World _w) {
    super(LEVEL_FIVE, _w);
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, int(center.x), int(center.y), 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);

      setUpCollectables(world, NUM_COLLECTABLES, color_collect);
      setUpShooter(world, LEFT_X + 75, TOP_Y + 75, TWO_PI, 100f, color_shooter, 14);
      setUpShooter(world, RIGHT_X - 75, BOTTOM_Y - 75, TWO_PI, 100f, color_shooter, 14);

      setUpWalls(this.world, wall_color);

      hit = audio_manager.getSound(SOUND_L5HIT);
      pickup = audio_manager.getSound(SOUND_L5PU);

      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);


  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(255, 255, 255);
    super.draw();

    textSize(75);

    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 
    }

    if (won) {
        triggerTransition();

    }

  }

  void update(float dt) {

    super.update(dt);


    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      collidePlayerAgainstWalls(collisions, false);
      handleLevelCollisions(collisions, player_color);

      this.checkResetCondition();


      if (!hit.isPlaying()) {
        hit.rewind();
      }

      if (!pickup.isPlaying()) {
        pickup.rewind();
      }
    }

  }

  void checkResetCondition() {

    ArrayList<Entity> collectables = this.world.group_manager.getEntitiesInGroup(GROUP_COLLECTABLES);

   boolean all_inactive = true;
    for (int i = 0; i < collectables.size(); i++) {
      Entity e = collectables.get(i);
      if (e.active) { 
        all_inactive = false;
        break;
      } else {
        remove_buffer.add(e);
      }
    }

    for (int i = 0; i < remove_buffer.size(); i++) {
        world.removeEntity(remove_buffer.get(i));
    }
    remove_buffer.clear();

    if (all_inactive) {
      setUpCollectables(world, NUM_COLLECTABLES, color_collect);
      background(255, 255, 255);
    }
  }
  
  boolean checkWinCondition() {
    return player_color.r >  254f;
  }

  void handleLevelCollisions(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        Entity player = p.a;

        p.b.active = false;

        Shape bshape = ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

          player_color.r = constrain(player_color.r + 20, 0, 255);
          player_color.b = constrain(player_color.b + 20, 0, 255);
          player_color.g = constrain(player_color.g - 20, 0, 255);

          if (pickup.isPlaying()) {
            pickup.rewind();
          }
          pickup.play();

      } else if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_BULLETS)) {

        Pool<Entity> pool = ((PoolComponent) p.b.getComponent(POOL)).pool;
        pool.giveBack(p.b);
        
        player_color.r = constrain(player_color.r - 10, 0, 255);
        player_color.b = constrain(player_color.b - 10, 0, 255);
        player_color.g = constrain(player_color.g + 10, 0, 255);

        if (hit.isPlaying()) {
            hit.rewind();
        }
        hit.play();
      }
    }
  }


  
   void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
    }
  }

}

class LevelSix extends BaseScene {

  RGB player_color = new RGB(0, 255, 100, 255);
  RGB color_grey = new RGB(63, 63, 63, 255);
  RGB color_dark_grey = new RGB(21, 21, 21, 255);

  RGB color_red = new RGB(255, 0, 0, 255);
  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);
  RGB color_black = new RGB(0, 0, 0, 255);
  RGB color_white = new RGB(255, 255, 255, 255);
  RGB bullet_color = new RGB(147, 176, 205, 255);

  RGB collectable_color = new RGB(0, 0, 0, 255);

  RGB wall_color = color_dark_grey;
  RGB bg = color_grey;

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  int NUM_COLLECTABLES = 4;


  AudioPlayer hit;
  AudioPlayer pickup;

  Entity fade;
  boolean transitioning_out = false;


  LevelSix(World _w) {
    super(LEVEL_SIX, _w);
  }

  void init() {


      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, int(center.x), int(center.y), 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);

      setUpCollectables(world, NUM_COLLECTABLES, collectable_color, true);
      setUpShooter(world, LEFT_X + 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 25);
      setUpShooter(world, RIGHT_X - 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 25);
      setUpShooter(world, RIGHT_X - 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 25);
      setUpShooter(world, LEFT_X + 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 25);

      setUpWalls(this.world, wall_color);

      hit = audio_manager.getSound(SOUND_L5HIT);
      pickup = audio_manager.getSound(SOUND_L5PU);


      
      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);

  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(bg.r, bg.g, bg.b);
    super.draw();

    textSize(75);

    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 
    }

    if (won) {
        triggerTransition();
    }

  }

  void update(float dt) {

    super.update(dt);


    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      collidePlayerAgainstWalls(collisions, true);
      handleLevelCollisions(collisions, player_color);

      this.checkResetCondition();


      if (!hit.isPlaying()) {
        hit.rewind();
      }

      if (!pickup.isPlaying()) {
        pickup.rewind();
      }
    }

  }

  void checkResetCondition() {

    ArrayList<Entity> collectables = this.world.group_manager.getEntitiesInGroup(GROUP_COLLECTABLES);

    
    boolean all_inactive = true;
    for (int i = 0; i < collectables.size(); i++) {
      Entity e = collectables.get(i);
      if (e.active) { 
        all_inactive = false;
        break;
      } else {
        remove_buffer.add(e);
      }
    }

    for (int i = 0; i < remove_buffer.size(); i++) {
        world.removeEntity(remove_buffer.get(i));
    }
    remove_buffer.clear();

    if (all_inactive) {

      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      setUpCollectables(world, NUM_COLLECTABLES, collectable_color, true);
      background(255, 255, 255);
    }
  }
  
  boolean checkWinCondition() {
    return player_color.r >  254f;
  }

  void handleLevelCollisions(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        p.b.active = false;
        // Play a sound
         if (pickup.isPlaying()) {
            pickup.rewind();
          }
          pickup.play();

      } else if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_BULLETS)) {

        Pool<Entity> pool = ((PoolComponent) p.b.getComponent(POOL)).pool;
        pool.giveBack(p.b);
        player_color.r += 15;
        player_color.g -= 5;
        player_color.b -= 5;

        if (hit.isPlaying()) {
            hit.rewind();
        }
        hit.play();
      }
    }
  }

   void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
    }
  }
  

}

class LevelSeven extends BaseScene {

  RGB player_color = new RGB(0, 255, 100, 255);
  RGB color_grey = new RGB(63, 63, 63, 255);
  RGB color_dark_grey = new RGB(21, 21, 21, 255);

  RGB color_red = new RGB(255, 0, 0, 255);
  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);
  RGB color_black = new RGB(0, 0, 0, 255);
  RGB color_white = new RGB(255, 255, 255, 255);
  RGB bullet_color = new RGB(147, 176, 205, 255);

  RGB collectable_color = new RGB(0, 0, 0, 255);

  RGB wall_color = color_grey;
  RGB bg = color_dark_grey;

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  Transform player_transform;
  int walls_hit = 0;

  int NUM_COLLECTABLES = 100;


  AudioPlayer hit;
  AudioPlayer pickup;


  Entity fade;
  boolean transitioning_out = false;

  LevelSeven(World _w) {
    super(LEVEL_SEVEN, _w);
  }

  void init() {


      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addCircleShape(player, int(center.x), int(center.y), 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);

      player_transform = (Transform) player.getComponent(TRANSFORM);


      setUpCollectables(world, NUM_COLLECTABLES, collectable_color, true);
      setUpMovingShooter(world, LEFT_X + 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, RIGHT_X - 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, RIGHT_X - 75, TOP_Y + 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, RIGHT_X - 300, TOP_Y + 300, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, LEFT_X + 75, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, LEFT_X + 150, BOTTOM_Y - 75, TWO_PI, 100f, bullet_color, 10);
      setUpMovingShooter(world, LEFT_X + 75, BOTTOM_Y - 150, TWO_PI, 100f, bullet_color, 10);

      setUpWalls(this.world, wall_color);

      hit = audio_manager.getSound(SOUND_L5HIT);
      pickup = audio_manager.getSound(SOUND_L5PU);


      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);

  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(bg.r, bg.g, bg.b);
    super.draw();

    textSize(75);
    

    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 
    }

    if (won) {
        triggerTransition();
    }

  }

  void update(float dt) {

    super.update(dt);


    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      levelSevenWallCollisions(collisions);
      handleLevelCollisions(collisions, player_color);

      this.checkResetCondition();

      bullet_color.r += randomint(-20, 20);
      bullet_color.g += randomint(-20, 20);
      bullet_color.b += randomint(-20, 20);

      if (bullet_color.r < 0 || bullet_color.r > 255) {
        bullet_color.r = 127;
      }
      if (bullet_color.g < 0 || bullet_color.g > 255) {
        bullet_color.g = 127;
      }

      if (bullet_color.g < 0 || bullet_color.g > 255) {
        bullet_color.g = 127;
      }


      if (!hit.isPlaying()) {
        hit.rewind();
      }

      if (!pickup.isPlaying()) {
        pickup.rewind();
      }
    }

  }

  void checkResetCondition() {

    ArrayList<Entity> collectables = this.world.group_manager.getEntitiesInGroup(GROUP_COLLECTABLES);

    
    boolean all_inactive = true;
    for (int i = 0; i < collectables.size(); i++) {
      Entity e = collectables.get(i);
      if (e.active) { 
        all_inactive = false;
        break;
      } else {
        remove_buffer.add(e);
      }
    }

    for (int i = 0; i < remove_buffer.size(); i++) {
        world.removeEntity(remove_buffer.get(i));
    }
    remove_buffer.clear();

    if (all_inactive) {

      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      setUpCollectables(world, NUM_COLLECTABLES, collectable_color, true);
      background(255, 255, 255);
    }
  }
  
  boolean checkWinCondition() {
    return player_transform.pos.x < 0 || player_transform.pos.x > width || player_transform.pos.y < 0 || player_transform.pos.y > height;
  }

  void handleLevelCollisions(ArrayList<CollisionPair> collisions, RGB player_color) {

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);

    for (CollisionPair p : collisions) {

      if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_COLLECTABLES)) {

        p.b.active = false;
        
        player_color.r = randomint(0, 255);
        player_color.g = randomint(0, 255);
        player_color.b = randomint(0, 255);
         if (pickup.isPlaying()) {
            pickup.rewind();
          }
          pickup.play();
        

      } else if (p.a == world.getTaggedEntity(TAG_PLAYER) && this.world.group_manager.isEntityInGroup(p.b, GROUP_BULLETS)) {

        Pool<Entity> pool = ((PoolComponent) p.b.getComponent(POOL)).pool;
        pool.giveBack(p.b);
     
        player_color.r = randomint(0, 255);
        player_color.g = randomint(0, 255);
        player_color.b = randomint(0, 255);

        if (hit.isPlaying()) {
            hit.rewind();
        }
        hit.play();
      }
    }
  }

  void levelSevenWallCollisions(ArrayList<CollisionPair> collisions) {

  if (collisions.size() > 0) {
      //printDebug("Detected collisions: " + collisions.size());

      for (CollisionPair p : collisions) {

        if (p.a == world.getTaggedEntity(TAG_PLAYER)) {

          Entity player = p.a;
          Transform t = (Transform) player.getComponent(TRANSFORM);
          Shape player_shape = ((ShapeComponent) player.getComponent(SHAPE)).shape;
          Motion m = (Motion) player.getComponent(MOTION);

          if (p.b == world.getTaggedEntity(TAG_WALL_LEFT) || p.b == world.getTaggedEntity(TAG_WALL_RIGHT) || 
            p.b == world.getTaggedEntity(TAG_WALL_TOP) || p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            RGB wall_color = new RGB(0, 0, 0, 0);
            wall_color.setFromRaw(wall.getColor().toRaw());
      

            if (wall_color.r > 0) {  

              wall_color.r -=10;
              wall_color.g -=10;
              wall_color.b -=10;

              t.pos.x = LEFT_X + 300;
              t.pos.y = TOP_Y + 300;

              wall.setColor(wall_color);
            }

          } 

        }

      }
    }

}


  void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false); 
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 3.1);
    }
  }
  

}

class LevelEight extends BaseScene {

  RGB player_color = new RGB(0, 255, 100, 255);
  RGB color_grey = new RGB(63, 63, 63, 255);
  RGB color_dark_grey = new RGB(21, 21, 21, 255);

  RGB color_red = new RGB(255, 0, 0, 255);
  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);
  RGB color_black = new RGB(0, 0, 0, 255);
  RGB color_white = new RGB(255, 255, 255, 255);
  RGB bullet_color = new RGB(147, 176, 205, 255);

  RGB collectable_color = new RGB(0, 0, 0, 255);

  RGB wall_color = color_dark_grey;
  RGB bg = color_grey;

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  Vec2 mouse_gridposition;
  Vec2 player_gridposition;

  int NUM_COLLECTABLES = 4;

  int grid_size = 40;
  Life gol;
  Life gol2;

  int cell_size;

  Transform player_transform;

  AudioPlayer bgsound;


  Entity fade;
  boolean transitioning_out = false;

  LevelEight(World _w) {
    super(LEVEL_EIGHT, _w);
  }

  void init() {

      mouse_gridposition = new Vec2(0, 0);
      player_gridposition = new Vec2(0, 0);

      this.gol = new Life(grid_size, grid_size);
      this.gol.turnOn(1, 5);
      this.gol.turnOn(1, 6);
      this.gol.turnOn(2, 5);
      this.gol.turnOn(2, 6);
 
      this.gol.turnOn(11, 5);
      this.gol.turnOn(11, 6);
      this.gol.turnOn(11, 7);
      this.gol.turnOn(12, 4);
      this.gol.turnOn(12, 8);

      this.gol.turnOn(13, 3);
      this.gol.turnOn(13, 9);
      this.gol.turnOn(14, 3);
      this.gol.turnOn(14, 9);
      this.gol.turnOn(15, 6);

      this.gol.turnOn(16, 4);
      this.gol.turnOn(16, 8);

      this.gol.turnOn(17, 5);
      this.gol.turnOn(17, 6);
      this.gol.turnOn(17, 7);
      this.gol.turnOn(18, 6);

      this.gol.turnOn(21, 3);
      this.gol.turnOn(21, 4);
      this.gol.turnOn(21, 5);

      this.gol.turnOn(22, 3);
      this.gol.turnOn(22, 4);
      this.gol.turnOn(22, 5);      

      this.gol.turnOn(23, 2);
      this.gol.turnOn(23, 6);

      this.gol.turnOn(25, 1);
      this.gol.turnOn(25, 2);
      this.gol.turnOn(25, 6);
      this.gol.turnOn(25, 7);

      this.gol.turnOn(35, 3);
      this.gol.turnOn(35, 4);
      this.gol.turnOn(36, 3);
      this.gol.turnOn(36, 4);

      copyCells(this.gol, 25);

      this.gol2 = new Life(grid_size, grid_size);

      cell_size = 600 / grid_size;

      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, int(center.x), int(center.y), 15, 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      //PLAYER_UTILS.addSpaceshipMovement(player, 20);
      PLAYER_UTILS.addSpaceshipMovementRandomControls(player, 20);

      player_transform = (Transform) player.getComponent(TRANSFORM);

      setUpWalls(this.world, wall_color);
      background(bg.r, bg.g, bg.b);

      bgsound = audio_manager.getSound(SOUND_L8BG);
      bgsound.setGain(-30);
      addVolumeFader(bgsound, 4.5, true);
      bgsound.play();
      bgsound.loop();


      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 3, true);

  }


  void draw() {

    background(gol.living, gol.living, gol.living);
    super.draw();


    for (int i = 0; i < grid_size; i++) {
      for (int j = 0; j < grid_size; j++) {

           Cell cell2 = this.gol2.cells.getCell(i, j);
            
          if (cell2 != null && cell2.alive) {
              fill(0, 255, 100, 100);
              rect(LEFT_X + (i * cell_size), 
                TOP_Y + (j * cell_size),
                cell_size,
                cell_size);
          }


          Cell cell = this.gol.cells.getCell(i, j);
          if (cell != null && cell.alive) {
              fill(255, 255, 255, 255);
              rect(LEFT_X + (i * cell_size), 
                TOP_Y + (j * cell_size),
                cell_size,
                cell_size);
          }

         
      }
    }

    textSize(75);
    
    fill(255, 255, 255, 255);
    text(gol.living, 20, 340);

    // fill(0, 255, 100, 255);
    // text(gol2.living, 780, 340);

    if (checkWinCondition()) {

      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 

    }

     if (won) {
        triggerTransition();
    }

    this.world.updateClock();
    this.update(this.world.clock.dt);


  }

  void update(float dt) {

    super.update(dt);

    // If we haven't transitioned away...
    if (this.world.scene_manager.getCurrentScene() == this) {

      CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
      ArrayList<CollisionPair> collisions = collision_system.getCollisions();

      collidePlayerAgainstWalls(collisions, true);

      mouse_gridposition.x = constrain(floor((mouseX - LEFT_X)/cell_size), 0, grid_size - 1);
      mouse_gridposition.y = constrain(floor((mouseY - TOP_Y)/cell_size), 0, grid_size - 1);


      player_gridposition.x = constrain(floor((player_transform.pos.x - LEFT_X)/cell_size), 0, grid_size - 1);
      player_gridposition.y = constrain(floor((player_transform.pos.y - TOP_Y)/cell_size), 0, grid_size - 1);

      gol2.turnOn(player_gridposition.x, player_gridposition.y);

      if (world.clock.ticks % 8 == 0) {
        this.gol.updateFrame();
      }

       if (world.clock.ticks % 5 == 0) {
        this.gol2.updateFrame();
      }
    }
  }

  void mouseClicked() {
      this.gol.toggle(int(mouse_gridposition.x), int(mouse_gridposition.y));
  }



  
  boolean checkWinCondition() {
    return gol.tick > 0 && gol.living == 0;
  }

  void copyCells(Life gol, int yoffset) {
    for (int i = 0; i < grid_size; i++) {
      for (int j = 0; j < grid_size; j++) {
          Cell cell = gol.cells.getCell(i, j);
          Cell cell2 = gol.cells.getCell(i, j + yoffset);

          if (cell != null && cell2 != null) {

            cell2.setState(cell.getState());
          }

      }   
    }
  }

   void triggerTransition() {
    if (!transitioning_out) {
      fade = fullScreenFadeBox(world, false);

      transitioning_out = true;      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 5, false); 
      addVolumeFader(bgsound, 5, false);
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(gateway);
                                }
                              }, 5.1);
    }
  }
 

  

}

class LevelCredits extends BaseScene {

  Entity fade;


  LevelCredits(World _w) {
    super("Final", _w);
  }

  void init() {

      super.init();   
      this.world.clock.stop();

      fade = fullScreenFadeBox(world, true);
      addFadeEffect(fade, 6, true);
  }


  void draw() {

    this.world.clock.start();
    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(0, 0, 0);
    fill(48, 166, 109, 200);
    rect(LEFT_X, TOP_Y, 600, 600);


    textAlign(CENTER);
    textSize(75);    
    fill(203, 203, 203, 255);
    text("Chromatophore", 0, TOP_Y + 5, width, height);
    textSize(30);
    text("by Jim Fingal", 0, BOTTOM_Y - 75, width, height);

    super.draw();
  }


  void update(float dt) {
    super.update(dt);
  }

}
class LevelGateway extends Scene {

  int level;

  ArrayList<Scene> levels; 

  Vec2 mouse_gridposition;
  
  int grid_size = 3;
  int cell_size;

  RGB active_fill;

  float oscillation_amount = 70;

  Entity fade;
  boolean transitioning_out = false;

  
  ArrayList<ArrayList<String>> text_interludes = new ArrayList<ArrayList<String>>();

  final TextInterlude last;


  LevelGateway(World _w) {

    super(LEVEL_GATEWAY, _w);
    
    level = 0;
    mouse_gridposition = new Vec2(0, 0);
    cell_size = 600 / grid_size;

    initializeLevels();
    initializeInterludes();

    last = prepareLevelNine();
  }

  void initializeLevels() {

    LevelOne level_one = new LevelOne(world);
    world.scene_manager.addScene(level_one);
   
    LevelTwo level_two = new LevelTwo(world);
    world.scene_manager.addScene(level_two);
 
    LevelThree level_three = new LevelThree(world);
    world.scene_manager.addScene(level_three);

    LevelFour level_four = new LevelFour(world);
    world.scene_manager.addScene(level_four);
  
    LevelFive level_five = new LevelFive(world);
    world.scene_manager.addScene(level_five);
 
    LevelSix level_six = new LevelSix(world);
    world.scene_manager.addScene(level_six);
  
    LevelSeven level_seven = new LevelSeven(world);
    world.scene_manager.addScene(level_seven);
  
    LevelEight level_eight = new LevelEight(world);
    world.scene_manager.addScene(level_eight);


    levels = new ArrayList<Scene>();
    levels.add(level_one);
    levels.add(level_two);
    levels.add(level_three);
    levels.add(level_four);
    levels.add(level_five);
    levels.add(level_six);
    levels.add(level_seven);
    levels.add(level_eight);

  }

  void update(float dt) {


    ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
    schedule_system.update(dt);

    TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);
    tween_system.update(dt);

    mouse_gridposition.x = constrain(floor((mouseX - LEFT_X)/cell_size), 0, grid_size - 1);
    mouse_gridposition.y = constrain(floor((mouseY - TOP_Y)/cell_size), 0, grid_size - 1);

  }

  void enter() {    
    // super.enter();
    world.resetEntities();
    level++;
    active_fill = new RGB(255 - level * (255 / 8), 255 - level * (255 / 8), 255 - level * (255 / 8), 255);
    fade = fullScreenFadeBox(world, true);
    addFadeEffect(fade, 3, true);
    transitioning_out = false;
  }

  void draw() {

    background(255 - (level * (255 / 9)), 255 - (level * (255 / 9)), 255 - (level * (255 / 9)), 255);

    textSize(80);
    
    for (int i = 0; i < 9; i++) {

      if (i + 1 == this.level) {

        if (mousePosToLevel() == level) {
          if (i < 8) {
            // fill(200, 200, 0, 100);
            fill(185, 209, 61, 200);
          } else {
            fill(221, 61, 58, 200);
          }
        } else {
          float diff = sin(this.world.clock.total_time) * oscillation_amount;
          fill(active_fill.r + diff, active_fill.b + diff, active_fill.g + diff, 255);
        }

      } else if (i + 1 < this.level) {
        fill(48, 166, 109, 200);
      } else {
        fill(255 - i * (255 / 8), 255 - i * (255 / 8), 255 - i * (255 / 8), 255);
      }
      rect(LEFT_X + ((i * 200) % 600), TOP_Y + yVal(i), 200, 200);
    }

    fill(0, 255, 255, 255);
    //text(mouse_gridposition.toString(), 20, 340);
    //text(mousePosToLevel(), 20, 440);


    RenderingSystem rendering_system = (RenderingSystem) this.world.getSystem(RENDERING_SYSTEM);
    rendering_system.drawDrawables();

    this.world.updateClock();
    this.update(this.world.clock.dt);

  }

  int yVal(int i) {

    if (i <= 2) {
      return 0;
    } else if (i <= 5) {
      return 200;
    } else {
      return 400;
    }

  }




  boolean checkWinCondition() {
    return level >= 9;
  }

  void mouseClicked() {
      if (mousePosToLevel() == level) {
        triggerTransition(level - 1);
      }
  }

  int mousePosToLevel() {
    return int((mouse_gridposition.x + 1) + (mouse_gridposition.y) * 3);
  }

  void triggerTransition(final int level) {
    if (!transitioning_out) {
      transitioning_out = true;

      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false);

      if (level < 8) {

        final Scene level_to = levels.get(level);
        final TextInterlude interlude = new TextInterlude(world, text_interludes.get(level), 4.5, level_to);
        world.scene_manager.addScene(interlude);
        schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(interlude);
                                  world.removeEntity(fade);
                                }
                              }, 3.1);
      } else {

        
        schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(last);
                                  world.removeEntity(fade);
                                }
                              }, 3.1);

      }

     


    }
  }

  void initializeInterludes() {

    ArrayList<String> interlude_one = new ArrayList<String>();
    interlude_one.add("1. It is said that Prometheus stole fire from the gods and gave it to man,");
    interlude_one.add("receiving eternal agony for his offense.");
    interlude_one.add("");
    interlude_one.add("A spiteful creature, man did everything he could to extinguish fire");
    interlude_one.add("from the earth and plunge himself back into darkness.");

    text_interludes.add(interlude_one);

    ArrayList<String> interlude_two = new ArrayList<String>();

    interlude_two.add("2. One never steps into the same lava flow twice.");
    interlude_two.add("");
    interlude_two.add("The changing of rules and the systems that underlie them is the best we can rely on.");

    text_interludes.add(interlude_two);

    ArrayList<String> interlude_three = new ArrayList<String>();

    interlude_three.add("3. A dark moon, I find that I am unable to escape my elliptical orbit around you.");
    interlude_three.add("");
    interlude_three.add("One day we will collide and share our first extinction event.");

    text_interludes.add(interlude_three);

    ArrayList<String> interlude_four = new ArrayList<String>();

    interlude_four.add("4. Coleoid cephalopods have complex multicellular organs which they use to change color rapidly. ");
    interlude_four.add("This is most notable in brightly colored squid, cuttlefish and octopuses. ");
    interlude_four.add("Like chameleons, cephalopods use physiological color change for social interaction.");
    interlude_four.add("They are also among the most skilled at background adaptation, having the ability to match both the color and the texture of their local environment with remarkable accuracy.");
    text_interludes.add(interlude_four);

    ArrayList<String> interlude_five = new ArrayList<String>();

    interlude_five.add("5. With each generation of hardware, we add extra bits and the palette of representable colors rises.");
    interlude_five.add("We measure this in terms of color depth of a pixel.");
    interlude_five.add("Deep color contains more than a billion distinct colors.");
    interlude_five.add("Dither is an intentionally applied form of noise used to randomize quantization error, preventing large-scale patterns such as color banding in images.");
    interlude_five.add("");
    interlude_five.add("These days, it’s rare to not feel out of my depth.");

    text_interludes.add(interlude_five);

    ArrayList<String> interlude_six = new ArrayList<String>();
    interlude_six.add("6. In Greek mythology, Proteus is an early sea-god or god of rivers and oceanic bodies of water.");
    interlude_six.add("Some who ascribe to him a specific domain call him the god of 'elusive sea change,' which suggests the constantly changing nature of the sea or the liquid quality of water in general.");
    interlude_six.add("");
    interlude_six.add("He can foretell the future, but, in a mytheme familiar to several cultures, will change his shape to avoid having to.");
    interlude_six.add("From this feature of Proteus comes the adjective 'protean,' with the general meaning of 'versatile,' 'mutable,' 'capable of assuming many forms.'");
    interlude_six.add("");

    text_interludes.add(interlude_six);

    ArrayList<String> interlude_seven = new ArrayList<String>();
    interlude_seven.add("7. At this point, the individual faces a choice: sink into despair and");
    interlude_seven.add("resignation, or take a leap of faith toward what Jaspers calls");
    interlude_seven.add("'Transcendence.'");
    interlude_seven.add("");
    interlude_seven.add("In making this leap, individuals confront their own limitless freedom, which");
    interlude_seven.add("Jaspers calls 'Existenz,' and can finally experience authentic existence.");
    text_interludes.add(interlude_seven);

    ArrayList<String> interlude_eight = new ArrayList<String>();
    interlude_eight.add("8. SPEGEL: I have prayed just one prayer in my life. Use me. Handle me.");
    interlude_eight.add("But God never understood what a strong and devoted slave I had become. So I had to go unused.");
    interlude_eight.add("(Pause)");
    interlude_eight.add("Incidentally, that is also a lie.");
    interlude_eight.add("(Pause)");
    interlude_eight.add("One walks step by step into the darkness. The motion itself is the only truth.");
    text_interludes.add(interlude_eight);

  }

  TextInterlude prepareLevelNine() {


    ArrayList<String> interlude_nine_one = new ArrayList<String>();
    interlude_nine_one.add("9.1");
    interlude_nine_one.add("In 1984, Beckett went to the funeral of long-time friend Robert Blin.");
    interlude_nine_one.add("Sitting in the crematorium of Père Lachaise, the sound of the cracking of the bones within the incinerator filled the quiet room.");
    interlude_nine_one.add("");
    interlude_nine_one.add("The sound of the bones was to haunt him for years to come.");

    ArrayList<String> interlude_nine_two = new ArrayList<String>();
    interlude_nine_two.add("9.2");
    interlude_nine_two.add("Exhibit one: “Old earth, no more lies, I’ve seen you, it was me, with my other’s ravening eyes, too late.”");
    interlude_nine_two.add("");

    ArrayList<String> interlude_nine_three = new ArrayList<String>();
    interlude_nine_three.add("9.3");
    interlude_nine_three.add("Exhibit two: “But who knows the fate of his bones, or how often he is to be buried? Who hath the oracle of his ashes, or whither they are to be scattered?”");
    interlude_nine_three.add("");

    ArrayList<String> interlude_nine_four = new ArrayList<String>();
    interlude_nine_four.add("9.4");
    interlude_nine_four.add("Exhibit three: “Ah to love at your last and see them at theirs, the last minute loved ones, and be happy, why ah, uncalled for.”");
    interlude_nine_four.add("");

    ArrayList<String> interlude_nine_five = new ArrayList<String>();
    interlude_nine_five.add("9.5");
     interlude_nine_five.add("For all my willingness to change, I find it most difficult to accept this final one.");
    interlude_nine_five.add("What I could never live with is if things ended before I was finished.");
    interlude_nine_five.add("");

    TextInterlude i5 = new TextInterlude(world, interlude_nine_five, 4.0, credits);
    TextInterlude i4 = new TextInterlude(world, interlude_nine_four, 4.0, i5);
    TextInterlude i3 = new TextInterlude(world, interlude_nine_three, 4.0, i4);
    TextInterlude i2 = new TextInterlude(world, interlude_nine_two, 4.0, i3);
    TextInterlude i1 = new TextInterlude(world, interlude_nine_one, 4.0, i2);

    world.scene_manager.addScene(i1);
    world.scene_manager.addScene(i2);
    world.scene_manager.addScene(i3);
    world.scene_manager.addScene(i4);
    world.scene_manager.addScene(i5);
    return i1;


  }

}

class LevelTitle extends BaseScene {

  float start = 0;
  boolean fadein = false;
  boolean fadeout = false;

  PImage background_image;

  AudioPlayer chimes;
  Entity fade;


  LevelTitle(World _w) {
    super(LEVEL_TITLE, _w);
  }

  void init() {
      super.init();   
      this.world.clock.stop();

      background_image = loadImage("title.png");

      fade = fullScreenFadeBox(world, true);

      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { addFadeEffect(fade, 3, true); 
                                    printDebug("Running fade in effect");
                                }
                              }, 1.5);
      schedule_system.doAfter(new ScheduleEntry() {   
                                public void run() { 
                                  addFadeEffect(fade, 5, false);
                                    printDebug("Running fade in effect");

                                }
                              }, 6.5);

      final LevelGateway gwy = gateway;
      schedule_system.doAfter(new ScheduleEntry() { public void run() {  world.scene_manager.setCurrentScene(gwy); } } , 12);

  }


  void draw() {

    this.world.clock.start();
    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(63, 63, 63);
    image(background_image, 0, 0);

    textSize(75);    
    // fill(zbc[2], zbc[1], zbc[0], 255);
    fill(255, 255, 255, 255);
    text("Chromatophore", 40, 140);

    textSize(30);
    text("by Jim Fingal", 80, 240);

    super.draw();
  }


  void update(float dt) {
    super.update(dt);
  }

}
Vec2 center = new Vec2(480, 320);

class BaseScene extends Scene {

  boolean won;
  float win_time = 0;


	BaseScene(String _name, World _w) {
		super(_name, _w);
    won = false;

	}

	void update(float dt) {

	  TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);
	  tween_system.update(dt);

	  InputSystem input_system = (InputSystem) this.world.getSystem(INPUT_SYSTEM);
	  input_system.updateInputs(dt);

	  BehaviorSystem behavior_system = (BehaviorSystem) this.world.getSystem(BEHAVIOR_SYSTEM);
	  behavior_system.updateBehaviors(dt);

	  MovementSystem movement_system = (MovementSystem) this.world.getSystem(MOVEMENT_SYSTEM);
	  movement_system.updateMovables(dt);

    ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
    schedule_system.update(dt);

    // Handle Collisions in child class

	}

	void draw() {

    // Extended class responsible for updating
		RenderingSystem rendering_system = (RenderingSystem) this.world.getSystem(RENDERING_SYSTEM);
		rendering_system.drawDrawables();

	}

}


class TextInterlude extends BaseScene {

  final ArrayList<String> text_array;
  final float line_delay;
  final Scene next_scene;

  TextInterlude(World _w, ArrayList<String> text_array, float line_delay, Scene next_scene) {
    super(text_array.get(0), _w);
    this.text_array = text_array;
    this.line_delay = line_delay;
    this.next_scene = next_scene;
  }

  void init() {

    this.world.updateClock();
    this.world.clock.stop();
    ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);

    float cumulative_delay = 0.01f;
    for (int i = 0; i < text_array.size(); i++) {

      Entity text_entity = getTextEntity(text_array.get(i), 30, 30 + (i * height / text_array.size()),  width - 60, height - 60, 24,  new RGB(203, 203, 203, 0));

      this.scheduleAhead(text_entity, this.line_delay, cumulative_delay);

      cumulative_delay +=  3 * this.line_delay / 4.0;

    }

    
    schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() {
                                  Entity fade = fullScreenFadeBox(world, false);
                                  addFadeEffect(fade, 4.0, false);
                                }
                              }, cumulative_delay + 2);

    schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() {
                                  world.resetEntities();
                                  world.scene_manager.setCurrentScene(next_scene);
                                }
                              }, cumulative_delay + 10);

  }

  void scheduleAhead(final Entity txt, float fade_length, float delay_length) {
    
    final float fl = fade_length;
    final float dl = delay_length;

    ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
    schedule_system.doAfter(new ScheduleEntry() {   
                                public void run() { 
                                  addFadeEffect(txt, fl, false);
                                }
                              }, dl);
  }

  void update(float dt) {

    super.update(dt);

  }

  void draw() {

    this.world.clock.start();

    background(0, 0, 0);

    super.draw();

    this.world.updateClock();
    this.update(this.world.clock.dt);

  }


}





void collidePlayerAgainstWalls(ArrayList<CollisionPair> collisions, boolean bounce) {
    collidePlayerAgainstWalls(collisions, bounce, null);
}


void collidePlayerAgainstWalls(ArrayList<CollisionPair> collisions, boolean bounce, RGB world_color) {

  if (collisions.size() > 0) {
      //printDebug("Detected collisions: " + collisions.size());

      for (CollisionPair p : collisions) {

        if (p.a == world.getTaggedEntity(TAG_PLAYER)) {

          Entity player = p.a;
          Transform t = (Transform) player.getComponent(TRANSFORM);
          Shape player_shape = ((ShapeComponent) player.getComponent(SHAPE)).shape;
          Motion m = (Motion) player.getComponent(MOTION);

          if (p.b == world.getTaggedEntity(TAG_WALL_LEFT)) {

            //printDebug("Collided: PLAYER and LEFT WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;
            
            if (bounce) {
              m.velocity.x = -m.velocity.x;
            }

            if (player_shape instanceof Circle) {
              t.pos.x = wall.pos.x + wall.width + ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.x = wall.pos.x + wall.width;
            }

            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }


          } else if (p.b == world.getTaggedEntity(TAG_WALL_RIGHT)) {
            //printDebug("Collided: PLAYER and RIGHT WALL");

            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.x = -m.velocity.x;
            }

            if (player_shape instanceof Circle) {
              t.pos.x = wall.pos.x - ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.x = wall.pos.x - ((Rectangle) player_shape).width;

            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }

          } else if (p.b == world.getTaggedEntity(TAG_WALL_TOP)) {

           // printDebug("Collided: PLAYER and TOP WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.y = -m.velocity.y;
            }

            if (player_shape instanceof Circle) {
              t.pos.y = wall.pos.y + wall.height + ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.y = wall.pos.y + wall.height;
            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }

          } else if (p.b == world.getTaggedEntity(TAG_WALL_BOTTOM)) {

            // printDebug("Collided: PLAYER and BOTTOM WALL");
            Rectangle wall = (Rectangle) ((ShapeComponent) p.b.getComponent(SHAPE)).shape;

            if (bounce) {
              m.velocity.y = -m.velocity.y;
            }

            if (player_shape instanceof Circle) {
              t.pos.y = wall.pos.y - ((Circle) player_shape).radius;
            } else if (player_shape instanceof Rectangle) {
              t.pos.y = wall.pos.y - ((Rectangle) player_shape).height;
            }


            if (world_color != null) {
              world_color.r +=40;
              world_color.b -=10;
              world_color.g -=10;
            }

          }

        }

      }
    }

}

final int TOP_Y = 20;
final int BOTTOM_Y = 620;
final int LEFT_X = 180;
final int RIGHT_X = 780;

Entity setUpSpringMount(World world, int x, int y, float mass) {

    Entity mount = world.entity_manager.newEntity();
    Transform t = new Transform(x, y);
    mount.addComponent(t);

    Physics p = new Physics(mass);
    mount.addComponent(p);

    Motion m = new Motion();
    m.max_speed = 0;
    mount.addComponent(m);

    final Shape mount_shape = new Circle(t.pos, 1).setColor(new RGB(255, 0, 0, 255));
    mount.addComponent(new ShapeComponent(mount_shape, 0));

    world.tagEntity(mount, TAG_SPRING_MOUNT);

    return mount;

}

Entity fullScreenFadeBox(World world, boolean fade_in) {

    Entity fade = world.entity_manager.newEntity();
    Transform t = new Transform(0, 0);
    fade.addComponent(t);

    final Shape fade_shape = new Rectangle(t.pos, width, height);
    final RGB fade_color = new RGB(0, 0, 0, 254);
    if (!fade_in) {
        fade_color.a = 1;
    }
    fade_shape.setColor(fade_color);

    fade.addComponent(new ShapeComponent(fade_shape, 0));

    return fade;

}

Entity getTextEntity(String content, int x, int y, int w, int h, int text_size, IColor c) {

    Entity text_entity = world.entity_manager.newEntity();
    Transform t = new Transform(x, y);
    text_entity.addComponent(t);

    final Shape text_shape = new TextBox(t.pos, w, h, content, text_size).setColor(c);
    text_entity.addComponent(new ShapeComponent(text_shape, 1));

    return text_entity;

}

void addFadeEffect(Entity e, float fade_length, boolean fade_in) {
    
    TweenSystem tween_system = (TweenSystem) world.getSystem(TWEEN_SYSTEM);

    ShapeComponent shape_component = (ShapeComponent) e.getComponent(SHAPE);

    final RGB fade_color = (RGB) (shape_component.shape.getColor());

    if (fade_in) {

        tween_system.addTween(fade_length, new TweenVariable() {
                              public float initial() {           
                                return fade_color.a; }
                              public void setValue(float value) { 
                                fade_color.a = int(value); 
                              }  
                          }, 1, EasingFunctions.linear);
       
    } else {

         tween_system.addTween(fade_length, new TweenVariable() {
                              public float initial() {           
                                return fade_color.a; }
                              public void setValue(float value) { 
                                fade_color.a = int(value); 
                              }  
                          }, 254, EasingFunctions.linear);
    }
}

void addVolumeFader(final Controller player, float fade_length, boolean fade_in) {
    
    TweenSystem tween_system = (TweenSystem) world.getSystem(TWEEN_SYSTEM);

    TweenVariable gain_fader = new TweenVariable() {
                              public float initial() {           
                                return player.getGain(); }
                              public void setValue(float value) { 
                                player.setGain(value); 
                              }  
                          };

    TweenVariable volume_fader = new TweenVariable() {
                              public float initial() {           
                                return player.getVolume(); }
                              public void setValue(float value) { 
                                player.setVolume(value); 
                              }  
                          };
    if (fade_in) {
        tween_system.addTween(fade_length, gain_fader, 0, EasingFunctions.inCubic);
        tween_system.addTween(fade_length, volume_fader, 1, EasingFunctions.inCubic);

    } else {
        tween_system.addTween(fade_length, gain_fader, -30, EasingFunctions.inCubic);
        tween_system.addTween(fade_length, volume_fader, 0, EasingFunctions.inCubic);

    }
}



void setUpPlatform(World world, int x, int y, int w, int h, IColor c) {

    Entity platform = createRectangle(world, x, y, w, h, c);
    
    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    world.tagEntity(platform, TAG_PLATFORM);

    cs.watchCollision(player, platform);

}

void setUpWalls(World world, IColor c) {

    Entity left = createRectangle(world, 0, 0, 180, 640, c);
    Entity right = createRectangle(world, 780, 0, 180, 640, c);
    Entity top = createRectangle(world, 0, 0, 960, 20, c);
    Entity bottom = createRectangle(world, 0, 620, 960, 20, c);

    world.tagEntity(left, TAG_WALL_LEFT);
    world.tagEntity(right, TAG_WALL_RIGHT);
    world.tagEntity(top, TAG_WALL_TOP);
    world.tagEntity(bottom, TAG_WALL_BOTTOM);

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    cs.watchCollision(player, left);
    cs.watchCollision(player, right);
    cs.watchCollision(player, top);
    cs.watchCollision(player, bottom);
}

Entity createRectangle(World world, int x, int y, int w, int h, IColor c) {

    final Entity rectangle = world.entity_manager.newEntity();
    Transform rt = new Transform(x, y);
    rectangle.addComponent(rt);

    final Shape rectangle_shape = new Rectangle(rt.pos, w, h).setColor(c);
    rectangle.addComponent(new ShapeComponent(rectangle_shape, 2));

    // rectangle.addComponent(new RenderingComponent().addDrawable(rectangle_shape, 1));
    // rectangle.addComponent(new Collider(rectangle_shape));

    return rectangle;
}

Entity createCircle(World world, int x, int y, int radius, IColor c) {

    final Entity circle = world.entity_manager.newEntity();
    Transform t = new Transform(x, y);
    circle.addComponent(t);

    final Shape circle_shape = new Circle(t.pos, radius).setColor(c);
    circle.addComponent(new ShapeComponent(circle_shape, 2));

   return circle;

}

void setUpCollectables(World world, int num, IColor c) {
    setUpCollectables(world, num, c, false);
}

void setUpCollectables(World world, int num, IColor c, boolean do_rotate) {

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    for (int i = 0; i < num; i++) {

        Entity collectable = createRectangle(world, randomint(185, 775), randomint(25, 615), 6, 6, c);
        world.group_manager.addEntityToGroup(collectable, GROUP_COLLECTABLES);
        cs.watchCollision(player, collectable);

        if (do_rotate) {
            addRotationBehavior(collectable);
        }

    }

}

void addRotationBehavior(final Entity e) {

    Behavior b = new Behavior();

    b.addBehavior(new BehaviorCallback() {
        public void update(float dt) {
            Transform t = (Transform) e.getComponent(TRANSFORM);
            t.rotate(dt * 5);
        }
    });

    e.addComponent(b);

}

Entity setUpMovingShooter(final World world, int x, int y, final float rotation, final float speed, final IColor c, final int ticks) {

    final Entity emitter = setUpShooter(world, x, y, rotation, speed, c, ticks);

    final Transform t = (Transform) emitter.getComponent(TRANSFORM);

    IColor emitter_col = new RGB(zbc[0], zbc[0], zbc[0], 180);
    final Shape circle_shape = new Circle(t.pos, 4).setColor(emitter_col);
    emitter.addComponent(new ShapeComponent(circle_shape, 2));


    Behavior b = (Behavior) emitter.getComponent(BEHAVIOR);


    final Motion motion = new Motion();
    emitter.addComponent(motion);
    motion.max_speed = 500;
    //motion.damping = .98;
    motion.acceleration.x = 5;
    motion.acceleration.y = 5;

     b.addBehavior(new BehaviorCallback() {
      public void update(float dt) {

        if (t.pos.x <= LEFT_X) {
          t.pos.x = RIGHT_X;
        }

        if (t.pos.x >= RIGHT_X) {
          t.pos.x = LEFT_X;
        }

        if (t.pos.y <= TOP_Y) {
          t.pos.y = BOTTOM_Y;
        }

        if (t.pos.y >= BOTTOM_Y) {
          t.pos.y = TOP_Y;
        }
      }
  });

     b.addBehavior(new BehaviorCallback() {

        float clock = 0;
          public void update(float dt) {
            clock+= dt;
            t.pos.x += cos(clock);
            t.pos.y += cos(clock);

          }
    });


     return emitter;

}

Entity setUpShooter(final World world, int x, int y, final float rotation, final float speed, final IColor c, final int ticks) {

    final Entity emitter = world.entity_manager.newEntity();


    final Transform t = new Transform(x, y);
    t.rotateTo(rotation);

    emitter.addComponent(t);

    final BulletPool bullets = new BulletPool(80, t, world, speed, c);

    Behavior b = new Behavior();

    // Rotate Emitter
    b.addBehavior(new BehaviorCallback() {
        public void update(float dt) {
            // printDebug("rotating");
            t.rotate(dt);
       }
    });

    // Emit stuff
    b.addBehavior(new BehaviorCallback() {
        public void update(float dt) {
            // printDebug("creating bullet");


            if (world.clock.ticks % ticks == 0) {
                Entity bullet = bullets.getPoolObject();

                if (bullet != null) {
                    Transform bt = (Transform) bullet.getComponent(TRANSFORM);
                    bt.pos.x = int(t.pos.x);
                    bt.pos.y = int(t.pos.y);
                    bt.rotateTo(t.getRotation());

                    Motion m = (Motion)  bullet.getComponent(MOTION);
                    m.velocity.x = speed;
                    m.velocity.y = 0;
                    m.velocity.rotate(t.getRotation());
                }
            }
       }
    });

    emitter.addComponent(b);

    return emitter;
}

// TODO pool
Entity createBullet(final World world, int x, int y, float rotation, float speed, IColor c, final BulletPool p) {

    final Entity bullet = createCircle(world, x, y, 3, c);

    Motion motion = new Motion();
    bullet.addComponent(motion);
    motion.velocity.x = speed;
    motion.velocity.rotate(rotation);


    Behavior b = new Behavior();

    b.addBehavior(new BehaviorCallback() {
        public void update(float dt) {

            Transform t = (Transform) bullet.getComponent(TRANSFORM);
    
            if (t.pos.x < LEFT_X || t.pos.x > RIGHT_X || t.pos.y < TOP_Y || t.pos.y > BOTTOM_Y) {
                // printDebug("Giving back bullet");
                p.giveBack(bullet);
                // printDebug("Should now be inactive: " + bullet.active);

            }
       }
    });


    bullet.addComponent(b);

    PoolComponent pc = new PoolComponent(p);
    bullet.addComponent(pc);

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);
    cs.watchCollision(player, bullet);

    world.group_manager.addEntityToGroup(bullet, GROUP_BULLETS);

    return bullet;
}




 class BulletPool extends Pool<Entity> {

        Transform t;
        float speed;
        IColor c;
        World world;


        BulletPool(int size, Transform t, World world, float speed, IColor c) {
            super(size);
            this.t = t;
            this.speed = speed;
            this.c = c;
            this.world = world;
        }

        protected Entity createObject() {
            return createBullet(world, int(t.pos.x), int(t.pos.y), t.getRotation(), speed, c, this);
        }

        protected void recycleObject(Entity object) {
            object.active = false;
        }

        protected void enableObject(Entity object) {
            object.active = true;
        }

        public Entity getPoolObject() {

            Entity obj = null;

            if (available.size() > 0) {
                obj = available.get(0);
                available.remove(obj);
                used.add(obj);
                enableObject(obj);
            } else if (used.size() < max_size) {
                obj = createObject();
                used.add(obj);
            }

            return obj;
        }

        public void giveBack(Entity object) {
            recycleObject(object);
            used.remove(object);
            available.add(object);
        }
    };




 class PlayerUtils {

	Entity getNewPlayerEntity(World world) {

	  Entity player = world.entity_manager.newEntity();
	  world.tagEntity(player, TAG_PLAYER);
	  return player;

	}

	void addRectangleShape(Entity player, int x, int y, int w, int h, IColor c) {

	  	Transform t = new Transform(x, y);
	  	player.addComponent(t);

		final Shape player_shape = new Rectangle(t.pos, w, h).setColor(c);
	 	player.addComponent(new ShapeComponent(player_shape, 0));

	}


	void addCircleShape(Entity player, int x, int y, int radius, IColor c) {

	  	Transform t = new Transform(x, y);
	  	player.addComponent(t);

		final Shape player_shape = new Circle(t.pos, radius).setColor(c);
	 	player.addComponent(new ShapeComponent(player_shape, 1));

	}

	void addPhysics(Entity player, float mass) {

	  	Physics p = new Physics(mass);
	  	player.addComponent(p);

	}

	void addMotion(Entity player, int max_speed, int drag_x, int drag_y, float damping) {

	  	  Motion m = new Motion();
		  m.max_speed = max_speed;
		  m.drag.x = drag_x;
		  m.drag.y = drag_y;
		  m.damping = damping;

		  player.addComponent(m);

	}

	void addGravity(Entity player, int x, int y) {

	  	  Gravity g = new Gravity(x, y);
		  player.addComponent(g);

	}

	void addSpaceshipMovement(final Entity player, final int responsiveness) {

		InputResponse r = new InputResponse(); 

  		r.addInputResponseFunction(new InputResponseFunction() {
      		
      		public void update(InputSystem input_system) {

		        Motion m = (Motion) player.getComponent(MOTION);

		          if (input_system.actionHeld(ACTION_UP)) {
		            if (m.velocity.y >= 0) {
		               m.velocity.y = 0;
		            }
		            m.velocity.y -= responsiveness;

		            // printDebug("Action Held: UP");
		          } else if (input_system.actionHeld(ACTION_DOWN)) {
		            
		            if (m.velocity.y <= 0) {
		              m.velocity.y = 0;
		            }
		             m.velocity.y += responsiveness;

		            // printDebug("Action Held: DOWN");

		          }

		          if (input_system.actionHeld(ACTION_LEFT)) {
		            if (m.velocity.x >= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x -= responsiveness;
		            // printDebug("Action Held: LEFT");

		          } else if (input_system.actionHeld(ACTION_RIGHT)) {
		            if (m.velocity.x <= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x += responsiveness;
		            // printDebug("Action Held: RIGHT");

		          }

		      }
	  });

	  player.addComponent(r);

	}

	void addSpaceshipMovementRandomControls(final Entity player, final int responsiveness) {

		InputResponse r = new InputResponse(); 

		final ArrayList<MotionChanger> motions = new ArrayList<MotionChanger>();

		motions.add(new MotionChanger() {
			public void updateMotion(Motion m) {
				 if (m.velocity.y >= 0) {
	               m.velocity.y = 0;
	            }
	            m.velocity.y -= responsiveness;
	            printDebug("Moving down");
			}
		});

		motions.add(new MotionChanger() {
			public 	void updateMotion(Motion m) {
					if (m.velocity.y <= 0) {
	              m.velocity.y = 0;
	            }
	            m.velocity.y += responsiveness;
	            printDebug("Moving up");

				}
			});

			motions.add(new MotionChanger() {
				public void updateMotion(Motion m) {
					if (m.velocity.x >= 0) {
	              m.velocity.x = 0;
	            }
	            m.velocity.x -= responsiveness;
	           	printDebug("Moving left");

				}
			});

			motions.add(new MotionChanger() {
				public void updateMotion(Motion m) {
				if (m.velocity.x <= 0) {
	              m.velocity.x = 0;
	            }
	            m.velocity.x += responsiveness;
	           	printDebug("Moving Right");
				}
			});

		final HashMap<String, Integer> action_maps = new HashMap<String, Integer>();

		final ArrayList<String> actions = new ArrayList<String>();
		actions.add(ACTION_UP);
		actions.add(ACTION_RIGHT);
		actions.add(ACTION_DOWN);
		actions.add(ACTION_LEFT);

  		r.addInputResponseFunction(new InputResponseFunction() {

  			int current_index = 0;

      		public void update(InputSystem input_system) {

      			Motion m = (Motion) player.getComponent(MOTION);

      			for (int i = 0; i < actions.size(); i++) {
      				String a = actions.get(i);
      				if (input_system.actionPressed(a)) {
      					action_maps.put(a, current_index);
      					printDebug("Mapping action " + a + " to impact " + i);

      					current_index++;
      					if (current_index >= actions.size()) {
      						current_index = 0;
      					}

      				} else if (action_maps.containsKey(a) && !input_system.actionHeld(a)) {
      					action_maps.remove(a);
      					printDebug("Released action " + a);

      				}

      				if (input_system.actionHeld(a)) {
      					MotionChanger motion_changer = motions.get(action_maps.get(a));
      					motion_changer.updateMotion(m);
      				}
      			}

		     }
	  });

	  player.addComponent(r);

	}



	void addForceMovement(final Entity player, final float force) {

		InputResponse r = new InputResponse(); 

  		r.addInputResponseFunction(new InputResponseFunction() {
      		
      		public void update(InputSystem input_system) {

		        Physics p = (Physics) player.getComponent(PHYSICS);

		        boolean up_or_down = false;
		        boolean left_or_right = false;

		        if (input_system.actionHeld(ACTION_UP)) {

		          	p.applyForce(0, -force);
		          	up_or_down = true;
	
		        } else if (input_system.actionHeld(ACTION_DOWN)) {
		            
		           	p.applyForce(0, force);
		          	up_or_down = true;

		          } 

		          if (input_system.actionHeld(ACTION_LEFT)) {

		           	p.applyForce(-force, 0);
		           	left_or_right = true;

		          } else if (input_system.actionHeld(ACTION_RIGHT)) {
		           	
		           	p.applyForce(force, 0);
		          	left_or_right = true;
		          }

		          if (up_or_down && left_or_right) {
		          	p.normalizeForces(force);
		          }

		      }
	  });

	  player.addComponent(r);

	}


	void addPlatformerMovement(final Entity player, final int responsiveness, final int jump_power) {

		InputResponse r = new InputResponse(); 

		final AudioPlayer jump = audio_manager.getSound(SOUND_L2JUMP);

  		r.addInputResponseFunction(new InputResponseFunction() {
      		


      		public void update(InputSystem input_system) {

      			if (!jump.isPlaying()) {
			      jump.rewind();
			    }
		        Motion m = (Motion) player.getComponent(MOTION);

		          if (input_system.actionHeld(ACTION_UP)) {
		            
		            Jumper j = (Jumper) player.getComponent(JUMPER);

		            if (j.jumpable) {

		            	if (m.velocity.y >= 0) {
		               		m.velocity.y = 0;
		            	}
		            	m.velocity.y -= jump_power;

		            	j.jumpable = false;
		            	jump.play();
					}
		          } 

		          if (input_system.actionHeld(ACTION_LEFT)) {
		            if (m.velocity.x >= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x -= responsiveness;
		            // printDebug("Action Held: LEFT");

		          } else if (input_system.actionHeld(ACTION_RIGHT)) {
		            if (m.velocity.x <= 0) {
		              m.velocity.x = 0;
		            }
		              m.velocity.x += responsiveness;
		            // printDebug("Action Held: RIGHT");

		          }

		      }
	  });

	  player.addComponent(r);

	  player.addComponent(new Jumper());
	}


	void addConstrainToWorldBehavior(final Entity player) {
		Behavior b = new Behavior();

		  b.addBehavior(new BehaviorCallback() {
		      public void update(float dt) {
		        Transform t = (Transform) player.getComponent(TRANSFORM);

		        if (t.pos.x <= LEFT_X) {
		          t.pos.x = LEFT_X;
		        }

		        if (t.pos.x >= RIGHT_X) {
		          t.pos.x = RIGHT_X;
		        }

		        if (t.pos.y <= TOP_Y) {
		          t.pos.y = TOP_Y;
		        }

		        if (t.pos.y >= BOTTOM_Y) {
		          t.pos.y = BOTTOM_Y;
		        }
		      }
		  });

		  player.addComponent(b);

	}

}

PlayerUtils PLAYER_UTILS = new PlayerUtils();






void setUpPlayer(World world) {

  final Entity player = PLAYER_UTILS.getNewPlayerEntity(world);


  Motion m = new Motion();
  m.max_speed = 500;
  m.drag.x = 200;
  m.drag.y = 200;

  player.addComponent(m);


 

//  player.addComponent(new RenderingComponent().addDrawable(player_shape, 0));
// player.addComponent(new Collider(player_shape));

 Behavior b = new Behavior();


  b.addBehavior(new BehaviorCallback() {
      public void update(float dt) {
        Transform t = (Transform) player.getComponent(TRANSFORM);
        Motion m = (Motion) player.getComponent(MOTION);

        if (t.pos.x <= LEFT_X) {
          t.pos.x = LEFT_X;
          m.velocity.x = -m.velocity.x;
        }

        if (t.pos.x >= RIGHT_X) {
          t.pos.x = RIGHT_X;
          m.velocity.x = -m.velocity.x;
        }

        if (t.pos.y <= TOP_Y) {
          t.pos.y = TOP_Y;
          m.velocity.y = -m.velocity.y;
        }

        if (t.pos.y >= BOTTOM_Y) {
          t.pos.y = BOTTOM_Y;
          m.velocity.y = -m.velocity.y;
        }
      }
  });

 // Shift to analagous colors
 
 /* 
 b.addBehavior(new BehaviorCallback() {

      final HSB player_hsb = new HSB(player_shape.getColor().toRaw());
           
      ArrayList<IColor> analagous = new AnalagousHarmony().generate(player_hsb);
      int current = 0;
      HSB next_color = player_hsb;

      int i = 0;
      public void update(float dt) {

        player_shape.setColor(player_hsb);
        
        printDebug("Got here: " + ((HSB) player_shape.clr).h + " , " + next_color.h);

        if (((HSB) player_shape.clr).h == next_color.h) {
          printDebug("Got here: " + ((HSB) player_shape.clr).h + " , " + next_color.h);
          current++;
          if (current >= analagous.size()) {
            i++;
            current = 0;
          }


          next_color = new HSB(analagous.get(current).toRaw());

        
          tween_system.addTween(0.1, new TweenVariable() {
                              public float initial() {           
                                return ((HSB) player_shape.clr).h; }
                              public void setValue(float value) { 
                                ((HSB) player_shape.clr).h = int(value); 
                              }  
                          }, next_color.h, EasingFunctions.linear);
       
        }

      }
  });
  */

  player.addComponent(b);


}

int DEFAULT_WIDTH = 960;
int DEFAULT_HEIGHT = 640;

abstract class Shape implements Drawable, Collidable {

  final Vec2 pos;
  IColor clr;

  // When called with this, we get a final reference pointing
  // to some other vector. Allows us to e.g. have the shape track 
  // a transform's position.
  Shape(Vec2 _position) {
    this.pos = _position;
  }

  Shape(float x, float y) {
    this.pos = new Vec2(x, y);
  }

  Shape setColor(IColor _c) {
    this.clr = _c;
    return this;
  }
  
  IColor getColor() {
    return this.clr;
  }

  public abstract void draw();
  public abstract void drawAroundOrigin();
  public abstract Vec2 centerPosition();

  // public abstract boolean collidesWith(Collidable collidable)

}

class Point extends Shape {

  Point(float x, float y) {
    super(x, y);
  }

  Point(Vec2 _position) {
    super(_position);
  }

  void draw() {
    fill(this.getColor().toRaw());
    point(this.pos.x, this.pos.y);
  }

  void drawAroundOrigin() {
    fill(this.getColor().toRaw());
    point(0, 0);
  }

  String toString() {
      return "Point: (" + this.pos.x + ", " + this.pos.y + ")";
  }

  Vec2 centerPosition() {
    return this.pos;
  }

}


class Rectangle extends Shape  {

  int width; 
  int height;
  private Vec2 center_vec;

  Rectangle(Vec2 pos, int width, int height) {
    super(pos);
    this.width = width;
    this.height = height;
    this.center_vec = new Vec2(pos.x + this.width/2, pos.y + this.height/2);
  }
  Rectangle(float x, float y, int width, int height) {
    super(x, y);
    this.width = width;
    this.height = height;
  }

  void draw() {
    rectMode(CORNER);
    fill(this.getColor().toRaw());
    rect(this.pos.x, this.pos.y, this.width, this.height);
  }

  void drawAroundOrigin() {
    rectMode(CENTER);
    fill(this.getColor().toRaw());
    rect(0, 0, this.width, this.height);
  }


  String toString() {
      return "Rectangle: (" + this.pos.x + ", " + this.pos.y + ", w=" + this.width + " h=" + this.height + ")";
  }

  // Keep one object, recalculate whenever called
  Vec2 centerPosition() {
    this.center_vec.x = this.pos.x + this.width/2;
    this.center_vec.y = this.pos.y + this.height/2;
    return this.center_vec;
  }

}

class Circle extends Shape {

  float radius;

  Circle(float x, float y, float radius) {
    super(x, y);
    this.radius = radius;
  }
  
  Circle(Vec2 pos, float radius) {
    super(pos);
    this.radius = radius;
  }

  void draw() {
    fill(this.getColor().toRaw());
    ellipse(this.pos.x, this.pos.y, this.radius * 2, this.radius * 2);
  }

  void drawAroundOrigin() {
    fill(this.getColor().toRaw());
    ellipse(0, 0, this.radius * 2, this.radius * 2);
  }

   Vec2 centerPosition() {
    return this.pos;
  }

  String toString() {
      return "Circle: (" + this.pos.x + ", " + this.pos.y + ", r= " + this.radius + ")";
  }
  
}





class TextBox extends Rectangle  {

 String content;
 int size;

TextBox(Vec2 pos, int width, int height, String content, int size) {
    super(pos, width, height);
    this.content = content;
    this.size = size;
  }

  void draw() {
    textSize(this.size);    
    fill(this.getColor().toRaw());
    text(this.content, this.pos.x, this.pos.y, this.width, this.height); 
  }

  void drawAroundOrigin() {
    rectMode(CENTER);
    textSize(this.size);    
    fill(this.getColor().toRaw());
    text(this.content, 0, 0, this.width, this.height); 
  }


  String toString() {
      return "Text: (" + this.pos.x + ", " + this.pos.y + ", w=" + this.width + " h=" + this.height + ", text=" + this.content + ", size=" + this.size + " color=" + this.getColor() + ")";
  }


}
String BEHAVIOR_SYSTEM = "BehaviorSystem";

class BehaviorSystem extends System {

  ArrayList<Entity> entity_buffer;
  BehaviorSystem(World w) {
    super(BEHAVIOR_SYSTEM, w);
    entity_buffer = new ArrayList<Entity>();
  }

  void updateBehaviors(float dt) {

    if (this.world.entity_manager.component_store.containsKey(BEHAVIOR)) {

      entity_buffer.clear();

      for (Entity e : this.world.entity_manager.component_store.get(BEHAVIOR).keySet()) {

        if (e.active) {
          // Add to buffer in case behavior causes entity to remove itself
          entity_buffer.add(e);
        }
      }

      for (int i = 0; i < entity_buffer.size(); i++) {

          Behavior b = (Behavior) (entity_buffer.get(i)).getComponent(BEHAVIOR);

          for (BehaviorCallback behavior_callback : b.behaviors) {


            behavior_callback.update(dt);
          }

      }
    }
  }

}
String COLLISION_SYSTEM = "CollisionSystem";

class CollisionSystem extends System {

  ArrayList<CollisionPair> collisions_to_watch;
  Vec2 buffer;

  final ArrayList<CollisionPair> _collisions;

  CollisionSystem(World w) {
    super(COLLISION_SYSTEM, w);
    this.collisions_to_watch = new ArrayList<CollisionPair>();
    this.buffer = new Vec2(0, 0);
    this._collisions = new ArrayList<CollisionPair>();
  }

  CollisionPair watchCollision(Entity a, Entity b) {
    CollisionPair cp = new CollisionPair(a, b);
    this.collisions_to_watch.add(cp);
    return cp;
  }

  void stopWatchingCollision(CollisionPair pair) {
    this.collisions_to_watch.remove(pair);
  }

  void stopWatchingCollisionsFrom(Entity a) {

    for (int i = collisions_to_watch.size() - 1; i >= 0; i --) {
      CollisionPair entry = collisions_to_watch.get(i); 
      if (entry.a == a) {
        collisions_to_watch.remove(i);
      }
    }
  }

  void stopWatchingCollisionsTo(Entity b) {

    for (int i = collisions_to_watch.size() - 1; i >= 0; i --) {
      CollisionPair entry = collisions_to_watch.get(i); 
      if (entry.b == b) {
        collisions_to_watch.remove(i);
      }
    }
  }

  void reset() {
    collisions_to_watch = new ArrayList<CollisionPair>();
  }


  ArrayList<CollisionPair> getCollisions() {

      this._collisions.clear();

      for (CollisionPair pair : collisions_to_watch) {

        ShapeComponent ca = (ShapeComponent) pair.a.getComponent(SHAPE);
        ShapeComponent cb = (ShapeComponent) pair.b.getComponent(SHAPE);

        if (pair.a.active && pair.b.active && 
            ca != null && cb != null && 
            ca.collideable && cb.collideable) {
          if (this.checkCollision(ca.shape, cb.shape)) {
            this._collisions.add(pair);
          }
        }
      }

      return this._collisions;
  }


  // Returns a collision pair if collides, null if not
  Boolean checkCollision(Shape a, Shape b) {

    if (a == b) { 
      return false;
    }

    if (a instanceof Circle) {
      return circleCollision((Circle) a, b);
    } 
    else if (a instanceof Point) {
      return pointCollision((Point) a, b);
    } 
    else if (a instanceof Rectangle) {
      return rectangleCollision((Rectangle) a, b);
    } 
    else {
      // not supported
      return null;
    }
  }

  private Boolean pointCollision(Point pa, Shape b) {

    if (b instanceof Circle) {

      Circle cb = (Circle) b;
      return cb.pos.dist(pa.pos)  < cb.radius;
    } 
    else if (b instanceof Point) {

      Point pb = (Point) b;
      return pa.pos.x == pb.pos.x && pa.pos.y == pb.pos.y;
    } 
    else if (b instanceof Rectangle) {

      Rectangle rb = (Rectangle) b;

      return pa.pos.x > rb.pos.x &&
        pa.pos.x < rb.pos.x + rb.width &&
        pa.pos.y > rb.pos.y &&
        pa.pos.y < rb.pos.y + rb.height;
    } 
    else {
      // not supported
      return null;
    }
  }

  private Boolean rectangleCollision(Rectangle ra, Shape b) {

    if (b instanceof Circle) {

      return circleCollision((Circle) b, (Shape) ra);
    } 
    else if (b instanceof Point) {

       return pointCollision((Point) b, (Shape) ra);

    } 
    else if (b instanceof Rectangle) {

      Rectangle rb = (Rectangle) b;

      // If any of these are true, then they don't intersect, so return "not" of that.
      // 0, 0 is in upper left hand corner.
      return ! (
       // the X coord of my upper right is less than x coord of other upper left
       ra.pos.x + ra.width < rb.pos.x ||
       //  the X coord of other's upper right is less than x coord of my upper left
       rb.pos.x + rb.width < ra.pos.x ||
       // the Y coord of my lower right is less than Y coord of other upper left
       ra.pos.y + ra.height < rb.pos.y  || 
       // the Y coord of other's lower right is less than than Y coord of my upper left
       rb.pos.y  + rb.height < ra.pos.y
       );
    } 
    else {
      // not supported
      return null;
    }
  }

  private Boolean circleCollision(Circle ca, Shape b) {

    if (b instanceof Circle) {

      Circle cb = (Circle) b;
      float added_radii = ca.radius + cb.radius;
      return ca.pos.dist(cb.pos) < added_radii;
    } 
    else if (b instanceof Point) {
      return pointCollision((Point) b, (Shape) ca);
    } 
    else if (b instanceof Rectangle) {

      // From: http://stackoverflow.com/a/1879223
      Rectangle rb = (Rectangle) b;
      // Find closest point
      float closestX = constrain(ca.pos.x, rb.pos.x, rb.pos.x + rb.width);
      float closestY = constrain(ca.pos.y, rb.pos.y, rb.pos.y + rb.height);

      // Check to see if this point is within circle
      return ca.pos.dist(closestX, closestY) < ca.radius;
    } 
    else {
      // not supported
      return null;
    }
  }

}
String MOVEMENT_SYSTEM = "MovementSystem";

class MovementSystem extends System {

  MovementSystem(World w) {
    super(MOVEMENT_SYSTEM, w);
  }

  void updateMovables(float dt) {

    // Bizarre way to get around including Set


   HashMap<Entity, Component> motion_store = this.world.entity_manager.component_store.get(MOTION);

  if (motion_store != null) {
      for (Entity e : motion_store.keySet()) {

        if (e.active) {

          if (this.world.entity_manager.component_store.get(TRANSFORM).containsKey(e)) {

            Transform t = (Transform) e.getComponent(TRANSFORM);
            Motion m = (Motion) e.getComponent(MOTION);

            Gravity g = (Gravity) e.getComponent(GRAVITY);

            if (g != null) {
              this.applySimpleGravity(m, g, dt);
            }

            this.update(t, m, dt);
          }
        }
      }
    }
  }

  void applySimpleGravity(Motion movement, Gravity g, float dt) {
      movement.velocity.y += (g.force.y * dt);
      movement.velocity.x += (g.force.x * dt);
  }

  void update (Transform transform, Motion movement, float dt) {


    if (movement.acceleration.x != 0 || movement.acceleration.y != 0 ) {

      float acceleration_effect_x = movement.acceleration.x * dt;
      float acceleration_effect_y = movement.acceleration.y * dt;

      movement.velocity.x =  movement.velocity.x  + acceleration_effect_x;
      movement.velocity.y =  movement.velocity.y  + acceleration_effect_y;
    
      // printDebug("Velocity before acceleration: " + movement.velocity);
      // printDebug("Acceleration: " + movement.acceleration);
      // printDebug("Velocity after acceleration: " + movement.velocity);
    }


    if (movement.drag.x != 0 || movement.drag.y != 0) {


      float drag_x = movement.drag.x * dt;
      float drag_y = movement.drag.y * dt;

      if (movement.velocity.x > 0) {

        movement.velocity.x = movement.velocity.x - drag_x;

        if (movement.velocity.x < 0) {
          movement.velocity.x = 0;
        }
      } 
      else if (movement.velocity.x < 0) {

        movement.velocity.x = movement.velocity.x + drag_x;

        if (movement.velocity.x > 0) {
          movement.velocity.x = 0;
        }
      }


      if (movement.velocity.y > 0) {

        movement.velocity.y = movement.velocity.y - drag_y;

        if (movement.velocity.y < 0) {
          movement.velocity.y = 0;
        }
      } 
      else if (movement.velocity.y < 0) {

        movement.velocity.y = movement.velocity.y + drag_y;

        if (movement.velocity.y > 0) {
          movement.velocity.y = 0;
        }
      }
    }

    movement.cap();

    if (movement.velocity.x != 0 || movement.velocity.y != 0) {

      float movement_x = movement.velocity.x  * dt;
      float movement_y = movement.velocity.y  * dt;

      transform.move(movement_x, movement_y);
    }

    movement.velocity.x = movement.velocity.x * movement.damping;
    movement.velocity.y = movement.velocity.y * movement.damping;
    
  }
}
String PHYSICS_SYSTEM = "PhysicsSystem";

class PhysicsSystem extends System {

  Vec2 force_buffer;

  PhysicsSystem(World w) {
    super(PHYSICS_SYSTEM, w);
    force_buffer = new Vec2(0, 0);
  }


  void update(float dt) {


    HashMap<Entity, Component> physics_store = this.world.entity_manager.component_store.get(PHYSICS);

    if (physics_store != null) {

      for (Entity e : physics_store.keySet()) {


        if (e.active && this.world.entity_manager.component_store.get(MOTION).containsKey(e)) {

          Physics p = (Physics) physics_store.get(e);
          Motion m = (Motion) e.getComponent(MOTION);


          // In physics system we only accelerate when there are forces on us. Zero out
          m.acceleration.x = 0;
          m.acceleration.y = 0;

          this.applyForces(p, m);
        }
      }
    }
  }

  void applyForces(Physics p, Motion m) {

    force_buffer.x = p.forces.x;
    force_buffer.y = p.forces.y;

    if (force_buffer.x != 0 || force_buffer.y != 0) {

      force_buffer.multiply(p.invmass);

      m.acceleration.add(force_buffer);

      p.clearForces();

      // printDebug("Applying forces: " + force_buffer.x + ", " + force_buffer.y);
      // printDebug("Accelerating object: " + m.acceleration.x + ", " + m.acceleration.y);
    }

  }

}
String RENDERING_SYSTEM = "RenderingSystem";

class RenderingSystem extends System {

  HashMap<Integer, ArrayList<ShapeComponent>> z_tracker;
  HashMap<ShapeComponent, Transform> transforms;

  RenderingSystem(World w) {
    super(RENDERING_SYSTEM, w);
    this.z_tracker = new HashMap<Integer, ArrayList<ShapeComponent>>();
    this.transforms = new HashMap<ShapeComponent, Transform>();
  }

  void drawDrawables() { 

    if (this.world.entity_manager.component_store.containsKey(SHAPE)) {

      // Clear arrays
      for (Integer key :  this.z_tracker.keySet()) {
        this.z_tracker.get(key).clear();
      }

      int min_z = 100000;
      int max_z = -100000;

      // Sort out by layer
      for (Entity e : this.world.entity_manager.component_store.get(SHAPE).keySet()) {

        if (e.active) {
          
          ShapeComponent sc = (ShapeComponent) e.getComponent(SHAPE);
          Transform t = (Transform) e.getComponent(TRANSFORM);

          transforms.put(sc, t);

          int z = sc.z;

          if (!this.z_tracker.containsKey(z)) {
            this.z_tracker.put(z, new ArrayList<ShapeComponent>());
          }

          this.z_tracker.get(z).add(sc);

          if (z < min_z) { 
            min_z = z;
          }
          
          if (z > max_z) { 
            max_z = z;
          }
        }

      }
      
      for (int i = max_z; i >= min_z; i--) {

        if (this.z_tracker.containsKey(i)) {

          for (ShapeComponent sc : this.z_tracker.get(i)) {

             Transform t = transforms.get(sc);
             Shape shape = sc.shape;
            
             if (t.getRotation() == 0) {

                shape.draw();

             } else {
              
                pushMatrix();
                translate(shape.centerPosition().x, shape.centerPosition().y);
                rotate(t.getRotation());
                shape.drawAroundOrigin();
                popMatrix();
              
             }


          }
        }
      }

    }
  }
}

String SCHEDULE_SYSTEM = "ScheduleSystem";

interface ScheduleEntry {
  void run();
}

class ScheduleSystem extends System {

  HashMap<ScheduleEntry, Float> delayed;
  ArrayList<ScheduleEntry> expired;

  ScheduleSystem(World w) {
    super(SCHEDULE_SYSTEM, w);
    delayed = new HashMap<ScheduleEntry, Float>();
    expired = new ArrayList<ScheduleEntry>();
  }

  void doAfter(ScheduleEntry entry, float delay_duration) {

    delayed.put(entry, delay_duration);

  }

  void update(float dt) {

    
    for (ScheduleEntry entry : delayed.keySet()) {
        float remaining_until = delayed.get(entry) - dt; 
        
        if (remaining_until <= 0) {
          entry.run();
          expired.add(entry);
        }  else {
          delayed.put(entry, remaining_until);
        }
    }

    for (int i = 0; i < expired.size(); i++) {
      delayed.remove(expired.get(i));
    }

    expired.clear();

  }

}
String SPRING_SYSTEM = "SpringSystem";


class Spring {

  Entity a;
  Entity b;
  float stiffness;
  float damping;
  float target_length;

  Spring(Entity a, Entity b, float stiffness, float damping, float target_length) {
    this.a = a;
    this.b = b;
    this.stiffness = stiffness;
    this.damping = damping;
    this.target_length = target_length;
  }

  String toString() {

    return "Spring: (" + a + " and " + b + 
            ", stiffness: " + this.stiffness + 
            ", damping: " + this.damping + 
            ", target_length: " + this.target_length + ")";
  }

}


class SpringSystem extends System {

  ArrayList<Spring> springs;

  Vec2 point_buffer;
  Vec2 velocity_buffer;
  Vec2 force_buffer;

  SpringSystem(World w) {
    super(SPRING_SYSTEM, w);
    springs = new ArrayList<Spring>();
    point_buffer = new Vec2(0, 0);
    velocity_buffer = new Vec2(0, 0);
    force_buffer = new Vec2(0, 0);
  }

  void addSpring(Entity a, Entity b, float stiffness, float damping, float target_length) {
    Spring s = new Spring(a, b, stiffness, damping, target_length);
    springs.add(s);
  }

  void update(float dt) {

     for (int i = 0; i < 5; i++) {
      for (Spring s : springs) {
  
          Entity a = s.a;
          Entity b = s.b;
  
          Physics a_physics = (Physics) a.getComponent(PHYSICS);
          Physics b_physics = (Physics) b.getComponent(PHYSICS);
  
          Transform a_transform = (Transform) a.getComponent(TRANSFORM);
          Transform b_transform = (Transform) b.getComponent(TRANSFORM);
  
          Motion a_motion = (Motion) a.getComponent(MOTION);
          Motion b_motion = (Motion) b.getComponent(MOTION);
  
          float len = a_transform.pos.dist(b_transform.pos);    
  
          // Only pull, don't push
  
          if (len >= s.target_length) {
  
              // printDebug("Pulling with spring: " + s);
  
              // TODO: attach to middle. For now just happens to work that it's a circle
              point_buffer.x = a_transform.pos.x - b_transform.pos.x;
              point_buffer.y = a_transform.pos.y - b_transform.pos.y;
  
              point_buffer.divide(len);
              point_buffer.multiply(len - s.target_length);
  
              velocity_buffer = b_motion.velocity.subtract(a_motion.velocity);
  
              force_buffer.x = point_buffer.x * s.stiffness - (velocity_buffer.x * s.damping);
              force_buffer.y = point_buffer.y * s.stiffness - (velocity_buffer.y * s.damping);
  
              // printDebug("Applying force to first entity: " + force_buffer);
              b_physics.applyForce(force_buffer);
  
              force_buffer.negative();
  
              // printDebug("Applying force to second entity: " + force_buffer);
              a_physics.applyForce(force_buffer);
  
          }
       }

    }


  }

}

String TWEEN_SYSTEM = "TweenSystem";

class TweenSystem extends System {

  HashMap<Tween, TweenVariable> tweens;

  TweenSystem(World w) {
    super(TWEEN_SYSTEM, w);
    tweens = new HashMap<Tween, TweenVariable>();
  }

  void addTween(float dur, TweenVariable variable, float target, Easing easing_function) {

    Tween tween = new Tween(variable.initial(), target, dur, easing_function);
    tweens.put(tween, variable);
  }

  void update(float dt) {

    Tween[] to_remove = new Tween[tweens.size()];
    int index = 0;

    for (Tween tween : tweens.keySet()) {

      TweenVariable variable = tweens.get(tween);

      tween.update(dt);
      variable.setValue(tween.value);

      if (tween.finished()) {
        to_remove[index] = tween;
        index++;
      }
    }

    for (int i = 0; i < index; i++) {
      tweens.remove(to_remove[i]);
    }
  }
}




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

	Vec2 rotate(float theta) {

		float c = cos(theta);
		float s = sin(theta);

		float new_x = c * this.x - s * this.y;
	  	float new_y = s * this.x + c * this.y;

	  	this.x = new_x;
	  	this.y = new_y;

	  	return this;

	}

}

void assertTrue(boolean conditional, String message) throws RuntimeException {
  
  if (!conditional) {
     throw new RuntimeException("Assertion Error: " + message); 
  } else {
    printDebug("Test passed: " + message);
  }
}
  
void runTests() {
  
   runEntityTests();
   runSystemTests();
   runColorTests();
   runSceneTests();
   runTweenTest();
   runCollisionTests();

}
void runCollisionTests() {

  World w = new World();
  CollisionSystem cs = new CollisionSystem(w);

  Entity a = w.entity_manager.newEntity();
  Entity b = w.entity_manager.newEntity();

  cs.stopWatchingCollisionsFrom(a);
  cs.stopWatchingCollisionsFrom(b);
  cs.stopWatchingCollisionsTo(a);
  cs.stopWatchingCollisionsTo(b);

  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");

  cs.watchCollision(a, b);
  assertTrue(cs.collisions_to_watch.size() == 1, "Should have 1 thing to watch");

  cs.stopWatchingCollisionsFrom(a);
  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");
  
  cs.watchCollision(a, b);
  assertTrue(cs.collisions_to_watch.size() == 1, "Should have 1 thing to watch");

  cs.stopWatchingCollisionsTo(b);
  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");

  cs.watchCollision(a, b);
  cs.reset();
  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");


  Point p1 = new Point(10, 10);
  Point p2 = new Point(10, 21);
  Point p3 = new Point(10, 21);

  Circle c1 = new Circle(10, 10, 10);
  Circle c2 = new Circle(19, 10, 10);
  Circle c3 = new Circle(31, 10, 10);

  Rectangle r1 = new Rectangle (9, 9, 10, 10);
  Rectangle r2 = new Rectangle (19, 19, 10, 10);
  Rectangle r3 = new Rectangle (39, 39, 10, 10);

  // Point collisions
  assertTrue(!cs.checkCollision(p1, p1), "Shape doesn't collide with self");
  assertTrue(!cs.checkCollision(p1, p2), "Different points shouldn't collide");
  assertTrue(cs.checkCollision(p2, p3), "Points in the same spot should collide");
  assertTrue(cs.checkCollision(p1, c1), "Point is inside shape");
  assertTrue(cs.checkCollision(p1, r1), "Point is inside shape");

  // Circle Collisions
  assertTrue(cs.checkCollision(c1, p1), "Point is inside shape");
  assertTrue(!cs.checkCollision(c3, p1), "Point is not inside shape");
  assertTrue(cs.checkCollision(c1, c2), "Circles overlap");
  assertTrue(cs.checkCollision(c2, c1), "Circles overlap");
  assertTrue(!cs.checkCollision(c1, c3), "Circles don't overlap");
  assertTrue(!cs.checkCollision(c3, c1), "Circles don't overlap");
  assertTrue(cs.checkCollision(c1, r1), "Rectangle collides with circle");
  assertTrue(!cs.checkCollision(c1, r3), "Rectangle does not collide with circle");

  // Rectangle Collisions
  assertTrue(cs.checkCollision(r1, p1), "Point is inside rectangle");
  assertTrue(!cs.checkCollision(r1, p3), "Point is not shape");
  assertTrue(cs.checkCollision(r1, c1), "Rectangle collides with circle");
  assertTrue(!cs.checkCollision(r1, c3), "Rectangle does not collide with circle");
  assertTrue(cs.checkCollision(r1, r2), "Rectangle collides with rectangle");
  assertTrue(!cs.checkCollision(r1, r3), "Rectangle does not collide with rectangle");



}


void runTweenTest() {

  Tween tween = new Tween(0, 1, 1, EasingFunctions.linear);

  assertTrue(tween.change == 1.0, "Change should be 1.0");

  tween.update(0.5);

  assertTrue(tween.value == 0.5, "Halfway through should be 0.5");
  assertTrue(tween.elapsed == 0.5, "Should have elapsed 0.5");
  assertTrue(tween.finished() == false, "Not finished");

  tween.update(0.7);

  assertTrue(tween.value == 1.0, "Done should be 1");
  assertTrue(tween.elapsed == 1.2, "Should have elapsed 1.2");
  assertTrue(tween.finished() == true, "Finished");

 
  TweenSystem tween_system = new TweenSystem(new World());



  final Tweenable t = new Tweenable();
     
  tween_system.addTween(1.0, new TweenVariable() {
                              public float initial() { return t.foo; }
                              public void setValue(float value) { t.foo = value; }  
                       }, 1.0, EasingFunctions.linear
   );

  tween_system.update(0.5);

  assertTrue(t.foo == 0.5, "Should be tweened half-way");
  
  tween_system.update(0.7);

  assertTrue(t.foo == 1.0, "Should be tweened all the way");
  assertTrue(tween_system.tweens.size() == 0, "Should have pruned tween");
  
}

class Tweenable {
  Float foo = 0.0;
  Tweenable() {}
};

void runSceneTests() {
  
  SceneManager sm = new SceneManager();
  
  World w = new World();
  Scene s = new Scene("PLAY", w);
  
  sm.addScene(s);
  
  Scene s2 = sm.getScene("PLAY");
  assertTrue(s == s2, "Scene retrieved should be scene stored");
  
}


void runColorTests() {

   int c = color(50, 100, 150);
   
   assertTrue(bitwiseR(c) == 50, "Red value should be 50, is " + bitwiseR(c));
   assertTrue(bitwiseG(c) == 100, "Green value should be 100, is " + bitwiseG(c));
   assertTrue(bitwiseB(c) == 150, "Blue value should be 150, is " + bitwiseB(c));
   
   IColor tt = new TwoTone(true);
   
   assertTrue(tt.toRaw() == color(255), "Should be black");
   tt.setFromRaw(color(15));   
   assertTrue(tt.toRaw() == color(0), "Should be white");
   
   HSB hsb = new HSB(c);
   RGB rgb = new RGB(c);
   
   assertTrue(rgb.toRaw() == c, "To and from raw RGB should be symmetrical");   
   assertTrue(rgb.toRaw() == c, "To and from raw RGB should be symmetrical, make sure no hsb side effects");   
   assertTrue(rgb.r + 0 == 50, "Should parse 50 red");   
   assertTrue(rgb.g + 0 == 100, "Should parse 50 red");   
   assertTrue(rgb.b + 0 == 150, "Should parse 50 red");   


  /* This doesn't assert true, but is close enough, as the below test shows.
  assertTrue(hsb.toRaw() == c, "To and from raw HSB should be symmetrical, instead are " + c + " and " + hsb.toRaw());

  int c = color(50, 100, 150);
  HSB hsb = new HSB(c);
  fill(c);
  rect(0, 0, 480, 640);
  fill(hsb.toRaw());
  rect(480, 0, 480, 640);
  */ 
   
}

void runEntityTests() {

  EntityManager em = new EntityManager(new World());
  
  assertTrue(em.next_id == 1, "First ID should be 1");
  
  Entity e = em.newEntity();
  
  assertTrue(e.id == 1, "Entity should get first ID");
  assertTrue(em.next_id == 2, "Second ID should be 2");
}

void runSystemTests() {

  SystemManager sys = new SystemManager();
  
  System foo = new System("Foo", new World());
  
  sys.addSystem(foo);
  
  System bar = sys.getSystem("Foo");
  assertTrue(foo == bar, "System added and system retrieved should be the same, instead are " + foo + ", " + bar);

}
void runWorldTests() {
  
  World w = new World();

}

