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
      return entities.contains(e);
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

