String SHAPE = "Shape";

class ShapeComponent extends Component {

  int z;
  Shape shape;
  boolean visible;
  boolean collideable;

  ShapeComponent(Shape s) {
    super(SHAPE);
    this.shape = s;
    this.z = 1;
    this.visible = true;
    this.collideable = true;
  }

  ShapeComponent(Shape s, int _z) {
    super(SHAPE);
    this.shape = s;
    this.z = _z;
    this.visible = true;
    this.collideable = true;
  }

}
