

class MultiMap<K, V> {

	// This is dumb, but a way around including files so we can
	// export cleanly to processing.js
	HashMap<K, HashMap<V, Boolean>> map;

	MultiMap() {
		this.map = new HashMap<K, HashMap<V, Boolean>>();
	}

	/*
	V[] get(K key) {
		if (map.containsKey(key)) {
			// Yuck
      		return (V) this.map.get(key).keySet().toArray();
		} else {
			return null;
		}
	}

	void put(K key, V value) {
		if (map.containsKey(key)) {
			map.get(key).put(value, Boolean.TRUE);
		} else {
			map.put(key, new HashMap<V, Boolean>());
			map.get(key).put(value, Boolean.TRUE);
		}

	}
	*/
}

// Very simple pool
abstract class Pool<T> {

	ArrayList<T> used;
	ArrayList<T> available;
	int max_size;

	Pool(int size) {
		this.max_size = size;
		used = new ArrayList<T>();
		available = new ArrayList<T>();
	}

	public T getObject() {

		T obj = null;

		if (available.size() > 0) {
			obj = available.get(0);
			available.remove(obj);
			used.add(obj);
			enableObject(obj);
		} else if (used.size() < max_size) {
			obj = createObject();
			used.add(obj);
		}

		return obj;
	}

	public void giveBack(T object) {
		recycleObject(object);
		used.remove(object);
		available.add(object);
	}

	protected abstract T createObject();
	protected abstract void recycleObject(T object);
	protected abstract void enableObject(T object);


}