
final int TOP_Y = 20;
final int BOTTOM_Y = 620;
final int LEFT_X = 180;
final int RIGHT_X = 780;

Entity setUpSpringMount(World world, int x, int y, float mass) {

    Entity mount = world.entity_manager.newEntity();
    Transform t = new Transform(x, y);
    mount.addComponent(t);

    Physics p = new Physics(mass);
    mount.addComponent(p);

    Motion m = new Motion();
    m.max_speed = 0;
    mount.addComponent(m);

    final Shape mount_shape = new Circle(t.pos, 1).setColor(new RGB(255, 0, 0, 255));
    mount.addComponent(new ShapeComponent(mount_shape, 0));

    world.tagEntity(mount, TAG_SPRING_MOUNT);

    return mount;

}

Entity fullScreenFadeBox(World world, boolean fade_in) {

    Entity fade = world.entity_manager.newEntity();
    Transform t = new Transform(0, 0);
    fade.addComponent(t);

    final Shape fade_shape = new Rectangle(t.pos, width, height);
    final RGB fade_color = new RGB(0, 0, 0, 254);
    if (!fade_in) {
        fade_color.a = 0;
    }
    fade_shape.setColor(fade_color);

    fade.addComponent(new ShapeComponent(fade_shape, 0));

    return fade;

}

void addFadeEffect(Entity e, float fade_length, boolean fade_in) {
    
    TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);

    ShapeComponent shape_component = (ShapeComponent) e.getComponent(SHAPE);

    final RGB fade_color = (RGB) (shape_component.shape.getColor());

    if (fade_in) {

        tween_system.addTween(fade_length, new TweenVariable() {
                              public float initial() {           
                                return fade_color.a; }
                              public void setValue(float value) { 
                                fade_color.a = int(value); 
                              }  
                          }, 1, EasingFunctions.linear);
       
    } else {
       

         tween_system.addTween(fade_length, new TweenVariable() {
                              public float initial() {           
                                return fade_color.a; }
                              public void setValue(float value) { 
                                fade_color.a = int(value); 
                              }  
                          }, 254, EasingFunctions.linear);
    }
}

void addVolumeFader(final AudioPlayer player, float fade_length, boolean fade_in) {
    
    TweenSystem tween_system = (TweenSystem) this.world.getSystem(TWEEN_SYSTEM);

    TweenVariable volume_fader = new TweenVariable() {
                              public float initial() {           
                                return player.getGain(); }
                              public void setValue(float value) { 
                                player.setGain(value); 
                                printDebug("Setting gain to " + value);

                              }  
                          };
    if (fade_in) {
        tween_system.addTween(fade_length, volume_fader, 0, EasingFunctions.linear);
    } else {
        tween_system.addTween(fade_length, volume_fader, -60, EasingFunctions.linear);
    }
}



void setUpPlatform(World world, int x, int y, int w, int h, IColor c) {

    Entity platform = createRectangle(world, x, y, w, h, c);
    
    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    world.tagEntity(platform, TAG_PLATFORM);

    cs.watchCollision(player, platform);

}

void setUpWalls(World world, IColor c) {

    Entity left = createRectangle(world, 0, 0, 180, 640, c);
    Entity right = createRectangle(world, 780, 0, 180, 640, c);
    Entity top = createRectangle(world, 0, 0, 960, 20, c);
    Entity bottom = createRectangle(world, 0, 620, 960, 20, c);

    world.tagEntity(left, TAG_WALL_LEFT);
    world.tagEntity(right, TAG_WALL_RIGHT);
    world.tagEntity(top, TAG_WALL_TOP);
    world.tagEntity(bottom, TAG_WALL_BOTTOM);

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    cs.watchCollision(player, left);
    cs.watchCollision(player, right);
    cs.watchCollision(player, top);
    cs.watchCollision(player, bottom);
}

Entity createRectangle(World world, int x, int y, int w, int h, IColor c) {

    final Entity rectangle = world.entity_manager.newEntity();
    Transform rt = new Transform(x, y);
    rectangle.addComponent(rt);

    final Shape rectangle_shape = new Rectangle(rt.pos, w, h).setColor(c);
    rectangle.addComponent(new ShapeComponent(rectangle_shape, 2));

    // rectangle.addComponent(new RenderingComponent().addDrawable(rectangle_shape, 1));
    // rectangle.addComponent(new Collider(rectangle_shape));

    return rectangle;
}

Entity createCircle(World world, int x, int y, int radius, IColor c) {

    final Entity circle = world.entity_manager.newEntity();
    Transform t = new Transform(x, y);
    circle.addComponent(t);

    final Shape circle_shape = new Circle(t.pos, radius).setColor(c);
    circle.addComponent(new ShapeComponent(circle_shape, 2));

   return circle;

}

void setUpCollectables(World world, int num, IColor c) {
    setUpCollectables(world, num, c, false);
}

void setUpCollectables(World world, int num, IColor c, boolean do_rotate) {

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    for (int i = 0; i < num; i++) {

        final Entity collectable = createRectangle(world, randomint(185, 775), randomint(25, 615), 6, 6, c);
        world.group_manager.addEntityToGroup(collectable, GROUP_COLLECTABLES);
        cs.watchCollision(player, collectable);

        if (do_rotate) {
            Behavior b = new Behavior();

            b.addBehavior(new BehaviorCallback() {
                public void update(float dt) {
                    Transform t = (Transform) collectable.getComponent(TRANSFORM);
                    t.rotate(dt * 5);
                }
            });


            collectable.addComponent(b);
        }

    }

}

