

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
