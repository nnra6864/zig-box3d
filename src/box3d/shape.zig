//! Shape (box3d.h, types.h)

/// Shape id references a shape instance. This should be treated as an opaque handle.
pub const Shape = extern struct {
    index1: i32 = 0,
    world0: u16 = 0,
    generation: u16 = 0,

    /// A null id. Zero initialization also gives a null id.
    pub const null_id: Shape = .{};

    /// Is this id null?
    pub fn isNull(id: Shape) bool {
        return id.index1 == 0;
    }

    /// Is this id non-null?
    pub fn isNonNull(id: Shape) bool {
        return id.index1 != 0;
    }

    /// Compare two ids for equality.
    pub fn eql(a: Shape, b: Shape) bool {
        return a.index1 == b.index1 and a.world0 == b.world0 and a.generation == b.generation;
    }

    /// Store a shape id into a u64.
    pub fn store(id: Shape) u64 {
        return @as(u64, @as(u32, @bitCast(id.index1))) << 32 | @as(u64, id.world0) << 16 | id.generation;
    }

    /// Load a u64 into a shape id.
    pub fn load(x: u64) Shape {
        return .{ .index1 = @bitCast(@as(u32, @truncate(x >> 32))), .world0 = @truncate(x >> 16), .generation = @truncate(x) };
    }

    /// Destroy a shape. You may defer the body mass update which can improve performance if several shapes on a
    /// body are destroyed at once.
    /// See `Body.applyMassFromShapes`.
    pub const destroy = b3DestroyShape;
    extern fn b3DestroyShape(shapeId: Shape, updateBodyMass: bool) void;

    /// Shape identifier validation. Provides validation for up to 64K allocations.
    pub const isValid = b3Shape_IsValid;
    extern fn b3Shape_IsValid(id: Shape) bool;

    /// Get the type of a shape
    pub const getType = b3Shape_GetType;
    extern fn b3Shape_GetType(shapeId: Shape) ShapeType;

    /// Get the id of the body that a shape is attached to
    pub const getBody = b3Shape_GetBody;
    extern fn b3Shape_GetBody(shapeId: Shape) Body;

    /// Get the world that owns this shape
    pub const getWorld = b3Shape_GetWorld;
    extern fn b3Shape_GetWorld(shapeId: Shape) World;

    /// Returns true if the shape is a sensor
    pub const isSensor = b3Shape_IsSensor;
    extern fn b3Shape_IsSensor(shapeId: Shape) bool;

    /// Set the shape name.
    pub const setName = b3Shape_SetName;
    extern fn b3Shape_SetName(shapeId: Shape, name: [*:0]const u8) void;

    /// Get the shape name. Returns an empty string if the name isn't set.
    pub fn getName(shapeId: Shape) [:0]const u8 {
        return std.mem.span(b3Shape_GetName(shapeId));
    }
    extern fn b3Shape_GetName(shapeId: Shape) [*:0]const u8;

    /// Set the user data for a shape
    pub const setUserData = b3Shape_SetUserData;
    extern fn b3Shape_SetUserData(shapeId: Shape, userData: ?*anyopaque) void;

    /// Get the user data for a shape. This is useful when you get a shape id
    /// from an event or query.
    pub const getUserData = b3Shape_GetUserData;
    extern fn b3Shape_GetUserData(shapeId: Shape) ?*anyopaque;

    /// Set the mass density of a shape, usually in kg/m^3.
    /// This will optionally update the mass properties on the parent body.
    /// See `ShapeDef.density`, `Body.applyMassFromShapes`.
    pub const setDensity = b3Shape_SetDensity;
    extern fn b3Shape_SetDensity(shapeId: Shape, density: f32, updateBodyMass: bool) void;

    /// Get the density of a shape, usually in kg/m^3
    pub const getDensity = b3Shape_GetDensity;
    extern fn b3Shape_GetDensity(shapeId: Shape) f32;

    /// Set the friction on a shape
    pub const setFriction = b3Shape_SetFriction;
    extern fn b3Shape_SetFriction(shapeId: Shape, friction: f32) void;

    /// Get the friction of a shape
    pub const getFriction = b3Shape_GetFriction;
    extern fn b3Shape_GetFriction(shapeId: Shape) f32;

    /// Set the shape restitution (bounciness)
    pub const setRestitution = b3Shape_SetRestitution;
    extern fn b3Shape_SetRestitution(shapeId: Shape, restitution: f32) void;

    /// Get the shape restitution
    pub const getRestitution = b3Shape_GetRestitution;
    extern fn b3Shape_GetRestitution(shapeId: Shape) f32;

    /// Set the shape base surface material. Does not change per triangle materials.
    pub const setSurfaceMaterial = b3Shape_SetSurfaceMaterial;
    extern fn b3Shape_SetSurfaceMaterial(shapeId: Shape, surfaceMaterial: SurfaceMaterial) void;

    /// Get the base shape surface material.
    pub const getSurfaceMaterial = b3Shape_GetSurfaceMaterial;
    extern fn b3Shape_GetSurfaceMaterial(shapeId: Shape) SurfaceMaterial;

    /// Get the number of mesh surface materials.
    pub const getMeshMaterialCount = b3Shape_GetMeshMaterialCount;
    extern fn b3Shape_GetMeshMaterialCount(shapeId: Shape) c_int;

    /// Set a surface material for a mesh shape.
    pub const setMeshMaterial = b3Shape_SetMeshMaterial;
    extern fn b3Shape_SetMeshMaterial(shapeId: Shape, surfaceMaterial: SurfaceMaterial, index: c_int) void;

    /// Get a surface material for a mesh shape
    pub const getMeshSurfaceMaterial = b3Shape_GetMeshSurfaceMaterial;
    extern fn b3Shape_GetMeshSurfaceMaterial(shapeId: Shape, index: c_int) SurfaceMaterial;

    /// Get the shape filter
    pub const getFilter = b3Shape_GetFilter;
    extern fn b3Shape_GetFilter(shapeId: Shape) Filter;

    /// Set the current filter. This is almost as expensive as recreating the shape.
    /// See `ShapeDef.filter`.
    /// - `shapeId`: the shape
    /// - `filter`: the new filter
    /// - `invokeContacts`: if true then the shape will have all contacts recomputed the next time step (expensive)
    pub const setFilter = b3Shape_SetFilter;
    extern fn b3Shape_SetFilter(shapeId: Shape, filter: Filter, invokeContacts: bool) void;

    /// Enable sensor events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
    /// See `ShapeDef.isSensor`.
    pub const enableSensorEvents = b3Shape_EnableSensorEvents;
    extern fn b3Shape_EnableSensorEvents(shapeId: Shape, flag: bool) void;

    /// Returns true if sensor events are enabled
    pub const areSensorEventsEnabled = b3Shape_AreSensorEventsEnabled;
    extern fn b3Shape_AreSensorEventsEnabled(shapeId: Shape) bool;

    /// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
    /// See `ShapeDef.enableContactEvents`.
    pub const enableContactEvents = b3Shape_EnableContactEvents;
    extern fn b3Shape_EnableContactEvents(shapeId: Shape, flag: bool) void;

    /// Returns true if contact events are enabled
    pub const areContactEventsEnabled = b3Shape_AreContactEventsEnabled;
    extern fn b3Shape_AreContactEventsEnabled(shapeId: Shape) bool;

    /// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
    /// and must be carefully handled due to multithreading. Ignored for sensors.
    /// See `PreSolveFcn`.
    pub const enablePreSolveEvents = b3Shape_EnablePreSolveEvents;
    extern fn b3Shape_EnablePreSolveEvents(shapeId: Shape, flag: bool) void;

    /// Returns true if pre-solve events are enabled
    pub const arePreSolveEventsEnabled = b3Shape_ArePreSolveEventsEnabled;
    extern fn b3Shape_ArePreSolveEventsEnabled(shapeId: Shape) bool;

    /// Enable contact hit events for this shape. Ignored for sensors.
    /// See `WorldDef.hitEventThreshold`.
    pub const enableHitEvents = b3Shape_EnableHitEvents;
    extern fn b3Shape_EnableHitEvents(shapeId: Shape, flag: bool) void;

    /// Returns true if hit events are enabled
    pub const areHitEventsEnabled = b3Shape_AreHitEventsEnabled;
    extern fn b3Shape_AreHitEventsEnabled(shapeId: Shape) bool;

    /// Ray cast a shape directly. The ray runs from origin to origin + translation and the hit point
    /// comes back as a world position, so the cast stays precise far from the world origin.
    pub const rayCast = b3Shape_RayCast;
    extern fn b3Shape_RayCast(shapeId: Shape, origin: Pos, translation: Vec3) WorldCastOutput;

    /// Get a copy of the shape's sphere. Asserts the type is correct.
    pub const getSphere = b3Shape_GetSphere;
    extern fn b3Shape_GetSphere(shapeId: Shape) Sphere;

    /// Get a copy of the shape's capsule. Asserts the type is correct.
    pub const getCapsule = b3Shape_GetCapsule;
    extern fn b3Shape_GetCapsule(shapeId: Shape) Capsule;

    /// Get the shape's convex hull. Asserts the type is correct.
    pub const getHull = b3Shape_GetHull;
    extern fn b3Shape_GetHull(shapeId: Shape) *const HullData;

    /// Get the shape's mesh. Asserts the type is correct.
    pub const getMesh = b3Shape_GetMesh;
    extern fn b3Shape_GetMesh(shapeId: Shape) Mesh;

    /// Get the shape's height field. Asserts the type is correct.
    pub const getHeightField = b3Shape_GetHeightField;
    extern fn b3Shape_GetHeightField(shapeId: Shape) *const HeightFieldData;

    /// Get the shape's compound. Asserts the type is correct.
    pub const getCompound = b3Shape_GetCompound;
    extern fn b3Shape_GetCompound(shapeId: Shape) *const CompoundData;

    /// Allows you to change a shape to be a sphere or update the current sphere.
    /// This does not modify the mass properties.
    /// See `Body.applyMassFromShapes`.
    pub const setSphere = b3Shape_SetSphere;
    extern fn b3Shape_SetSphere(shapeId: Shape, sphere: *const Sphere) void;

    /// Allows you to change a shape to be a capsule or update the current capsule.
    /// This does not modify the mass properties.
    /// See `Body.applyMassFromShapes`.
    pub const setCapsule = b3Shape_SetCapsule;
    extern fn b3Shape_SetCapsule(shapeId: Shape, capsule: *const Capsule) void;

    /// Allows you to change a shape to be a hull or update the current hull.
    /// This does not modify the mass properties.
    /// See `Body.applyMassFromShapes`.
    pub const setHull = b3Shape_SetHull;
    extern fn b3Shape_SetHull(shapeId: Shape, hull: *const HullData) void;

    /// Allows you to change a shape to be a mesh or update the current mesh.
    /// This does not modify the mass properties.
    /// See `Body.applyMassFromShapes`.
    pub const setMesh = b3Shape_SetMesh;
    extern fn b3Shape_SetMesh(shapeId: Shape, meshData: *const MeshData, scale: Vec3) void;

    /// Get the maximum capacity required for retrieving all the touching contacts on a shape
    pub const getContactCapacity = b3Shape_GetContactCapacity;
    extern fn b3Shape_GetContactCapacity(shapeId: Shape) c_int;

    /// Get the touching contact data for a shape. The provided shapeId will be either shapeIdA or shapeIdB on the contact data.
    /// Note: Box3D uses speculative collision so some contact points may be separated.
    /// Returns the number of elements filled in the provided array
    /// Warning: do not ignore the return value, it specifies the valid number of elements
    pub fn getContactData(shapeId: Shape, contactData: []ContactData) []ContactData {
        return contactData[0..@intCast(b3Shape_GetContactData(shapeId, contactData.ptr, @intCast(contactData.len)))];
    }
    extern fn b3Shape_GetContactData(shapeId: Shape, contactData: [*]ContactData, capacity: c_int) c_int;

    /// Get the maximum capacity required for retrieving all the overlapped shapes on a sensor shape.
    /// This returns 0 if the provided shape is not a sensor.
    /// - `shapeId`: the id of a sensor shape
    /// Returns the required capacity to get all the overlaps in `Shape.getSensorData`
    pub const getSensorCapacity = b3Shape_GetSensorCapacity;
    extern fn b3Shape_GetSensorCapacity(shapeId: Shape) c_int;

    /// Get the overlap data for a sensor shape.
    /// - `shapeId`: the id of a sensor shape
    /// - `visitorIds`: a user allocated array that is filled with the overlapping shapes (visitors)
    /// - `capacity`: the capacity of overlappedShapes
    /// Returns the number of elements filled in the provided array
    /// Warning: do not ignore the return value, it specifies the valid number of elements
    /// Warning: overlaps may contain destroyed shapes so use `Shape.isValid` to confirm each overlap
    pub fn getSensorData(shapeId: Shape, visitorIds: []Shape) []Shape {
        return visitorIds[0..@intCast(b3Shape_GetSensorData(shapeId, visitorIds.ptr, @intCast(visitorIds.len)))];
    }
    extern fn b3Shape_GetSensorData(shapeId: Shape, visitorIds: [*]Shape, capacity: c_int) c_int;

    /// Get the current world AABB
    pub const getAABB = b3Shape_GetAABB;
    extern fn b3Shape_GetAABB(shapeId: Shape) AABB;

    /// Compute the mass data for a shape
    pub const computeMassData = b3Shape_ComputeMassData;
    extern fn b3Shape_ComputeMassData(shapeId: Shape) MassData;

    /// Get the closest point on a shape to a target point. Target and result are in world space.
    pub const getClosestPoint = b3Shape_GetClosestPoint;
    extern fn b3Shape_GetClosestPoint(shapeId: Shape, target: Vec3) Vec3;

    /// Apply a wind force to the body for this shape using the density of air. This considers
    /// the projected area of the shape in the wind direction. This also considers
    /// the relative velocity of the shape.
    /// - `shapeId`: the shape id
    /// - `wind`: the wind velocity in world space
    /// - `drag`: the drag coefficient, the force that opposes the relative velocity
    /// - `lift`: the lift coefficient, the force that is perpendicular to the relative velocity
    /// - `maxSpeed`: the maximum relative speed. Speed cap is necessary for stability. Typically 10m/s or less.
    /// - `wake`: should this wake the body
    pub const applyWind = b3Shape_ApplyWind;
    extern fn b3Shape_ApplyWind(shapeId: Shape, wind: Vec3, drag: f32, lift: f32, maxSpeed: f32, wake: bool) void;
};