Entity setUpMovingShooter(final World world, int x, int y, final float rotation, final float speed, final IColor c, final int ticks) {

    final Entity emitter = setUpShooter(world, x, y, rotation, speed, c, ticks);

    final Transform t = (Transform) emitter.getComponent(TRANSFORM);

    IColor emitter_col = new RGB(zbc[0], zbc[0], zbc[0], 180);
    final Shape circle_shape = new Circle(t.pos, 4).setColor(emitter_col);
    emitter.addComponent(new ShapeComponent(circle_shape, 2));


    Behavior b = (Behavior) emitter.getComponent(BEHAVIOR);


    final Motion motion = new Motion();
    emitter.addComponent(motion);
    motion.max_speed = 500;
    //motion.damping = .98;
    motion.acceleration.x = 5;
    motion.acceleration.y = 5;

     b.addBehavior(new BehaviorCallback() {
      public void update(float dt) {

        if (t.pos.x <= LEFT_X) {
          t.pos.x = RIGHT_X;
        }

        if (t.pos.x >= RIGHT_X) {
          t.pos.x = LEFT_X;
        }

        if (t.pos.y <= TOP_Y) {
          t.pos.y = BOTTOM_Y;
        }

        if (t.pos.y >= BOTTOM_Y) {
          t.pos.y = TOP_Y;
        }
      }
  });

     b.addBehavior(new BehaviorCallback() {

        float clock = 0;
          public void update(float dt) {
            clock+= dt;
            t.pos.x += cos(clock);
            t.pos.y += cos(clock);

          }
    });


     return emitter;

}

Entity setUpShooter(final World world, int x, int y, final float rotation, final float speed, final IColor c, final int ticks) {

    final Entity emitter = world.entity_manager.newEntity();


    final Transform t = new Transform(x, y);
    t.rotateTo(rotation);

    emitter.addComponent(t);

    final BulletPool bullets = new BulletPool(80, t, world, speed, c);

    Behavior b = new Behavior();

    // Rotate Emitter
    b.addBehavior(new BehaviorCallback() {
        public void update(float dt) {
            // printDebug("rotating");
            t.rotate(dt);
       }
    });

    // Emit stuff
    b.addBehavior(new BehaviorCallback() {
        public void update(float dt) {
            // printDebug("creating bullet");


            if (world.clock.ticks % ticks == 0) {
                Entity bullet = bullets.getPoolObject();

                if (bullet != null) {
                    Transform bt = (Transform) bullet.getComponent(TRANSFORM);
                    bt.pos.x = int(t.pos.x);
                    bt.pos.y = int(t.pos.y);
                    bt.rotateTo(t.getRotation());

                    Motion m = (Motion)  bullet.getComponent(MOTION);
                    m.velocity.x = speed;
                    m.velocity.y = 0;
                    m.velocity.rotate(t.getRotation());
                }
            }
       }
    });

    emitter.addComponent(b);

    return emitter;
}

// TODO pool
Entity createBullet(final World world, int x, int y, float rotation, float speed, IColor c, final BulletPool p) {

    final Entity bullet = createCircle(world, x, y, 3, c);

    Motion motion = new Motion();
    bullet.addComponent(motion);
    motion.velocity.x = speed;
    motion.velocity.rotate(rotation);


    Behavior b = new Behavior();

    b.addBehavior(new BehaviorCallback() {
        public void update(float dt) {

            Transform t = (Transform) bullet.getComponent(TRANSFORM);
    
            if (t.pos.x < LEFT_X || t.pos.x > RIGHT_X || t.pos.y < TOP_Y || t.pos.y > BOTTOM_Y) {
                // printDebug("Giving back bullet");
                p.giveBack(bullet);
                // printDebug("Should now be inactive: " + bullet.active);

            }
       }
    });


    bullet.addComponent(b);

    PoolComponent pc = new PoolComponent(p);
    bullet.addComponent(pc);

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);
    cs.watchCollision(player, bullet);

    world.group_manager.addEntityToGroup(bullet, GROUP_BULLETS);

    return bullet;
}




 class BulletPool extends Pool<Entity> {

        Transform t;
        float speed;
        IColor c;
        World world;


        BulletPool(int size, Transform t, World world, float speed, IColor c) {
            super(size);
            this.t = t;
            this.speed = speed;
            this.c = c;
            this.world = world;
        }

        protected Entity createObject() {
            return createBullet(world, int(t.pos.x), int(t.pos.y), t.getRotation(), speed, c, this);
        }

        protected void recycleObject(Entity object) {
            object.active = false;
        }

        protected void enableObject(Entity object) {
            object.active = true;
        }

        public Entity getPoolObject() {

            Entity obj = null;

            if (available.size() > 0) {
                obj = available.get(0);
                available.remove(obj);
                used.add(obj);
                enableObject(obj);
            } else if (used.size() < max_size) {
                obj = createObject();
                used.add(obj);
            }

            return obj;
        }

        public void giveBack(Entity object) {
            recycleObject(object);
            used.remove(object);
            available.add(object);
        }
    };


