class LevelGateway extends Scene {

  int level;

  ArrayList<Scene> levels; 

  Vec2 mouse_gridposition;
  
  int grid_size = 3;
  int cell_size;

  RGB active_fill;

  float oscillation_amount = 70;

  Entity fade;
  boolean transitioning_out = false;

  
  ArrayList<ArrayList<String>> text_interludes = new ArrayList<ArrayList<String>>();

  final TextInterlude last;


  LevelGateway(World _w) {

    super(LEVEL_GATEWAY, _w);
    
    level = 0;
    mouse_gridposition = new Vec2(0, 0);
    cell_size = 600 / grid_size;

    initializeLevels();
    initializeInterludes();

    last = prepareLevelNine();
  }

  void initializeLevels() {

    LevelOne level_one = new LevelOne(world);
    world.scene_manager.addScene(level_one);
   
    LevelTwo level_two = new LevelTwo(world);
    world.scene_manager.addScene(level_two);
 
    LevelThree level_three = new LevelThree(world);
    world.scene_manager.addScene(level_three);

    LevelFour level_four = new LevelFour(world);
    world.scene_manager.addScene(level_four);
  
    LevelFive level_five = new LevelFive(world);
    world.scene_manager.addScene(level_five);
 
    LevelSix level_six = new LevelSix(world);
    world.scene_manager.addScene(level_six);
  
    LevelSeven level_seven = new LevelSeven(world);
    world.scene_manager.addScene(level_seven);
  
    LevelEight level_eight = new LevelEight(world);
    world.scene_manager.addScene(level_eight);


    levels = new ArrayList<Scene>();
    levels.add(level_one);
    levels.add(level_two);
    levels.add(level_three);
    levels.add(level_four);
    levels.add(level_five);
    levels.add(level_six);
    levels.add(level_seven);
    levels.add(level_eight);

  }

  void update(float dt) {


    ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
    schedule_system.update(dt);

    TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);
    tween_system.update(dt);

