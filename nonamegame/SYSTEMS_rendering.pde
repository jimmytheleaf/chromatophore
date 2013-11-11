String RENDERING_SYSTEM = "RenderingSystem";

class RenderingSystem extends System {

  HashMap<Integer, ArrayList<Drawable>> z_tracker;

  RenderingSystem(World w) {
    super(RENDERING_SYSTEM, w);
    this.z_tracker = new HashMap<Integer, ArrayList<Drawable>>();
  }

  void drawDrawables() { 

    if (this.world.entity_manager.component_store.containsKey(RENDERING)) {

      // Clear arrays
      for (Integer key :  this.z_tracker.keySet()) {
        this.z_tracker.get(key).clear();
      }

      int min_z = 100000;
      int max_z = -100000;

      // Sort out by layer
      for (Entity e : this.world.entity_manager.component_store.get(RENDERING).keySet()) {


        RenderingComponent r = (RenderingComponent) e.getComponent(RENDERING);

        for (Drawable d : r.drawables.keySet()) {

          int z = r.drawables.get(d);

          if (!this.z_tracker.containsKey(z)) {
            this.z_tracker.put(z, new ArrayList<Drawable>());
          }

          this.z_tracker.get(z).add(d);

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

          for (Drawable d : this.z_tracker.get(i)) {
              d.draw();
          }
        }
      }
    }
  }
}