/// This is used to filter collision on shapes. It affects shape-vs-shape collision
/// and shape-versus-query collision (such as `World.castRay`).
pub const Filter = extern struct {
    /// The collision category bits. Normally you would just set one bit. The category bits should
    /// represent your application object types. For example:
    /// ```cpp
    /// enum MyCategories
    /// {
    /// Static  = 0x00000001,
    /// Dynamic = 0x00000002,
    /// Debris  = 0x00000004,
    /// Player  = 0x00000008,
    /// // etc
    /// };
    /// ```
    categoryBits: u64,
    /// The collision mask bits. This states the categories that this
    /// shape would accept for collision.
    /// For example, you may want your player to only collide with static objects
    /// and other players.
    /// ```zig
    /// maskBits = Static | Player;
    /// ```
    maskBits: u64,
    /// Collision groups allow a certain group of objects to never collide (negative)
    /// or always collide (positive). A group index of zero has no effect. Non-zero group filtering
    /// always wins against the mask bits.
    /// For example, you may want ragdolls to collide with other ragdolls but you don't want
    /// ragdoll self-collision. In this case you would give each ragdoll a unique negative group index
    /// and apply that group index to all shapes on the ragdoll.
    groupIndex: c_int,

    /// Use this to initialize your filter
    pub const default = b3DefaultFilter;
    extern fn b3DefaultFilter() Filter;
};

