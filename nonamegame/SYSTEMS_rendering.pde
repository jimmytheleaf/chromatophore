String RENDERING_SYSTEM = "RenderingSystem";

class RenderingSystem extends System {

  RenderingSystem(World w) {
    super(RENDERING_SYSTEM, w);
  }

  void drawDrawables() {

    if (this.world.entity_manager.component_store.containsKey(RENDERING)) {

      // TODO - Z order
      for (Entity e : this.world.entity_manager.component_store.get(RENDERING).keySet()) {

        RenderingComponent r = (RenderingComponent) e.getComponent(RENDERING);

        for (Drawable d : r.drawables) {
          d.draw();
          // printDebug("Drawing drawable : " + d);
        }
      }
    }
  }
}
