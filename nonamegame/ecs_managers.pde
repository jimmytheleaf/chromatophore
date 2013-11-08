class EntityManager {
 
   int next_id;
   
   EntityManager() {
      this.next_id = 1; 
   }
   
   Entity newEntity() {
      Entity e = new Entity(next_id);  
      next_id++;
      return e;
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