/// Use this to initialize your filter
pub const defaultFilter = Filter.default;

/// Material properties supported per triangle on meshes and height fields
pub const SurfaceMaterial = extern struct {
    /// The Coulomb (dry) friction coefficient, usually in the range [0,1].
    friction: f32,
    /// The coefficient of restitution (bounce) usually in the range [0,1].
    /// https://en.wikipedia.org/wiki/Coefficient_of_restitution
    restitution: f32,
    /// The rolling resistance usually in the range [0,1]. This is only used for spheres and capsules.
    rollingResistance: f32,
    /// The tangent velocity for conveyor belts. This is local to the shape and will be projected
    /// onto the contact surface.
    tangentVelocity: Vec3,
    /// User material identifier. This is passed with query results and to friction and restitution
    /// combining functions. It is not used internally.
    userMaterialId: u64,
    /// Custom debug draw color. Ignored if 0. The low 24 bits are RGB. The high byte may
    /// carry a `DebugMaterial` preset, see `HexColor.withMaterial`.
    /// See `HexColor`.
    customColor: u32,
    /// Explicit padding. Must be zero.
    padding: u32,

    /// Use this to initialize your surface material
    pub const default = b3DefaultSurfaceMaterial;
    extern fn b3DefaultSurfaceMaterial() SurfaceMaterial;
};

