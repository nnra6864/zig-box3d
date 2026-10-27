# zig-box3d

Zig bindings for [Box3D](https://github.com/erincatto/box3d), Erin Catto's 3D physics engine, at commit [`f36d061`](https://github.com/erincatto/box3d/commit/f36d061ba26998c87cb7dc593a4065aaa03fb7eb) (0.1.0 plus later changes).

- Covers the whole public API, grouped by topic under `src/box3d/` (`world.zig`, `body.zig`, `shape.zig`, `joint.zig`, `geometry.zig`, ...) and re-exported flat from `src/box3d.zig` (`b3.World`, `b3.createHull`, `b3.Vec3`, ...).
- Ids are handles with methods: `b3World_Step(worldId, ...)` is `world.step(...)`, `b3CreateBody(worldId, &def)` is `world.createBody(&def)`, `b3CreateSphereShape(bodyId, ...)` is `body.createSphereShape(...)`.
- Each joint type has its own handle (`RevoluteJoint`, `WheelJoint`, ...) returned by its create function, so `hinge.setMotorSpeed(2)` works. The functions shared by all joints live on `hinge.joint`.
- Zig friendly signatures: slices instead of pointer + count (`body.getShapes(&buffer)` returns the filled part), results returned instead of written to out pointers, event arrays as slices, `[:0]const u8` names.
- The inline math from `math_functions.h` is written in Zig, as free functions and as methods (`q.rotate(v)`, `a.add(b)`, `m.invert()`). Hull, mesh and height field data have slice accessors (`hull.getPoints()`, `mesh.getTriangles()`).
- Doc comments come from the Box3D headers, with C names converted to their Zig equivalents.
- Box3D is compiled from source by the Zig build, so no CMake is needed. You can link the system's Box3D instead.

Requires Zig 0.17.0.

## Usage

```sh
zig fetch --save git+https://git.nnstdios.com/nnra6864/zig-box3d
```

In `build.zig`:

```zig
const box3d = b.dependency("zig_box3d", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("box3d", box3d.module("box3d"));
```

Importing the module links Box3D for you.

```zig
const std = @import("std");
const b3 = @import("box3d");

pub fn main() void {
    var world_def = b3.defaultWorldDef();
    world_def.gravity = .init(0, -10, 0);
    const world = b3.createWorld(&world_def);
    defer world.destroy();

    // A static ground box.
    var ground_def = b3.defaultBodyDef();
    ground_def.position = .init(0, -1, 0);
    const ground = world.createBody(&ground_def);
    const ground_box = b3.makeBoxHull(20, 1, 20);
    _ = ground.createHullShape(&b3.defaultShapeDef(), ground_box.hull());

    // A falling sphere.
    var ball_def = b3.defaultBodyDef();
    ball_def.type = .dynamic;
    ball_def.position = .init(0, 4, 0);
    const ball = world.createBody(&ball_def);
    var ball_shape_def = b3.defaultShapeDef();
    ball_shape_def.enableContactEvents = true;
    _ = ball.createSphereShape(&ball_shape_def, &.{ .center = .zero, .radius = 0.5 });

    for (0..120) |i| {
        world.step(1.0 / 60.0, 4);
        for (world.getContactEvents().beginEvents) |event| {
            const other = if (event.shapeIdA.getBody().eql(ball)) event.shapeIdB else event.shapeIdA;
            std.debug.print("step {d}: the ball touched body {d}\n", .{ i, other.getBody().index1 });
        }
    }
    std.debug.print("ball rests at y = {d:.3}\n", .{b3.toVec3(ball.getPosition()).y});
}
```

### Build options

| Option | Default | Description |
| --- | --- | --- |
| `double_precision` | `false` | Large world mode. World positions (`b3.Pos`) become doubles. This changes the ABI, so the bindings follow it, `b3.double_precision` tells you which mode you are in. |
| `disable_simd` | `false` | Build Box3D's scalar fallback instead of SSE2/AVX2/NEON. |
| `validate` | `false` | Enable Box3D's heavy internal validation in debug builds. |
| `system_box3d` | `false` | Link the Box3D installed on the system instead of building it from source. |
| `linkage` | `static` | Build Box3D as a `static` or `dynamic` library. |

Box3D's assertions are on in `Debug` and `ReleaseSafe` builds, and off in `ReleaseFast` and `ReleaseSmall`.

With `linkage = .dynamic`, install the library next to your executable with `b.installArtifact(box3d.artifact("box3d"))`.

`b3.Pos` and `b3.WorldTransform` are `Vec3` and `Transform` in single precision mode. Use `b3.toPos`, `b3.toVec3`, `b3.offsetPos` and `b3.subPos` to move between them, and your code works in both modes.

## Not bound

- Box3D's `B3_ASSERT`/`B3_VALIDATE` macros and C++ operator overloads.
- `b3World_DumpShapeBounds`, which is declared in the header but not implemented.
- Compile-time overrides of `B3_MAX_MANIFOLD_POINTS` and friends. The bindings assume Box3D's defaults.

## Testing

```sh
# Builds Box3D from source, checks every struct, enum and function against the C headers, and runs a few simulations
zig build test
zig build test -Ddouble_precision=true
# Uses the system Box3D (skips the header checks)
zig build test -Dsystem_box3d=true
```

## Regenerating

Most of `src/` is generated from the Box3D headers by `tools/gen/gen.py`. After bumping the `box3d` dependency in `build.zig.zon`:

```sh
zig build --fetch
python3 tools/gen/gen.py zig-pkg/<box3d package>/include/box3d src
zig build test
```

`src/box3d/math.zig`, `src/box3d/constants.zig` and `src/smoke_test.zig` are written by hand. The hand written wrappers used by the generator are in `tools/gen/overrides.py`.

## License

The bindings are released into the public domain under [CC0 1.0](LICENSE).

Box3D itself is © Erin Catto and distributed under the [MIT license](https://github.com/erincatto/box3d/blob/main/LICENSE).
The doc comments in `src/box3d/` are adapted from Box3D's headers and remain under that license.