    mouse_gridposition.x = constrain(floor((mouseX - LEFT_X)/cell_size), 0, grid_size - 1);
    mouse_gridposition.y = constrain(floor((mouseY - TOP_Y)/cell_size), 0, grid_size - 1);

  }

  void enter() {    
    // super.enter();
    world.resetEntities();
    level++;
    active_fill = new RGB(255 - level * (255 / 8), 255 - level * (255 / 8), 255 - level * (255 / 8), 255);
    fade = fullScreenFadeBox(world, true);
    addFadeEffect(fade, 3, true);
    transitioning_out = false;
  }

  void draw() {

    background(255 - (level * (255 / 9)), 255 - (level * (255 / 9)), 255 - (level * (255 / 9)), 255);

    textSize(80);
    
    for (int i = 0; i < 9; i++) {

      if (i + 1 == this.level) {

        if (mousePosToLevel() == level) {
          if (i < 8) {
            // fill(200, 200, 0, 100);
            fill(185, 209, 61, 200);
          } else {
            fill(221, 61, 58, 200);
          }
        } else {
          float diff = sin(this.world.clock.total_time) * oscillation_amount;
          fill(active_fill.r + diff, active_fill.b + diff, active_fill.g + diff, 255);
        }

      } else if (i + 1 < this.level) {
        fill(48, 166, 109, 200);
      } else {
        fill(255 - i * (255 / 8), 255 - i * (255 / 8), 255 - i * (255 / 8), 255);
      }
      rect(LEFT_X + ((i * 200) % 600), TOP_Y + yVal(i), 200, 200);
    }

    fill(0, 255, 255, 255);
    //text(mouse_gridposition.toString(), 20, 340);
    //text(mousePosToLevel(), 20, 440);


    RenderingSystem rendering_system = (RenderingSystem) this.world.getSystem(RENDERING_SYSTEM);
    rendering_system.drawDrawables();

    this.world.updateClock();
    this.update(this.world.clock.dt);

  }

  int yVal(int i) {

    if (i <= 2) {
      return 0;
    } else if (i <= 5) {
      return 200;
    } else {
      return 400;
    }

  }




  boolean checkWinCondition() {
    return level >= 9;
  }

  void mouseClicked() {
      if (mousePosToLevel() == level) {
        triggerTransition(level - 1);
      }
  }

  int mousePosToLevel() {
    return int((mouse_gridposition.x + 1) + (mouse_gridposition.y) * 3);
  }

  void triggerTransition(final int level) {
    if (!transitioning_out) {
      transitioning_out = true;

      
      ScheduleSystem schedule_system = (ScheduleSystem) this.world.getSystem(SCHEDULE_SYSTEM);
      addFadeEffect(fade, 3, false);

      if (level < 8) {

        final Scene level_to = levels.get(level);
        final TextInterlude interlude = new TextInterlude(world, text_interludes.get(level), 4.5, level_to);
        world.scene_manager.addScene(interlude);
        schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(interlude);
                                  world.removeEntity(fade);
                                }
                              }, 3.1);
      } else {

        
        schedule_system.doAfter(new ScheduleEntry() { 
                                public void run() { 
                                  world.scene_manager.setCurrentScene(last);
                                  world.removeEntity(fade);
                                }
                              }, 3.1);

      }

     


    }
  }

  void initializeInterludes() {

    ArrayList<String> interlude_one = new ArrayList<String>();
    interlude_one.add("1. It is said that Prometheus stole fire from the gods and gave it to man,");
    interlude_one.add("receiving eternal agony for his offense.");
    interlude_one.add("");
    interlude_one.add("A spiteful creature, man did everything he could to extinguish fire");
    interlude_one.add("from the earth and plunge himself back into darkness.");

    text_interludes.add(interlude_one);

    ArrayList<String> interlude_two = new ArrayList<String>();

    interlude_two.add("2. One never steps into the same lava flow twice.");
    interlude_two.add("");
    interlude_two.add("The changing of rules and the systems that underlie them is the best we can rely on.");

    text_interludes.add(interlude_two);

    ArrayList<String> interlude_three = new ArrayList<String>();

    interlude_three.add("3. A dark moon, I find that I am unable to escape my elliptical orbit around you.");
    interlude_three.add("");
    interlude_three.add("One day we will collide and share our first extinction event.");

    text_interludes.add(interlude_three);

    ArrayList<String> interlude_four = new ArrayList<String>();

    interlude_four.add("4. Coleoid cephalopods have complex multicellular organs which they use to change color rapidly. ");
    interlude_four.add("This is most notable in brightly colored squid, cuttlefish and octopuses. ");
    interlude_four.add("Like chameleons, cephalopods use physiological color change for social interaction.");
    interlude_four.add("They are also among the most skilled at background adaptation, having the ability to match both the color and the texture of their local environment with remarkable accuracy.");
    text_interludes.add(interlude_four);

    ArrayList<String> interlude_five = new ArrayList<String>();

    interlude_five.add("5. With each generation of hardware, we add extra bits and the palette of representable colors rises.");
    interlude_five.add("We measure this in terms of color depth of a pixel.");
    interlude_five.add("Deep color contains more than a billion distinct colors.");
    interlude_five.add("Dither is an intentionally applied form of noise used to randomize quantization error, preventing large-scale patterns such as color banding in images.");
    interlude_five.add("");
    interlude_five.add("These days, it’s rare to not feel out of my depth.");

    text_interludes.add(interlude_five);

    ArrayList<String> interlude_six = new ArrayList<String>();
    interlude_six.add("6. In Greek mythology, Proteus is an early sea-god or god of rivers and oceanic bodies of water.");
    interlude_six.add("Some who ascribe to him a specific domain call him the god of 'elusive sea change,' which suggests the constantly changing nature of the sea or the liquid quality of water in general.");
    interlude_six.add("");
    interlude_six.add("He can foretell the future, but, in a mytheme familiar to several cultures, will change his shape to avoid having to.");
    interlude_six.add("From this feature of Proteus comes the adjective 'protean,' with the general meaning of 'versatile,' 'mutable,' 'capable of assuming many forms.'");
    interlude_six.add("");

    text_interludes.add(interlude_six);

    ArrayList<String> interlude_seven = new ArrayList<String>();
    interlude_seven.add("7. At this point, the individual faces a choice: sink into despair and");
    interlude_seven.add("resignation, or take a leap of faith toward what Jaspers calls");
    interlude_seven.add("'Transcendence.'");
    interlude_seven.add("");
    interlude_seven.add("In making this leap, individuals confront their own limitless freedom, which");
    interlude_seven.add("Jaspers calls 'Existenz,' and can finally experience authentic existence.");
    text_interludes.add(interlude_seven);

    ArrayList<String> interlude_eight = new ArrayList<String>();
    interlude_eight.add("8. SPEGEL: I have prayed just one prayer in my life. Use me. Handle me.");
    interlude_eight.add("But God never understood what a strong and devoted slave I had become. So I had to go unused.");
    interlude_eight.add("(Pause)");
    interlude_eight.add("Incidentally, that is also a lie.");
    interlude_eight.add("(Pause)");
    interlude_eight.add("One walks step by step into the darkness. The motion itself is the only truth.");
    text_interludes.add(interlude_eight);

  }

  TextInterlude prepareLevelNine() {


    ArrayList<String> interlude_nine_one = new ArrayList<String>();
    interlude_nine_one.add("9.1");
    interlude_nine_one.add("In 1984, Beckett went to the funeral of long-time friend Robert Blin.");
    interlude_nine_one.add("Sitting in the crematorium of Père Lachaise, the sound of the cracking of the bones within the incinerator filled the quiet room.");
    interlude_nine_one.add("");
    interlude_nine_one.add("The sound of the bones was to haunt him for years to come.");

    ArrayList<String> interlude_nine_two = new ArrayList<String>();
    interlude_nine_two.add("9.2");
    interlude_nine_two.add("Exhibit one: “Old earth, no more lies, I’ve seen you, it was me, with my other’s ravening eyes, too late.”");
    interlude_nine_two.add("");

    ArrayList<String> interlude_nine_three = new ArrayList<String>();
    interlude_nine_three.add("9.3");
    interlude_nine_three.add("Exhibit two: “But who knows the fate of his bones, or how often he is to be buried? Who hath the oracle of his ashes, or whither they are to be scattered?”");
    interlude_nine_three.add("");

    ArrayList<String> interlude_nine_four = new ArrayList<String>();
    interlude_nine_four.add("9.4");
    interlude_nine_four.add("Exhibit three: “Ah to love at your last and see them at theirs, the last minute loved ones, and be happy, why ah, uncalled for.”");
    interlude_nine_four.add("");

    ArrayList<String> interlude_nine_five = new ArrayList<String>();
    interlude_nine_five.add("9.5");
     interlude_nine_five.add("For all my willingness to change, I find it most difficult to accept this final one.");
    interlude_nine_five.add("What I could never live with is if things ended before I was finished.");
    interlude_nine_five.add("");

    TextInterlude i5 = new TextInterlude(world, interlude_nine_five, 4.0, credits);
    TextInterlude i4 = new TextInterlude(world, interlude_nine_four, 4.0, i5);
    TextInterlude i3 = new TextInterlude(world, interlude_nine_three, 4.0, i4);
    TextInterlude i2 = new TextInterlude(world, interlude_nine_two, 4.0, i3);
    TextInterlude i1 = new TextInterlude(world, interlude_nine_one, 4.0, i2);

    world.scene_manager.addScene(i1);
    world.scene_manager.addScene(i2);
    world.scene_manager.addScene(i3);
    world.scene_manager.addScene(i4);
    world.scene_manager.addScene(i5);
    return i1;


  }

}
