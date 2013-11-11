
void assertTrue(boolean conditional, String message) throws RuntimeException {
  
  if (!conditional) {
     throw new RuntimeException("Assertion Error: " + message); 
  } else {
    printDebug("Test passed: " + message);
  }
}
  
void runTests() {
  
   runEntityTests();
   runSystemTests();
   runColorTests();
   runSceneTests();
   runTweenTest();
   runCollisionTests();

}
void runCollisionTests() {

  World w = new World();
  CollisionSystem cs = new CollisionSystem(w);

  Entity a = w.entity_manager.newEntity();
  Entity b = w.entity_manager.newEntity();

  cs.stopWatchingCollisionsFrom(a);
  cs.stopWatchingCollisionsFrom(b);
  cs.stopWatchingCollisionsTo(a);
  cs.stopWatchingCollisionsTo(b);

  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");

  cs.watchCollision(a, b);
  assertTrue(cs.collisions_to_watch.size() == 1, "Should have 1 thing to watch");

  cs.stopWatchingCollisionsFrom(a);
  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");
  
  cs.watchCollision(a, b);
  assertTrue(cs.collisions_to_watch.size() == 1, "Should have 1 thing to watch");

  cs.stopWatchingCollisionsTo(b);
  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");

  cs.watchCollision(a, b);
  cs.reset();
  assertTrue(cs.collisions_to_watch.size() == 0, "Shouldn't have anything to watch");


  Point p1 = new Point(10, 10);
  Point p2 = new Point(10, 21);
  Point p3 = new Point(10, 21);

  Circle c1 = new Circle(10, 10, 10);
  Circle c2 = new Circle(19, 10, 10);
  Circle c3 = new Circle(31, 10, 10);

  Rectangle r1 = new Rectangle (9, 9, 10, 10);
  Rectangle r2 = new Rectangle (19, 19, 10, 10);
  Rectangle r3 = new Rectangle (39, 39, 10, 10);

  // Point collisions
  assertTrue(!cs.checkCollision(p1, p1), "Shape doesn't collide with self");
  assertTrue(!cs.checkCollision(p1, p2), "Different points shouldn't collide");
  assertTrue(cs.checkCollision(p2, p3), "Points in the same spot should collide");
  assertTrue(cs.checkCollision(p1, c1), "Point is inside shape");
  assertTrue(cs.checkCollision(p1, r1), "Point is inside shape");

  // Circle Collisions
  assertTrue(cs.checkCollision(c1, p1), "Point is inside shape");
  assertTrue(!cs.checkCollision(c3, p1), "Point is not inside shape");
  assertTrue(cs.checkCollision(c1, c2), "Circles overlap");
  assertTrue(cs.checkCollision(c2, c1), "Circles overlap");
  assertTrue(!cs.checkCollision(c1, c3), "Circles don't overlap");
  assertTrue(!cs.checkCollision(c3, c1), "Circles don't overlap");
  assertTrue(cs.checkCollision(c1, r1), "Rectangle collides with circle");
  assertTrue(!cs.checkCollision(c1, r3), "Rectangle does not collide with circle");

  // Rectangle Collisions
  assertTrue(cs.checkCollision(r1, p1), "Point is inside rectangle");
  assertTrue(!cs.checkCollision(r1, p3), "Point is not shape");
  assertTrue(cs.checkCollision(r1, c1), "Rectangle collides with circle");
  assertTrue(!cs.checkCollision(r1, c3), "Rectangle does not collide with circle");
  assertTrue(cs.checkCollision(r1, r2), "Rectangle collides with rectangle");
  assertTrue(!cs.checkCollision(r1, r3), "Rectangle does not collide with rectangle");



}


void runTweenTest() {

  Tween tween = new Tween(0, 1, 1, EasingFunctions.linear);

  assertTrue(tween.change == 1.0, "Change should be 1.0");

  tween.update(0.5);

  assertTrue(tween.value == 0.5, "Halfway through should be 0.5");
  assertTrue(tween.elapsed == 0.5, "Should have elapsed 0.5");
  assertTrue(tween.finished() == false, "Not finished");

  tween.update(0.7);

  assertTrue(tween.value == 1.0, "Done should be 1");
  assertTrue(tween.elapsed == 1.2, "Should have elapsed 1.2");
  assertTrue(tween.finished() == true, "Finished");

 
  TweenSystem tween_system = new TweenSystem(new World());



  final Tweenable t = new Tweenable();
     
  tween_system.addTween(1.0, new TweenVariable() {
                              public float initial() { return t.foo; }
                              public void setValue(float value) { t.foo = value; }  
                       }, 1.0, EasingFunctions.linear
   );

  tween_system.update(0.5);

  assertTrue(t.foo == 0.5, "Should be tweened half-way");
  
  tween_system.update(0.7);

  assertTrue(t.foo == 1.0, "Should be tweened all the way");
  assertTrue(tween_system.tweens.size() == 0, "Should have pruned tween");
  
}

class Tweenable {
  Float foo = 0.0;
  Tweenable() {}
};

void runSceneTests() {
  
  SceneManager sm = new SceneManager();
  
  World w = new World();
  Scene s = new Scene("PLAY", w);
  
  sm.addScene(s);
  
  Scene s2 = sm.getScene("PLAY");
  assertTrue(s == s2, "Scene retrieved should be scene stored");
  
}


void runColorTests() {

   int c = color(50, 100, 150);
   
   assertTrue(bitwiseR(c) == 50, "Red value should be 50, is " + bitwiseR(c));
   assertTrue(bitwiseG(c) == 100, "Green value should be 100, is " + bitwiseG(c));
   assertTrue(bitwiseB(c) == 150, "Blue value should be 150, is " + bitwiseB(c));
   
   IColor tt = new TwoTone(true);
   
   assertTrue(tt.toRaw() == color(255), "Should be black");
   tt.setFromRaw(color(15));   
   assertTrue(tt.toRaw() == color(0), "Should be white");
   
   HSB hsb = new HSB(c);
   RGB rgb = new RGB(c);
   
   assertTrue(rgb.toRaw() == c, "To and from raw RGB should be symmetrical");   
   assertTrue(rgb.toRaw() == c, "To and from raw RGB should be symmetrical, make sure no hsb side effects");   
   assertTrue(rgb.r + 0 == 50, "Should parse 50 red");   
   assertTrue(rgb.g + 0 == 100, "Should parse 50 red");   
   assertTrue(rgb.b + 0 == 150, "Should parse 50 red");   


  /* This doesn't assert true, but is close enough, as the below test shows.
  assertTrue(hsb.toRaw() == c, "To and from raw HSB should be symmetrical, instead are " + c + " and " + hsb.toRaw());

  int c = color(50, 100, 150);
  HSB hsb = new HSB(c);
  fill(c);
  rect(0, 0, 480, 640);
  fill(hsb.toRaw());
  rect(480, 0, 480, 640);
  */ 
   
}

void runEntityTests() {

  EntityManager em = new EntityManager(new World());
  
  assertTrue(em.next_id == 1, "First ID should be 1");
  
  Entity e = em.newEntity();
  
  assertTrue(e.id == 1, "Entity should get first ID");
  assertTrue(em.next_id == 2, "Second ID should be 2");
}

void runSystemTests() {

  SystemManager sys = new SystemManager();
  
  System foo = new System("Foo", new World());
  
  sys.addSystem(foo);
  
  System bar = sys.getSystem("Foo");
  assertTrue(foo == bar, "System added and system retrieved should be the same, instead are " + foo + ", " + bar);

}
void runWorldTests() {
  
  World w = new World();

}
