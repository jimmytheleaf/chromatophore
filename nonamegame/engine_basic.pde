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

  void mouseClicked() {
    // Implement by extending class
  }

  
  String getName() {
    return this.name;
  }


  
}
