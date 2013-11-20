String RENDERING = "RenderingComponent";

class RenderingComponent extends Component {

  HashMap<Drawable, Integer> drawables_to_layer;

  RenderingComponent() {
    super(RENDERING);
    this.drawables_to_layer = new HashMap<Drawable, Integer>();
  }

  RenderingComponent addDrawable(Drawable d) {
    return this.addDrawable(d, 1);
  }

  RenderingComponent addDrawable(Drawable d, Integer layer) {
    this.drawables_to_layer.put(d, layer);
    return this;
  }

  RenderingComponent reset() {
    this.drawables_to_layer = new HashMap<Drawable, Integer>();
    return this;
  }
}
