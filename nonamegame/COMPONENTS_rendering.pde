String RENDERING = "RenderingComponent";

class RenderingComponent extends Component {
	
	ArrayList<Drawable> drawables;

	RenderingComponent() {
		super(RENDERING);
		this.drawables = new ArrayList<Drawable>();
	}

	RenderingComponent addDrawable(Drawable d) {
		this.drawables.add(d);
		return this;
	}

	RenderingComponent reset() {
		this.drawables = new ArrayList<Drawable>();
		return this;
	}

}
