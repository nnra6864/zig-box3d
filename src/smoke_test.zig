//! Runs small simulations through the bindings to check that they work end to end.

const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;

const b3 = @import("box3d.zig");

fn makeGround(world: b3.World) !b3.Body {
    var body_def = b3.defaultBodyDef();
    body_def.position = .init(0, -1, 0);
    const ground = world.createBody(&body_def);
    const box = b3.makeBoxHull(20, 1, 20);
    const shape_def = b3.defaultShapeDef();
    _ = ground.createHullShape(&shape_def, box.hull());
    return ground;
}

test "a sphere falls and comes to rest on the ground" {
    var world_def = b3.defaultWorldDef();
    world_def.gravity = .init(0, -10, 0);
    const world = b3.createWorld(&world_def);
    defer world.destroy();
    try expect(world.isValid());

    _ = try makeGround(world);

    var body_def = b3.defaultBodyDef();
    body_def.type = .dynamic;
    body_def.position = .init(0, 4, 0);
    body_def.name = "ball";
    const ball = world.createBody(&body_def);
    var shape_def = b3.defaultShapeDef();
    shape_def.enableContactEvents = true;
    const sphere: b3.Sphere = .{ .center = .zero, .radius = 0.5 };
    const shape = ball.createSphereShape(&shape_def, &sphere);

    try expectEqual(b3.BodyType.dynamic, ball.getType());
    try std.testing.expectEqualStrings("ball", ball.getName());
    try expect(shape.getBody().eql(ball));

    var began_touching = false;
    for (0..240) |_| {
        world.step(1.0 / 60.0, 4);
        if (world.getContactEvents().beginEvents.len > 0) began_touching = true;
    }
    try expect(began_touching);

    const p = b3.toVec3(ball.getPosition());
    try expectApproxEqAbs(@as(f32, 0.5), p.y, 0.05);

    var shapes: [4]b3.Shape = undefined;
    const found = ball.getShapes(&shapes);
    try expectEqual(1, found.len);
    try expect(found[0].eql(shape));

    var contacts: [4]b3.ContactData = undefined;
    const touching = shape.getContactData(&contacts);
    try expectEqual(1, touching.len);
    try expect(touching[0].getManifolds().len > 0);
}

test "ray cast, hull accessors and typed joints" {
    var world_def = b3.defaultWorldDef();
    world_def.gravity = .init(0, -10, 0);
    const world = b3.World.create(&world_def);
    defer world.destroy();

    const ground = try makeGround(world);

    const hit = world.castRayClosest(b3.toPos(.init(0, 10, 0)), .init(0, -20, 0), b3.defaultQueryFilter());
    try expect(hit.hit);
    try expectApproxEqAbs(@as(f32, 0), b3.toVec3(hit.point).y, 0.01);
    try expect(hit.shapeId.getBody().eql(ground));

    // A hull built from the corners of a cube.
    var points: [8]b3.Vec3 = undefined;
    for (&points, 0..) |*point, i| {
        point.* = .init(
            if (i & 1 != 0) 0.5 else -0.5,
            if (i & 2 != 0) 0.5 else -0.5,
            if (i & 4 != 0) 0.5 else -0.5,
        );
    }
    const hull = b3.createHull(&points, b3.max_hull_vertices) orelse return error.HullFailed;
    defer hull.destroy();
    try expectEqual(8, hull.getPoints().len);
    try expectEqual(6, hull.getFaces().len);
    try expectEqual(24, hull.getEdges().len);
    try expectApproxEqAbs(@as(f32, 1), hull.computeMass(1).mass, 1e-4);

    var body_def = b3.defaultBodyDef();
    body_def.type = .dynamic;
    body_def.position = .init(0, 3, 0);
    const box = world.createBody(&body_def);
    _ = box.createHullShape(&b3.defaultShapeDef(), hull);

    var joint_def = b3.defaultRevoluteJointDef();
    joint_def.base.bodyIdA = ground;
    joint_def.base.bodyIdB = box;
    joint_def.base.localFrameA = .{ .p = .init(0, 4, 0), .q = .identity };
    joint_def.base.localFrameB = .identity;
    joint_def.enableMotor = true;
    joint_def.maxMotorTorque = 100;
    const hinge = world.createRevoluteJoint(&joint_def);
    try expectEqual(b3.JointType.revolute, hinge.joint.getType());
    hinge.setMotorSpeed(2);
    try expectEqual(@as(f32, 2), hinge.getMotorSpeed());
    try expect(hinge.joint.as(b3.RevoluteJoint).joint.eql(hinge.joint));

    var joints: [2]b3.Joint = undefined;
    try expectEqual(1, box.getJoints(&joints).len);

    for (0..60) |_| world.step(1.0 / 60.0, 4);
    try expect(hinge.joint.isValid());
    hinge.joint.destroy(true);
    try expect(!hinge.joint.isValid());
}

test "ids store and load" {
    const body: b3.Body = .{ .index1 = 7, .world0 = 2, .generation = 9 };
    try expect(b3.Body.load(body.store()).eql(body));
    const contact: b3.Contact = .{ .index1 = 3, .world0 = 1, .generation = 70000 };
    try expect(b3.Contact.load(contact.store()).eql(contact));
    const world: b3.World = .{ .index1 = 5, .generation = 1 };
    try expect(b3.World.load(world.store()).eql(world));
    try expect(b3.Shape.null_id.isNull());
}

test "math" {
    const q = b3.Quat.fromAxisAngle(.axis_z, 0.5 * b3.pi);
    const v = q.rotate(.axis_x);
    try expectApproxEqAbs(@as(f32, 1), v.y, 1e-5);
    try expectApproxEqAbs(@as(f32, 0), q.invRotate(v).y, 1e-5);
    try expectApproxEqAbs(@as(f32, 0.5 * b3.pi), q.getAngle(), 1e-4);

    const m = b3.Matrix3.fromQuat(q);
    const r = m.mulV(.axis_x);
    try expectApproxEqAbs(v.y, r.y, 1e-5);
    const inv = m.invert().mul(m);
    try expectApproxEqAbs(@as(f32, 1), inv.cx.x, 1e-5);

    const t: b3.Transform = .{ .p = .init(1, 2, 3), .q = q };
    const p = t.transformPoint(.init(1, 0, 0));
    const back = t.invTransformPoint(p);
    try expectApproxEqAbs(@as(f32, 1), back.x, 1e-5);

    const box = b3.makeAABB(&.{ .init(0, 0, 0), .init(1, 2, 3) }, 0);
    try expectApproxEqAbs(@as(f32, 22), box.area(), 1e-5);
    try expect(box.overlaps(box.inflate(1)));
    try expectApproxEqAbs(@as(f32, 0.25), b3.unwindAngle(0.25 + 2 * b3.pi), 1e-5);
}
