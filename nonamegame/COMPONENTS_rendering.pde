String RENDERING = "RenderingComponent";

class RenderingComponent extends Component {

  HashMap<Drawable, Integer> drawables;

  RenderingComponent() {
    super(RENDERING);
    this.drawables = new HashMap<Drawable, Integer>();
  }

  RenderingComponent addDrawable(Drawable d) {
    return this.addDrawable(d, 1);
  }

  RenderingComponent addDrawable(Drawable d, Integer layer) {
    this.drawables.put(d, layer);
    return this;
  }

  RenderingComponent reset() {
    this.drawables = new HashMap<Drawable, Integer>();
    return this;
  }
}
