
void assertTrue(boolean conditional, String message) throws RuntimeException {
  
  if (!conditional) {
     throw new RuntimeException("Assertion Error: " + message); 
  }
}
  
void runTests() {
  
   runEntityTests();
   runSystemTests();
   runWorldTests();
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
