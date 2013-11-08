class Entity {
 
   int id;
  
   Entity(int _id) {
      this.id = _id; 
   } 
  
}

class Component {

  String name;
  
  Component(String _name) {
    this.name = _name;
  }

}

class System {
  
  String name;
  
  System(String _name) {
    this.name = _name;
  }
  
}


class Scene {

  String name;
  World world;
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
  
  String getName() {
    return this.name;
  }
  
}