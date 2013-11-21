


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
    rectangle.addComponent(new ShapeComponent(rectangle_shape, 1));




    // rectangle.addComponent(new RenderingComponent().addDrawable(rectangle_shape, 1));
    // rectangle.addComponent(new Collider(rectangle_shape));

    return rectangle;
}
