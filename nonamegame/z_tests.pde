
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
}

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