/// Use this to initialize your surface material
pub const defaultSurfaceMaterial = SurfaceMaterial.default;

/// Shape type
pub const ShapeType = enum(c_int) {
    /// A capsule is an extruded sphere
    capsule,
    /// A baked compound shape composed of spheres, capsules, hulls, and meshes
    compound,
    /// A height field useful for terrain
    height,
    /// A convex hull
    hull,
    /// A triangle soup
    mesh,
    /// A sphere with an offset
    sphere,

    /// The number of ShapeType values.
    pub const count = 6;
};

/// Used to create a shape
pub const ShapeDef = extern struct {
    /// Optional shape name for debugging
    name: ?[*:0]const u8,
    /// Use this to store application specific shape data.
    userData: ?*anyopaque,
    /// Surface material used on mesh shapes per triangle. Ignored for convex shapes. Ignored for compound shapes.
    materials: ?[*]const SurfaceMaterial,
    /// Surface material count.
    materialCount: c_int,
    /// The base surface material. Ignored for compound shapes.
    baseMaterial: SurfaceMaterial,
    /// The density, usually in kg/m^3.
    density: f32,
    /// Explosion scale for `World.explode`. non-dimensional
    explosionScale: f32,
    /// Contact filtering data.
    filter: Filter,
    /// Enable custom filtering. Only one of the two shapes needs to enable custom filtering. See `WorldDef`.
    enableCustomFiltering: bool,
    /// A sensor shape generates overlap events but never generates a collision response.
    /// Sensors do not have continuous collision. Instead, use a ray or shape cast for those scenarios.
    /// Sensors still contribute to the body mass if they have non-zero density.
    /// Note: Sensor events are disabled by default.
    /// See enableSensorEvents.
    isSensor: bool,
    /// Enable sensor events for this shape. This applies to sensors and non-sensors. False by default, even for sensors.
    /// Only convex shapes may act as sensor visitors.
    enableSensorEvents: bool,
    /// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors. False by default.
    enableContactEvents: bool,
    /// Enable hit events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors. False by default.
    enableHitEvents: bool,
    /// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
    /// and must be carefully handled due to multithreading. Ignored for sensors.
    enablePreSolveEvents: bool,
    /// When shapes are created they will scan the environment for collision the next time step. This can significantly slow down
    /// static body creation when there are many static shapes.
    /// This is flag is ignored for dynamic and kinematic shapes which always invoke contact creation.
    invokeContactCreation: bool,
    /// Should the body update the mass properties when this shape is created. Default is true.
    /// Warning: if this is false, you MUST call `Body.applyMassFromShapes` or `Body.setMassData` before simulating the world.
    updateBodyMass: bool,
    /// Enable speculative collision. Leave this true unless you care about reducing ghost collision
    /// more than continuous collision under rotation.
    /// Experimental: this can only disable speculative contact between hulls and triangles (meshes and height fields).
    enableSpeculativeContact: bool,
    /// Used internally to detect a valid definition. DO NOT SET.
    internalValue: c_int,

    /// Use this to initialize your shape definition
    pub const default = b3DefaultShapeDef;
    extern fn b3DefaultShapeDef() ShapeDef;
};

