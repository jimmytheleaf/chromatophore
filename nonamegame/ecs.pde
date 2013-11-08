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
