
class LevelSeven extends BaseScene {

  RGB player_color = new RGB(0, 255, 100, 255);
  RGB color_grey = new RGB(63, 63, 63, 255);
  RGB color_dark_grey = new RGB(21, 21, 21, 255);

  RGB color_red = new RGB(255, 0, 0, 255);
  RGB color_green = new RGB(0, 255, 0, 255);
  RGB color_blue = new RGB(0, 0, 255, 255);
  RGB color_black = new RGB(0, 0, 0, 255);
  RGB color_white = new RGB(255, 255, 255, 255);
  RGB bullet_color = new RGB(147, 176, 205, 255);

  RGB collectable_color = new RGB(0, 0, 0, 255);

  RGB wall_color = color_dark_grey;
  RGB bg = color_grey;

  ArrayList<Entity> remove_buffer = new ArrayList<Entity>();

  Vec2 mouse_gridposition;

  int NUM_COLLECTABLES = 4;

  int grid_size = 40;
  Life gol;
  int cell_size;

  LevelSeven(World _w) {
    super(LEVEL_SEVEN, _w);
  }

  void init() {

      mouse_gridposition = new Vec2(0, 0);

      this.gol = new Life(grid_size, grid_size);
      this.gol.turnOn(5, 5);
      this.gol.turnOn(5, 6);
      this.gol.turnOn(6, 6);

      cell_size = 600 / grid_size;

      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, int(center.x), int(center.y), 15, 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);


      setUpWalls(this.world, wall_color);
      background(bg.r, bg.g, bg.b);
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(bg.r, bg.g, bg.b);
    super.draw();


    fill(255, 255, 255);
    for (int i = 0; i < grid_size; i++) {
      for (int j = 0; j < grid_size; j++) {

          
          Cell cell = this.gol.cells.getCell(i, j);
          if (cell != null && cell.alive) {
              rect(LEFT_X + (i * cell_size), 
                TOP_Y + (j * cell_size),
                cell_size,
                cell_size);
          }
            
      }
    }

    textSize(100);
    
    fill(255, 255, 255, 255);
    //text(mouse_gridposition.toString(), 40, 340);

    if (checkWinCondition()) {
      fill(0, 0, 0, 255);
      text("THE WINNER IS YOU", 40, 340); 
    }

  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, true);

    mouse_gridposition.x = constrain(ceil((mouseX - LEFT_X)/cell_size), 0, grid_size);
    mouse_gridposition.y = constrain(ceil((mouseY - TOP_Y)/cell_size), 0, grid_size);

    if (world.clock.ticks % 5 == 0) {
      this.gol.updateFrame();
    }

  }

  void mouseClicked() {
      this.gol.turnOn(int(mouse_gridposition.x), int(mouse_gridposition.y));
  }



  
  boolean checkWinCondition() {
    return false;
  }

 

  

}