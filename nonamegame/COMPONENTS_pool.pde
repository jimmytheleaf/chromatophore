String POOL = "Pool";

class PoolComponent extends Component {

	Pool<Entity> pool;

	PoolComponent(Pool<Entity> p) {
		super(POOL);
		this.pool = p;
	}
}
