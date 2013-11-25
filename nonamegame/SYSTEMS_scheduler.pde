
String SCHEDULE_SYSTEM = "ScheduleSystem";

interface ScheduleEntry {
  void run();
}

class ScheduleSystem extends System {

  HashMap<ScheduleEntry, Float> delayed;
  ArrayList<ScheduleEntry> expired;

  ScheduleSystem(World w) {
    super(SCHEDULE_SYSTEM, w);
    delayed = new HashMap<ScheduleEntry, Float>();
    expired = new ArrayList<ScheduleEntry>();
  }

  void doAfter(ScheduleEntry entry, float delay_duration) {

    delayed.put(entry, delay_duration);

  }

  void update(float dt) {

    
    for (ScheduleEntry entry : delayed.keySet()) {
        float remaining_until = delayed.get(entry) - dt; 
        
        if (remaining_until <= 0) {
          entry.run();
          expired.add(entry);
        }  else {
          delayed.put(entry, remaining_until);
        }
    }

    for (int i = 0; i < expired.size(); i++) {
      delayed.remove(expired.get(i));
    }

    expired.clear();

  }

}
