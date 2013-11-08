
class Scene {

  String name;
  World world;
  
  Scene(String _name, World _w) {
    this.name = _name;
    this.world = _w;
  }
  
  void init() {
    // Implement by extending class
  }
  
  void enter() {
    // Implement by extending class
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
