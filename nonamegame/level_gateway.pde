class LevelGateway extends Scene {

  int level;

  ArrayList<Scene> levels; 

  Vec2 mouse_gridposition;
  
  int grid_size = 3;
  int cell_size;

  RGB active_fill;

  float oscillation_amount = 70;

  Entity fade;

  LevelGateway(World _w) {

    super(LEVEL_GATEWAY, _w);
    
    level = 0;
    mouse_gridposition = new Vec2(0, 0);
    cell_size = 600 / grid_size;

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
    addFadeEffect(fade, 5, true);

  }

  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(level * (255 / 9), level * (255 / 9), level * (255 / 9), 255);

    textSize(80);
    
    for (int i = 0; i < 9; i++) {

      if (i + 1 == this.level) {

        if (mousePosToLevel() == level) {
          fill(200, 200, 0, 100);
        } else {
          float diff = sin(this.world.clock.total_time) * oscillation_amount;
          fill(active_fill.r + diff, active_fill.b + diff, active_fill.g + diff, 255);
        }
      } else if (i + 1 < this.level) {
        fill(0, 200, 0, 100);
      } else {
        fill(255 - i * (255 / 8), 255 - i * (255 / 8), 255 - i * (255 / 8), 255);
      }
      rect(LEFT_X + ((i * 200) % 600), TOP_Y + yVal(i), 200, 200);
    }

    fill(0, 255, 255, 255);
    //text(mouse_gridposition.toString(), 20, 340);
    //text(mousePosToLevel(), 20, 440);


    if (checkWinCondition()) {

      fill(0, 0, 0, 255);
      text("THE WINNER IS YOU", 40, 340); 
    
    }

    RenderingSystem rendering_system = (RenderingSystem) this.world.getSystem(RENDERING_SYSTEM);
    rendering_system.drawDrawables();

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
      if (mousePosToLevel() == level && level < 9) {
        world.removeEntity(fade);
        world.scene_manager.setCurrentScene(levels.get(level - 1));
      }
  }


  int mousePosToLevel() {
    return int((mouse_gridposition.x + 1) + (mouse_gridposition.y) * 3);
  }

}
