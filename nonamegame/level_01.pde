
class LevelOne extends BaseScene {

  int corners_touched;
  Boolean[] corners;
  color black = color(0, 0, 0, 255);
  AudioPlayer audio_player;

  LevelOne(World _w) {
    super(LEVEL_ONE, _w);
    corners_touched = 0;
  }

  void init() {
      super.init();   
      
      Entity player = PLAYER_UTILS.getNewPlayerEntity(world);
      PLAYER_UTILS.addRectangleShape(player, 330, 170, 300, 300, new RGB(0, 0, 0, 255));
      PLAYER_UTILS.addMotion(player, 500, 200, 200, 1);
      PLAYER_UTILS.addSpaceshipMovement(player, 100);

      setUpWalls(this.world, new RGB(0, 0, 0, 255));
      background(255, 255, 255);
      audio_player = audio_manager.getSound(SOUND_L1CORNER);

      corners = new Boolean[4];
      corners[0] = false;
      corners[1] = false;
      corners[2] = false;
      corners[3] = false;
      
  }


  void draw() {

    this.world.updateClock();
    this.update(this.world.clock.dt);

    //background(255, 255, 255);
    super.draw();

    textSize(75);
    
    fill(255, 255, 255, 255);

    text("" + corners_touched, 40, 140);

    if (checkWinCondition()) {

      fill(255, 255, 255, 255);
      text("THE WINNER IS YOU", 40, 340); 
      if (!won) {
        won = true;
        this.win_time = this.world.clock.total_time;
      } 

       // text(this.win_time, 40, 140); 
        //text(this.world.clock.total_time, 40, 440); 

    }

     if (won) {
        if (this.world.clock.total_time - this.win_time > 3) {
          this.world.scene_manager.setCurrentScene(gateway);
        }
    }

  }

  boolean checkWinCondition() {
    return corners_touched == 4;
  }

  void update(float dt) {

    super.update(dt);

    CollisionSystem collision_system = (CollisionSystem) this.world.getSystem(COLLISION_SYSTEM);
    ArrayList<CollisionPair> collisions = collision_system.getCollisions();

    collidePlayerAgainstWalls(collisions, false);

    if (!audio_player.isPlaying()) {
      audio_player.rewind();
    }
    this.updateWinCondition();

  }

  void updateWinCondition() {

    loadPixels();
    
    if (getPixel(181, 21) == black) {
      if (!corners[0]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[0] = true;
      }
    }

    if (getPixel(181, 619) == black) {
      if (!corners[1]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[1] = true;

      }    
    }

    if (getPixel(779, 21) == black) {
       if (!corners[2]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[2] = true;

      }
    }

    if (getPixel(779, 619) == black) {
       if (!corners[3]) {
        corners_touched++;
        audio_player.rewind();
        audio_player.play();
        corners[3] = true;
      }
    }
  }

}