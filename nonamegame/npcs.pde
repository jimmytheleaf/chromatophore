
final int TOP_Y = 20;
final int BOTTOM_Y = 620;
final int LEFT_X = 180;
final int RIGHT_X = 680;

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

    CollisionSystem cs = (CollisionSystem) world.getSystem(COLLISION_SYSTEM);
    Entity player = world.getTaggedEntity(TAG_PLAYER);

    for (int i = 0; i < num; i++) {

        final Entity collectable = createRectangle(world, randomint(185, 775), randomint(25, 615), 6, 6, c);
        world.group_manager.addEntityToGroup(collectable, GROUP_COLLECTABLES);
        cs.watchCollision(player, collectable);

        /*
        Behavior b = new Behavior();

        b.addBehavior(new BehaviorCallback() {
            public void update(float dt) {
                Transform t = (Transform) collectable.getComponent(TRANSFORM);
                t.rotate(dt * 5);
            }
        });


        collectable.addComponent(b);
        */

    }

}

void setUpShooter(final World world, int x, int y, final float rotation, final float speed, final IColor c, final int ticks) {

    final Entity emitter = world.entity_manager.newEntity();
    final Transform t = new Transform(x, y);
    t.rotateTo(rotation);

    emitter.addComponent(t);

    final Pool<Entity> bullets = new Pool<Entity>(30) {
        protected Entity createObject() {
            return createBullet(world, int(t.pos.x), int(t.pos.y), t.getRotation(), speed, c, this);
        }

        protected void recycleObject(Entity object) {
            object.active = false;
        }

        protected void enableObject(Entity object) {
            object.active = true;
        }
    };

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
                Entity bullet = bullets.getObject();

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
}

// TODO pool
Entity createBullet(final World world, int x, int y, float rotation, float speed, IColor c, final Pool<Entity> p) {

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


