String COLLISION_SYSTEM = "CollisionSystem";

class CollisionSystem extends System {

  ArrayList<CollisionPair> collisions_to_watch;

  CollisionSystem(World w) {
    super(COLLISION_SYSTEM, w);
    collisions_to_watch = new ArrayList<CollisionPair>();
  }

  CollisionPair watchCollision(Entity a, Entity b) {
    CollisionPair cp = new CollisionPair(a, b);
    this.collisions_to_watch.add(cp);
    return cp;
  }

  void stopWatchingCollision(CollisionPair pair) {
    this.collisions_to_watch.remove(pair);
  }

  void stopWatchingCollisionsFrom(Entity a) {

    for (int i = collisions_to_watch.size() - 1; i >= 0; i --) {
        CollisionPair entry = collisions_to_watch.get(i); 
        if (entry.a == a) {
          collisions_to_watch.remove(i);
        }
    }
  }

  void stopWatchingCollisionsTo(Entity b) {

   for (int i = collisions_to_watch.size() - 1; i >= 0; i --) {
        CollisionPair entry = collisions_to_watch.get(i); 
        if (entry.b == b) {
          collisions_to_watch.remove(i);
        }
    }
  }

  void reset() {
    collisions_to_watch = new ArrayList<CollisionPair>();
  }
}