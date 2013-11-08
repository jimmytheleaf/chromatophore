
class World {

    EntityManager entity_manager;
    SystemManager system_manager;
    
    World() {
      
      this.entity_manager = new EntityManager();
      this.system_manager = new SystemManager();      
   
    }


}
