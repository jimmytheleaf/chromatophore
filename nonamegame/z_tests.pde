
void assertTrue(boolean conditional, String message) throws RuntimeException {
  
  if (!conditional) {
     throw new RuntimeException("Assertion Error: " + message); 
  }
}
  
void runTests() {
  
   runEntityTests();
   runSystemTests();
   runColorTests();
   runSceneTests();
   runTweenTest();
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

 
  TweenSystem tween_system = new TweenSystem();



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
   
   assertTrue(r(c) == 50, "Red value should be 50, is " + r(c));
   assertTrue(g(c) == 100, "Green value should be 100, is " + g(c));
   assertTrue(b(c) == 150, "Blue value should be 150, is " + b(c));
   
   IColor tt = new TwoTone(true);
   
   assertTrue(tt.toFullColor() == color(255), "Should be black");
   tt.setFromFullColor(color(15));   
   assertTrue(tt.toFullColor() == color(0), "Should be white");
   
   
}

void runEntityTests() {

  EntityManager em = new EntityManager();
  
  assertTrue(em.next_id == 1, "First ID should be 1");
  
  Entity e = em.newEntity();
  
  assertTrue(e.id == 1, "Entity should get first ID");
  assertTrue(em.next_id == 2, "Second ID should be 2");
}

void runSystemTests() {

  SystemManager sys = new SystemManager();
  
  System foo = new System("Foo");
  
  sys.addSystem(foo);
  
  System bar = sys.getSystem("Foo");
  assertTrue(foo == bar, "System added and system retrieved should be the same, instead are " + foo + ", " + bar);

}
void runWorldTests() {
  
  World w = new World();

}
