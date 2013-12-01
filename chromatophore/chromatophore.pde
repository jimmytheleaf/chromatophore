import ddf.minim.Minim;
import ddf.minim.AudioPlayer;
import ddf.minim.signals.*;
import ddf.minim.*;

int width = 960;
int height = 640;

final World world = new World(960, 640);
LevelGateway gateway;
LevelCredits credits;

Minim minim;
AudioManager audio_manager;

boolean playing;

void setup() 
{

  size(960, 640, P2D);
  //runTests();
  colorMode(RGB, 255, 255, 255, 255);
  rectMode(CORNER);
  frameRate(60);


  setUpSystems(world);

  background(63, 63, 63);
  noStroke();

  minim = new Minim(this);

  audio_manager = new AudioManager(minim);
  audio_manager.storeSound(SOUND_L1CORNER);
  audio_manager.storeSound(SOUND_L2JUMP);
  audio_manager.storeSound(SOUND_L2LAND);
  audio_manager.storeSound(SOUND_L2HIT);
  audio_manager.storeSound(SOUND_L4PU1);
  audio_manager.storeSound(SOUND_L4PU2);
  audio_manager.storeSound(SOUND_L5HIT);
  audio_manager.storeSound(SOUND_L5PU);
  audio_manager.storeSound(SOUND_L8BG);
  audio_manager.storeSound(SOUND_AMBIENCE);

  playing = false;

  credits = new LevelCredits(world);
  world.scene_manager.addScene(credits);

  gateway = new LevelGateway(world);
  world.scene_manager.addScene(gateway);

  LevelTitle title = new LevelTitle(world);
  world.scene_manager.addScene(title);

  AudioPlayer bgsound = audio_manager.getSound(SOUND_AMBIENCE);
  bgsound.play();
  bgsound.loop();

  // world.scene_manager.setCurrentScene(gateway);
  world.scene_manager.setCurrentScene(title);



}


void setUpSystems(World world) {

  TweenSystem tween_system = new TweenSystem(world);
  MovementSystem movement_system = new MovementSystem(world);
  BehaviorSystem behavior_system = new BehaviorSystem(world);
  InputSystem input_system = new InputSystem(world);
  RenderingSystem rendering_system = new RenderingSystem(world);
  CollisionSystem collision_system = new CollisionSystem(world);
  ScheduleSystem schedule_system = new ScheduleSystem(world);

  SpringSystem spring_system = new SpringSystem(world);
  PhysicsSystem physics_system = new PhysicsSystem(world);

  world.setSystem(tween_system);
  world.setSystem(movement_system);
  world.setSystem(behavior_system);
  world.setSystem(input_system);
  world.setSystem(rendering_system);
  world.setSystem(collision_system);
  world.setSystem(spring_system);
  world.setSystem(physics_system);
  world.setSystem(schedule_system);

  input_system.registerInput('W', ACTION_UP);
  input_system.registerInput('S', ACTION_DOWN);
  input_system.registerInput('A', ACTION_LEFT);
  input_system.registerInput('D', ACTION_RIGHT);

}

void update(float dt) {

  Scene current_scene = world.scene_manager.getCurrentScene();
  current_scene.update(dt);

}


void draw() 
{
  
  Scene current_scene = world.scene_manager.getCurrentScene();
  current_scene.draw();

}

void keyReleased() {

  key = normalizeInput(key);

  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.keyReleased(key);
}

void keyPressed() {
  
  key = normalizeInput(key);

  InputSystem input_system = (InputSystem) world.getSystem(INPUT_SYSTEM);
  input_system.keyPressed(key);

}

void mouseClicked() {
 
  Scene current_scene = world.scene_manager.getCurrentScene();
  current_scene.mouseClicked();

}


class AudioManager {


  Minim minim;

  HashMap<String, AudioPlayer> sounds;

  AudioManager(Minim minim) {
    this.sounds = new HashMap<String, AudioPlayer>();
    this.minim = minim;
  }

  void storeSound(String filename) {
    AudioPlayer p = minim.loadFile(filename);
    p.setGain(-10);
    p.setVolume(0.5);
    sounds.put(filename, p);
  }

  AudioPlayer getSound(String filename) {
    return this.sounds.get(filename);
  }


}