/// Use this to initialize your shape definition
pub const defaultShapeDef = ShapeDef.default;

const std = @import("std");

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const Body = b3.Body;
const Capsule = b3.Capsule;
const CompoundData = b3.CompoundData;
const ContactData = b3.ContactData;
const HeightFieldData = b3.HeightFieldData;
const HullData = b3.HullData;
const MassData = b3.MassData;
const Mesh = b3.Mesh;
const MeshData = b3.MeshData;
const Pos = b3.Pos;
const Sphere = b3.Sphere;
const Vec3 = b3.Vec3;
const World = b3.World;
const WorldCastOutput = b3.WorldCastOutput;
/// Create a circle shape and attach it to a body. The shape definition and geometry are fully cloned.
/// Contacts are not created until the next time step.
/// Returns the shape id for accessing the shape
pub const createSphereShape = Body.createSphereShape;
/// Create a capsule shape and attach it to a body. The shape definition and geometry are fully cloned.
/// Contacts are not created until the next time step.
/// Returns the shape id for accessing the shape
pub const createCapsuleShape = Body.createCapsuleShape;
/// Create a convex hull shape and attach it to a body. The shape definition is fully cloned. Contacts are not created
/// until the next time step.
/// Returns the shape id for accessing the shape
pub const createHullShape = Body.createHullShape;
/// Create a convex hull shape and attach it to a body. The hull is cloned then transformed with scale applied first.
/// Use this for non-uniform or mirrored scale or a baked local transform. The baked result is shared through the
/// world hull database. The shape definition and geometry are fully cloned. Contacts are not created until the next time step.
/// Returns the shape id for accessing the shape
pub const createTransformedHullShape = Body.createTransformedHullShape;
/// Create a mesh hull shape and attach it to a body. The shape definition is fully cloned but the mesh is not.
/// Contacts are not created until the next time step.
/// Mesh collision only creates contacts on static bodies.
/// Warning: this holds reference to the input mesh data which must remain valid for the lifetime of this shape
/// Returns the shape id for accessing the shape
pub const createMeshShape = Body.createMeshShape;
/// Create a height-field shape and attach it to a body. The shape definition is fully cloned but the height field is not.
/// Contacts are not created until the next time step.
/// Height field is only allowed on static bodies.
/// Warning: this holds reference to the input height field which must remain valid for the lifetime of this shape
/// Returns the shape id for accessing the shape
pub const createHeightFieldShape = Body.createHeightFieldShape;
/// Baked compound shapes are only allowed on static bodies.
/// Note: runtime compounds are achieved by adding multiple shapes to a body.
/// Runtime compounds can be dynamic and/or kinematic.
pub const createBakedCompoundShape = Body.createBakedCompoundShape;
