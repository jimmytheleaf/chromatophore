
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
  Vec2 player_gridposition;

  int NUM_COLLECTABLES = 4;

  int grid_size = 40;
  Life gol;
  Life gol2;

  int cell_size;

  Transform player_transform;

  LevelSeven(World _w) {
    super(LEVEL_SEVEN, _w);
  }

  void init() {

      mouse_gridposition = new Vec2(0, 0);
      player_gridposition = new Vec2(0, 0);

      this.gol = new Life(grid_size, grid_size);
      this.gol.turnOn(1, 5);
      this.gol.turnOn(1, 6);
      this.gol.turnOn(2, 5);
      this.gol.turnOn(2, 6);
 
      this.gol.turnOn(11, 5);
      this.gol.turnOn(11, 6);
      this.gol.turnOn(11, 7);
      this.gol.turnOn(12, 4);
      this.gol.turnOn(12, 8);

      this.gol.turnOn(13, 3);
      this.gol.turnOn(13, 9);
      this.gol.turnOn(14, 3);
      this.gol.turnOn(14, 9);
      this.gol.turnOn(15, 6);

      this.gol.turnOn(16, 4);
      this.gol.turnOn(16, 8);

      this.gol.turnOn(17, 5);
      this.gol.turnOn(17, 6);
      this.gol.turnOn(17, 7);
      this.gol.turnOn(18, 6);

      this.gol.turnOn(21, 3);
      this.gol.turnOn(21, 4);
      this.gol.turnOn(21, 5);

      this.gol.turnOn(22, 3);
      this.gol.turnOn(22, 4);
      this.gol.turnOn(22, 5);      

      this.gol.turnOn(23, 2);
      this.gol.turnOn(23, 6);

      this.gol.turnOn(25, 1);
      this.gol.turnOn(25, 2);
      this.gol.turnOn(25, 6);
      this.gol.turnOn(25, 7);

      this.gol.turnOn(35, 3);
      this.gol.turnOn(35, 4);
      this.gol.turnOn(36, 3);
      this.gol.turnOn(36, 4);

      copyCells(this.gol, 25);

      this.gol2 = new Life(grid_size, grid_size);

      cell_size = 600 / grid_size;

      collectable_color.r = zbc[randomint(0, 3)];
      collectable_color.g = zbc[randomint(0, 3)];
      collectable_color.b = zbc[randomint(0, 3)];

      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, int(center.x), int(center.y), 15, 15, player_color);
      PLAYER_UTILS.addMotion(player, 200, 0, 0, 0.98);
      PLAYER_UTILS.addSpaceshipMovement(player, 20);

      player_transform = (Transform) player.getComponent(TRANSFORM);

      setUpWalls(this.world, wall_color);
      background(bg.r, bg.g, bg.b);
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    background(gol.living, gol.living, gol.living);
    super.draw();


    for (int i = 0; i < grid_size; i++) {
      for (int j = 0; j < grid_size; j++) {

           Cell cell2 = this.gol2.cells.getCell(i, j);
            
          if (cell2 != null && cell2.alive) {
              fill(0, 255, 100, 100);
              rect(LEFT_X + (i * cell_size), 
                TOP_Y + (j * cell_size),
                cell_size,
                cell_size);
          }


          Cell cell = this.gol.cells.getCell(i, j);
          if (cell != null && cell.alive) {
              fill(255, 255, 255, 255);
              rect(LEFT_X + (i * cell_size), 
                TOP_Y + (j * cell_size),
                cell_size,
                cell_size);
          }

         
      }
    }

    textSize(90);
    
    fill(255, 255, 255, 255);
    text(gol.living, 20, 340);

    fill(0, 255, 100, 255);
    text(gol2.living, 780, 340);

    if (checkWinCondition()) {
      fill(255, 255, 255, 255);
      text("THE WINNER IS YOU", 40, 340); 
    }

  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, true);

    mouse_gridposition.x = constrain(ceil((mouseX - LEFT_X)/cell_size), 0, grid_size - 1);
    mouse_gridposition.y = constrain(ceil((mouseY - TOP_Y)/cell_size), 0, grid_size - 1);


    player_gridposition.x = constrain(ceil((player_transform.pos.x - LEFT_X)/cell_size), 0, grid_size - 1);
    player_gridposition.y = constrain(ceil((player_transform.pos.y - TOP_Y)/cell_size), 0, grid_size - 1);

    gol2.turnOn(player_gridposition.x, player_gridposition.y);

    if (world.clock.ticks % 5 == 0) {
      this.gol.updateFrame();
    }

     if (world.clock.ticks % 10 == 0) {
      this.gol2.updateFrame();
    }

  }

  void mouseClicked() {
      this.gol.toggle(int(mouse_gridposition.x), int(mouse_gridposition.y));
  }



  
  boolean checkWinCondition() {
    return gol.living == 0;
  }

  void copyCells(Life gol, int yoffset) {
    for (int i = 0; i < grid_size; i++) {
      for (int j = 0; j < grid_size; j++) {
          Cell cell = gol.cells.getCell(i, j);
          Cell cell2 = gol.cells.getCell(i, j + yoffset);

          if (cell != null && cell2 != null) {

            cell2.setState(cell.getState());
          }

      }   
    }
  }
 

  

}