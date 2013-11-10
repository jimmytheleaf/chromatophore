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

    MultiMap<String, Entity> group_to_entities;

    GroupManager() {
      group_to_entities = new MultiMap<String, Entity>();
    }

    // TODO

}

