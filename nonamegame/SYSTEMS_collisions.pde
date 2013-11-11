String COLLISION_SYSTEM = "CollisionSystem";

class CollisionSystem extends System {

  ArrayList<CollisionPair> collisions_to_watch;
  Vec2 buffer;

  final ArrayList<CollisionPair> _collisions;

  CollisionSystem(World w) {
    super(COLLISION_SYSTEM, w);
    this.collisions_to_watch = new ArrayList<CollisionPair>();
    this.buffer = new Vec2(0, 0);
    this._collisions = new ArrayList<CollisionPair>();
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


  ArrayList<CollisionPair> getCollisions() {

      this._collisions.clear();

      for (CollisionPair pair : collisions_to_watch) {

        Collider ca = (Collider) pair.a.getComponent(COLLIDER);
        Collider cb = (Collider) pair.b.getComponent(COLLIDER);

        if (ca != null && cb != null && ca.active && cb.active) {
          if (this.checkCollision(ca.collidable, cb.collidable)) {
            this._collisions.add(pair);
          }
        }
      }

      return this._collisions;
  }


  // Returns a collision pair if collides, null if not
  Boolean checkCollision(Collidable a, Collidable b) {

    if (a == b) { 
      return false;
    }

    if (a instanceof Circle) {
      return circleCollision((Circle) a, b);
    } 
    else if (a instanceof Point) {
      return pointCollision((Point) a, b);
    } 
    else if (a instanceof Rectangle) {
      return rectangleCollision((Rectangle) a, b);
    } 
    else {
      // not supported
      return null;
    }
  }

  private Boolean pointCollision(Point pa, Collidable b) {

    if (b instanceof Circle) {

      Circle cb = (Circle) b;
      return cb.pos.dist(pa.pos)  < cb.radius;
    } 
    else if (b instanceof Point) {

      Point pb = (Point) b;
      return pa.pos.x == pb.pos.x && pa.pos.y == pb.pos.y;
    } 
    else if (b instanceof Rectangle) {

      Rectangle rb = (Rectangle) b;

      return pa.pos.x > rb.pos.x &&
        pa.pos.x < rb.pos.x + rb.width &&
        pa.pos.y > rb.pos.y &&
        pa.pos.y < rb.pos.y + rb.height;
    } 
    else {
      // not supported
      return null;
    }
  }

  private Boolean rectangleCollision(Rectangle ra, Collidable b) {

    if (b instanceof Circle) {

      return circleCollision((Circle) b, (Collidable) ra);
    } 
    else if (b instanceof Point) {

       return pointCollision((Point) b, (Collidable) ra);

    } 
    else if (b instanceof Rectangle) {

      Rectangle rb = (Rectangle) b;

      // If any of these are true, then they don't intersect, so return "not" of that.
      // 0, 0 is in upper left hand corner.
      return ! (
       // the X coord of my upper right is less than x coord of other upper left
       ra.pos.x + ra.width < rb.pos.x ||
       //  the X coord of other's upper right is less than x coord of my upper left
       rb.pos.x + rb.width < ra.pos.x ||
       // the Y coord of my lower right is less than Y coord of other upper left
       ra.pos.y + ra.height < rb.pos.y  || 
       // the Y coord of other's lower right is less than than Y coord of my upper left
       rb.pos.y  + rb.height < ra.pos.y
       );
    } 
    else {
      // not supported
      return null;
    }
  }

  private Boolean circleCollision(Circle ca, Collidable b) {

    if (b instanceof Circle) {

      Circle cb = (Circle) b;
      float added_radii = ca.radius + cb.radius;
      return ca.pos.dist(cb.pos) < added_radii;
    } 
    else if (b instanceof Point) {
      return pointCollision((Point) b, (Collidable) ca);
    } 
    else if (b instanceof Rectangle) {

      // From: http://stackoverflow.com/a/1879223
      Rectangle rb = (Rectangle) b;
      // Find closest point
      float closestX = constrain(ca.pos.x, rb.pos.x, rb.pos.x + rb.width);
      float closestY = constrain(ca.pos.y, rb.pos.y, rb.pos.y + rb.height);

      // Check to see if this point is within circle
      return ca.pos.dist(closestX, closestY) < ca.radius;
    } 
    else {
      // not supported
      return null;
    }
  }

}
