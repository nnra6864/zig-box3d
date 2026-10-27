"""Hand written parts of the bindings, used by gen.py."""

TYPE_RENAMES: dict[str, str] = {}

OPAQUES = {"b3Recording", "b3RecPlayer"}

# Written by hand (MeshEdgeFlags is a packed struct in geometry extras).
# b3World_DumpShapeBounds is declared but has no implementation.
SKIP = {"b3MeshEdgeFlags", "b3World_DumpShapeBounds"}

FILES = {
    "b3ContactData": "contact",
    "b3DestroyDebugShapeCallback": "debug_draw",
    "b3CreateDebugShapeCallback": "debug_draw",
    "b3Manifold": "contact",
    "b3ManifoldPoint": "contact",
}

FILE_ORDER = [
    "base", "constants", "math", "world", "events", "recording", "body", "shape", "joint", "contact",
    "query", "tree", "mover", "geometry", "collision", "debug_draw",
]

FILE_TITLES = {
    "base": "Base functionality (base.h)",
    "constants": "Constants and length units (constants.h)",
    "math": "Vector math types and functions (math_functions.h)",
    "world": "World (box3d.h, types.h)",
    "events": "World event types (types.h)",
    "recording": "Recording and replay (box3d.h)",
    "body": "Body (box3d.h, types.h)",
    "shape": "Shape (box3d.h, types.h)",
    "joint": "Joints (box3d.h, types.h)",
    "contact": "Contact (box3d.h, types.h)",
    "query": "Queries: ray casts, shape casts, distance and time of impact (types.h, collision.h)",
    "tree": "Dynamic tree, a binary AABB tree to organize and query geometric objects (types.h, collision.h)",
    "mover": "Character mover (types.h, collision.h)",
    "geometry": "Geometry: spheres, capsules, hulls, meshes, height fields and compounds (types.h, collision.h)",
    "collision": "Shape collision (types.h, collision.h)",
    "debug_draw": "Debug draw (types.h)",
}

# C function -> (owner type or None, method name, flat alias name or None)
OWNERS = {
    # world
    "b3CreateWorld": ("World", "create", "createWorld"),
    "b3DestroyWorld": ("World", "destroy", None),
    # recording
    "b3CreateRecording": ("Recording", "create", None),
    "b3DestroyRecording": ("Recording", "destroy", None),
    "b3SaveRecordingToFile": ("Recording", "saveToFile", None),
    "b3LoadRecordingFromFile": ("Recording", "loadFromFile", None),
    "b3CreatePlayer": ("RecPlayer", "create", None),
    "b3DestroyPlayer": ("RecPlayer", "destroy", None),
    # body
    "b3CreateBody": ("World", "createBody", "createBody"),
    "b3DestroyBody": ("Body", "destroy", None),
    # shape
    "b3CreateSphereShape": ("Body", "createSphereShape", "createSphereShape"),
    "b3CreateCapsuleShape": ("Body", "createCapsuleShape", "createCapsuleShape"),
    "b3CreateHullShape": ("Body", "createHullShape", "createHullShape"),
    "b3CreateTransformedHullShape": ("Body", "createTransformedHullShape", "createTransformedHullShape"),
    "b3CreateMeshShape": ("Body", "createMeshShape", "createMeshShape"),
    "b3CreateHeightFieldShape": ("Body", "createHeightFieldShape", "createHeightFieldShape"),
    "b3CreateBakedCompoundShape": ("Body", "createBakedCompoundShape", "createBakedCompoundShape"),
    "b3DestroyShape": ("Shape", "destroy", None),
    # joints
    "b3DestroyJoint": ("Joint", "destroy", None),
    # hull
    "b3CloneHull": ("HullData", "clone", None),
    "b3CloneAndTransformHull": ("HullData", "cloneAndTransform", None),
    "b3DestroyHull": ("HullData", "destroy", None),
    "b3DestroyMesh": ("MeshData", "destroy", None),
    "b3GetHeight": ("MeshData", "getHeight", None),
    "b3DestroyHeightField": ("HeightFieldData", "destroy", None),
    # compound
    "b3GetCompoundChild": ("CompoundData", "getChild", None),
    "b3QueryCompound": ("CompoundData", "query", None),
    "b3GetCompoundCapsule": ("CompoundData", "getCapsule", None),
    "b3GetCompoundHull": ("CompoundData", "getHull", None),
    "b3GetCompoundMesh": ("CompoundData", "getMesh", None),
    "b3GetCompoundSphere": ("CompoundData", "getSphere", None),
    "b3GetCompoundMaterials": ("CompoundData", "getMaterials", None),
    "b3DestroyCompound": ("CompoundData", "destroy", None),
    # geometry
    "b3ComputeSphereMass": ("Sphere", "computeMass", None),
    "b3ComputeCapsuleMass": ("Capsule", "computeMass", None),
    "b3ComputeHullMass": ("HullData", "computeMass", None),
    "b3ComputeSphereAABB": ("Sphere", "computeAABB", None),
    "b3ComputeCapsuleAABB": ("Capsule", "computeAABB", None),
    "b3ComputeHullAABB": ("HullData", "computeAABB", None),
    "b3ComputeMeshAABB": ("MeshData", "computeAABB", None),
    "b3ComputeHeightFieldAABB": ("HeightFieldData", "computeAABB", None),
    "b3ComputeCompoundAABB": ("CompoundData", "computeAABB", None),
    # query
    "b3IsValidRay": ("RayCastInput", "isValid", None),
    "b3OverlapCapsule": ("Capsule", "overlap", None),
    "b3OverlapCompound": ("CompoundData", "overlap", None),
    "b3OverlapHeightField": ("HeightFieldData", "overlap", None),
    "b3OverlapHull": ("HullData", "overlap", None),
    "b3OverlapMesh": ("Mesh", "overlap", None),
    "b3OverlapSphere": ("Sphere", "overlap", None),
    "b3RayCastSphere": ("Sphere", "rayCast", None),
    "b3RayCastHollowSphere": ("Sphere", "rayCastHollow", None),
    "b3RayCastCapsule": ("Capsule", "rayCast", None),
    "b3RayCastCompound": ("CompoundData", "rayCast", None),
    "b3RayCastHull": ("HullData", "rayCast", None),
    "b3RayCastMesh": ("Mesh", "rayCast", None),
    "b3RayCastHeightField": ("HeightFieldData", "rayCast", None),
    "b3ShapeCastSphere": ("Sphere", "shapeCast", None),
    "b3ShapeCastCapsule": ("Capsule", "shapeCast", None),
    "b3ShapeCastCompound": ("CompoundData", "shapeCast", None),
    "b3ShapeCastHull": ("HullData", "shapeCast", None),
    "b3ShapeCastMesh": ("Mesh", "shapeCast", None),
    "b3ShapeCastHeightField": ("HeightFieldData", "shapeCast", None),
    "b3QueryMesh": ("Mesh", "query", None),
    "b3QueryHeightField": ("HeightFieldData", "query", None),
    "b3GetSweepTransform": ("Sweep", "getTransform", None),
}
for _k in ["Distance", "Motor", "Filter", "Parallel", "Prismatic", "Revolute", "Spherical", "Weld", "Wheel"]:
    OWNERS[f"b3Create{_k}Joint"] = ("World", f"create{_k}Joint", f"create{_k}Joint")

PARAM_RENAMES = {"type": "bodyType"}
FUNC_PARAM_RENAMES = {("b3World_Draw", "draw"): "debugDraw", ("b3Hash", "hash"): "seed"}

# (function, param) -> Zig type
PARAM_TYPES = {
    ("b3SetAllocator", "allocFcn"): "?AllocFcn",
    ("b3SetAllocator", "freeFcn"): "?FreeFcn",
    ("b3Hash", "data"): "[*]const u8",
    ("b3CreateHull", "points"): "[*]const Vec3",
    ("b3CreateMesh", "degenerateTriangleIndices"): "?[*]i32",
    ("b3ValidateCompound", "bytes"): "[*]const u8",
    ("b3ShapeDistance", "simplexes"): "?[*]Simplex",
    ("b3CollideTriangleAndCapsule", "triangleA"): "*const [3]Vec3",
    ("b3CollideTriangleAndSphere", "triangleA"): "*const [3]Vec3",
    ("b3Hull2D", "pts"): "[*]Point2D",
    ("b3Hull2D", "hull"): "[*]Point2D",
    ("b3SimplifyHull2D", "hull"): "[*]Point2D",
    ("b3SolvePlanes", "planes"): "[*]CollisionPlane",
    ("b3ClipVector", "planes"): "[*]const CollisionPlane",
    ("b3World_CastMover", "fcn"): "?MoverFilterFcn",
    ("b3World_SetCustomFilterCallback", "fcn"): "?CustomFilterFcn",
    ("b3World_SetPreSolveCallback", "fcn"): "?PreSolveFcn",
    ("b3World_SetFrictionCallback", "callback"): "?FrictionCallback",
    ("b3World_SetRestitutionCallback", "callback"): "?RestitutionCallback",
    ("b3RecPlayer_SetDebugShapeCallbacks", "destroyDebugShape"): "?DestroyDebugShapeCallback",
    ("b3CreatePlayer", "data"): "[*]const u8",
    ("b3ValidateReplay", "data"): "[*]const u8",
    ("b3Body_GetShapes", "shapeArray"): "[*]Shape",
    ("b3Body_GetJoints", "jointArray"): "[*]Joint",
    ("b3Body_GetContactData", "contactData"): "[*]ContactData",
    ("b3Body_CollideMover", "bodyPlanes"): "[*]BodyPlaneResult",
    ("b3Shape_GetContactData", "contactData"): "[*]ContactData",
    ("b3Shape_GetSensorData", "visitorIds"): "[*]Shape",
    ("b3CreateBakedCompoundShape", "def"): "*const ShapeDef",
    ("b3DestroyRecording", "recording"): "*Recording",
}

RET_TYPES = {
    "b3CreateRecording": "*Recording",
    "b3Recording_GetData": "?[*]const u8",
    "b3Body_GetName": "[*:0]const u8",
    "b3Shape_GetName": "[*:0]const u8",
    "b3Shape_GetHull": "*const HullData",
    "b3Shape_GetHeightField": "*const HeightFieldData",
    "b3Shape_GetCompound": "*const CompoundData",
    "b3GetCompoundMaterials": "[*]const SurfaceMaterial",
    "b3World_GetBodyEvents": "BodyEvents.Extern",
    "b3World_GetSensorEvents": "SensorEvents.Extern",
    "b3World_GetContactEvents": "ContactEvents.Extern",
    "b3World_GetJointEvents": "JointEvents.Extern",
}

# Functions whose extern declaration is written in the wrapper.
CUSTOM_EXTERNS = {"b3CreateWorld"}

_ID_FIELD_DEFAULTS = {}
for _id in ["b3WorldId", "b3BodyId", "b3ShapeId", "b3JointId", "b3ContactId"]:
    for _f in ["index1", "world0", "generation", "padding"]:
        _ID_FIELD_DEFAULTS[(_id, _f)] = " = 0"

FIELD_DEFAULTS = {
    **_ID_FIELD_DEFAULTS,
    ("b3SimplexCache", "metric"): " = 0",
    ("b3SimplexCache", "count"): " = 0",
    ("b3SimplexCache", "indexA"): " = @splat(0)",
    ("b3SimplexCache", "indexB"): " = @splat(0)",
    ("b3SATCache", "separation"): " = 0",
    ("b3SATCache", "type"): " = .invalid",
    ("b3SATCache", "indexA"): " = 0",
    ("b3SATCache", "indexB"): " = 0",
    ("b3SATCache", "hit"): " = 0",
}

FIELD_TYPES = {
    ("b3SATCache", "type"): "SeparatingFeature",
    ("b3ShapeDef", "materials"): "?[*]const SurfaceMaterial",
    ("b3MeshDef", "vertices"): "?[*]const Vec3",
    ("b3MeshDef", "indices"): "?[*]const i32",
    ("b3MeshDef", "materialIndices"): "?[*]const u8",
    ("b3HeightFieldDef", "heights"): "?[*]const f32",
    ("b3HeightFieldDef", "materialIndices"): "?[*]const u8",
    ("b3CompoundDef", "capsules"): "?[*]const CompoundCapsuleDef",
    ("b3CompoundDef", "hulls"): "?[*]const CompoundHullDef",
    ("b3CompoundDef", "meshes"): "?[*]const CompoundMeshDef",
    ("b3CompoundDef", "spheres"): "?[*]const CompoundSphereDef",
    ("b3CompoundMeshDef", "materials"): "?[*]const SurfaceMaterial",
    ("b3CompoundMesh", "materialIndices"): "?[*]const u16",
    ("b3ShapeProxy", "points"): "[*]const Vec3",
    ("b3LocalManifold", "points"): "?[*]LocalManifoldPoint",
    ("b3LocalManifold", "feature"): "TriangleFeature",
    ("b3DynamicTree", "nodes"): "?[*]TreeNode",
    ("b3DynamicTree", "parents"): "?[*]i32",
    ("b3DynamicTree", "proxies"): "?[*]TreeProxy",
    ("b3DynamicTree", "swapNodes"): "?[*]TreeNode",
    ("b3DynamicTree", "leafIndices"): "?[*]i32",
    ("b3DynamicTree", "leafNodes"): "?[*]TreeNode",
    ("b3DynamicTree", "leafBoxes"): "?[*]AABB",
    ("b3DynamicTree", "leafCenters"): "?[*]Vec3",
    ("b3DynamicTree", "binIndices"): "?[*]i32",
    ("b3ContactData", "manifolds"): "?[*]const Manifold",
}

ENUMS = {
    "b3BodyType": {"suffix": "Body", "count": {"b3_bodyTypeCount"}},
    "b3ShapeType": {"suffix": "Shape", "count": {"b3_shapeTypeCount"}},
    "b3JointType": {"suffix": "Joint"},
    "b3TOIState": {"prefix": "toiState"},
    "b3SeparatingFeature": {
        "tag": "u8",
        "names": {
            "b3_invalidAxis": "invalid",
            "b3_backsideAxis": "backside",
            "b3_faceAxisA": "face_a",
            "b3_faceAxisB": "face_b",
            "b3_edgePairAxis": "edge_pair",
            "b3_closestPointsAxis": "closest_points",
            "b3_manualFaceAxisA": "manual_face_a",
            "b3_manualFaceAxisB": "manual_face_b",
            "b3_manualEdgePairAxis": "manual_edge_pair",
        },
    },
    "b3TriangleFeature": {"prefix": "feature"},
    "b3HexColor": {"prefix": "color", "open": True},
    "b3DebugMaterial": {"prefix": "debugMaterial"},
    "b3RecQueryType": {"prefix": "recQuery"},
}

# ---------------------------------------------------------------------------- id types


def _id_extras(name, store_bits):
    eql = {
        "World": "a.index1 == b.index1 and a.generation == b.generation",
    }.get(name, "a.index1 == b.index1 and a.world0 == b.world0 and a.generation == b.generation")
    out = f"""/// A null id. Zero initialization also gives a null id.
pub const null_id: {name} = .{{}};

/// Is this id null?
pub fn isNull(id: {name}) bool {{
    return id.index1 == 0;
}}

/// Is this id non-null?
pub fn isNonNull(id: {name}) bool {{
    return id.index1 != 0;
}}

/// Compare two ids for equality.
pub fn eql(a: {name}, b: {name}) bool {{
    return {eql};
}}
"""
    if store_bits == 32:
        out += f"""
/// Store a world id into a u32.
pub fn store(id: World) u32 {{
    return @as(u32, id.index1) << 16 | id.generation;
}}

/// Load a u32 into a world id.
pub fn load(x: u32) World {{
    return .{{ .index1 = @truncate(x >> 16), .generation = @truncate(x) }};
}}
"""
    elif store_bits == 64:
        lname = name.lower()
        out += f"""
/// Store a {lname} id into a u64.
pub fn store(id: {name}) u64 {{
    return @as(u64, @as(u32, @bitCast(id.index1))) << 32 | @as(u64, id.world0) << 16 | id.generation;
}}

/// Load a u64 into a {lname} id.
pub fn load(x: u64) {name} {{
    return .{{ .index1 = @bitCast(@as(u32, @truncate(x >> 32))), .world0 = @truncate(x >> 16), .generation = @truncate(x) }};
}}
"""
    else:
        out += """
/// Store a contact id into three u32 values.
pub fn store(id: Contact) [3]u32 {
    return .{ @bitCast(id.index1), id.world0, id.generation };
}

/// Load a contact id from three u32 values.
pub fn load(values: [3]u32) Contact {
    return .{ .index1 = @bitCast(values[0]), .world0 = @truncate(values[1]), .padding = 0, .generation = values[2] };
}
"""
    return out


TYPE_EXTRAS = {
    "World": _id_extras("World", 32),
    "Body": _id_extras("Body", 64)
    + """
/// The closest point on a body and its distance to the target.
pub const ClosestPoint = struct {
    point: Vec3,
    distance: f32,
};
""",
    "Shape": _id_extras("Shape", 64),
    "Joint": _id_extras("Joint", 64)
    + """
/// Constraint tuning parameters.
pub const ConstraintTuning = struct {
    /// The stiffness in Hertz (cycles per second)
    hertz: f32,
    /// The non-dimensional damping ratio (one for critical damping)
    dampingRatio: f32,
};

/// Cast to a typed joint handle such as `RevoluteJoint`. Asserts that the joint has that type.
pub fn as(jointId: Joint, comptime T: type) T {
    std.debug.assert(jointId.getType() == T.joint_type);
    return .{ .joint = jointId };
}
""",
    "Contact": _id_extras("Contact", 96),
    "DynamicTree": """/// Dynamic tree version for compatibility testing.
pub const current_version: u64 = 0x1D6F4C2A73B80E91;

/// Get proxy user data
pub fn getUserData(tree: *const DynamicTree, proxyId: c_int) u64 {
    return tree.proxies.?[@intCast(proxyId)].userData;
}

/// Get the AABB of a proxy
pub fn getAABB(tree: *const DynamicTree, proxyId: c_int) AABB {
    return tree.nodes.?[@intCast(tree.proxies.?[@intCast(proxyId)].node)].aabb;
}
""",
    "HullData": """/// Hull version. Useful for validating serialized data.
pub const current_version: u64 = 0x6B1E39D4A87C25F3;

/// Get read only hull vertices.
pub fn getVertices(hull: *const HullData) []const HullVertex {
    return trailing(HullVertex, hull, hull.vertexOffset, hull.vertexCount);
}

/// Get read only hull points.
pub fn getPoints(hull: *const HullData) []const Vec3 {
    return trailing(Vec3, hull, hull.pointOffset, hull.vertexCount);
}

/// Get read only hull half edges.
pub fn getEdges(hull: *const HullData) []const HullHalfEdge {
    return trailing(HullHalfEdge, hull, hull.edgeOffset, hull.edgeCount);
}

/// Get read only hull planes.
pub fn getPlanes(hull: *const HullData) []const Plane {
    return trailing(Plane, hull, hull.planeOffset, hull.faceCount);
}

/// Get read only hull faces.
pub fn getFaces(hull: *const HullData) []const HullFace {
    return trailing(HullFace, hull, hull.faceOffset, hull.faceCount);
}

/// Get read only SOA vertices. This is an array of vertices with all x values,
/// y values, and z values as separate arrays. The array lengths are padded to
/// a multiple of 8. The padded values are repeats of the first value.
pub fn getSoaVertices(hull: *const HullData) []const f32 {
    return trailing(f32, hull, hull.soaVertexOffset, 3 * soaStride(hull.vertexCount));
}

/// Get read only SOA unit normal vectors. This is an array of normals with all x values,
/// y values, and z values as separate arrays. The array lengths are padded to
/// a multiple of 8. The padded values are 0.
pub fn getSoaNormals(hull: *const HullData) []const f32 {
    return trailing(f32, hull, hull.soaNormalOffset, 3 * soaStride(hull.faceCount));
}

/// Get the dot products of the two adjacent face normals for each full edge.
pub fn getEdgeCosines(hull: *const HullData) []const f32 {
    return trailing(f32, hull, hull.edgeCosineOffset, @divTrunc(hull.edgeCount, 2));
}

fn soaStride(count: i32) i32 {
    return (count + 7) & ~@as(i32, 7);
}
""",
    "BoxHull": """/// The embedded hull, to pass to functions taking a `HullData`.
pub fn hull(box: *const BoxHull) *const HullData {
    return &box.base;
}
""",
    "MeshData": """/// Mesh version. Useful for validating serialized data.
pub const current_version: u64 = 0xAAAB9A00F1A8AAF7;

/// Get read only mesh BVH nodes.
pub fn getNodes(mesh: *const MeshData) []const MeshNode {
    return trailing(MeshNode, mesh, mesh.nodeOffset, mesh.nodeCount);
}

/// Get read only mesh vertices.
pub fn getVertices(mesh: *const MeshData) []const Vec3 {
    return trailing(Vec3, mesh, mesh.vertexOffset, mesh.vertexCount);
}

/// Get read only mesh triangles.
pub fn getTriangles(mesh: *const MeshData) []const MeshTriangle {
    return trailing(MeshTriangle, mesh, mesh.triangleOffset, mesh.triangleCount);
}

/// Get read only mesh materials. The count is equal to the triangle count.
pub fn getMaterialIndices(mesh: *const MeshData) []const u8 {
    return trailing(u8, mesh, mesh.materialOffset, mesh.triangleCount);
}

/// Get read only mesh flags. The count is equal to the triangle count.
pub fn getFlags(mesh: *const MeshData) []const MeshEdgeFlags {
    return trailing(MeshEdgeFlags, mesh, mesh.flagsOffset, mesh.triangleCount);
}
""",
    "HeightFieldData": """/// Height field version. Useful for validating serialized data.
pub const current_version: u64 = 0x8E41E5FB084848F8;

/// This material index is used to designate holes in a height field.
pub const hole: u8 = 0xFF;

/// Get read only compressed heights. One u16 per grid point.
pub fn getCompressedHeights(hf: *const HeightFieldData) []const u16 {
    return trailing(u16, hf, hf.heightsOffset, hf.rowCount * hf.columnCount);
}

/// Get read only material indices. One u8 per cell.
pub fn getMaterialIndices(hf: *const HeightFieldData) []const u8 {
    return trailing(u8, hf, hf.materialOffset, cellCount(hf));
}

/// Get read only triangle flags. One per triangle.
pub fn getFlags(hf: *const HeightFieldData) []const MeshEdgeFlags {
    return trailing(MeshEdgeFlags, hf, hf.flagsOffset, 2 * cellCount(hf));
}

fn cellCount(hf: *const HeightFieldData) i32 {
    return @max(hf.rowCount - 1, 0) * @max(hf.columnCount - 1, 0);
}
""",
    "CompoundData": """/// Compound version. Depends on the mesh and hull versions.
pub const current_version: u64 = 0x9E4B17D3A25C68F1 ^ MeshData.current_version ^ HullData.current_version;
""",
    "ContactData": """/// The contact manifolds. This points to internal data and may become invalid. Do not store it.
pub fn getManifolds(data: ContactData) []const Manifold {
    const ptr = data.manifolds orelse return &.{};
    return ptr[0..@intCast(data.manifoldCount)];
}
""",
    "ShapeProxy": """/// Make a shape proxy from a point cloud and radius. `points.len` must not exceed `max_shape_cast_points`.
pub fn init(points: []const Vec3, radius: f32) ShapeProxy {
    std.debug.assert(points.len <= b3.max_shape_cast_points);
    return .{ .points = points.ptr, .count = @intCast(points.len), .radius = radius };
}
""",
    "SimplexCache": """/// An empty cache, the same as zero initialization.
pub const empty: SimplexCache = .{};
""",
    "HexColor": """/// Make a color from an RGB value such as 0xFF8800.
pub fn rgb(value: u24) HexColor {
    return @fromBackingInt(value);
}

/// Pack an RGB color with a material preset for debug draw. The preset rides in
/// the high byte where the color converters ignore it.
pub fn withMaterial(color: HexColor, material: DebugMaterial) HexColor {
    const bits: u32 = @bitCast(@backingInt(color));
    const mat: u32 = @intCast(@backingInt(material));
    return @fromBackingInt(@bitCast((bits & 0x00FF_FFFF) | (mat << 24)));
}
""",
}

# Hand written struct bodies. The generator adds methods before the closing brace.
STRUCT_BODIES = {
    "b3SensorEvents": """
pub const SensorEvents = struct {
    /// Array of sensor begin touch events
    beginEvents: []const SensorBeginTouchEvent,
    /// Array of sensor end touch events
    endEvents: []const SensorEndTouchEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        beginEvents: ?[*]const SensorBeginTouchEvent,
        endEvents: ?[*]const SensorEndTouchEvent,
        beginCount: c_int,
        endCount: c_int,
    };
};
""",
    "b3ContactEvents": """
pub const ContactEvents = struct {
    /// Array of begin touch events
    beginEvents: []const ContactBeginTouchEvent,
    /// Array of end touch events
    endEvents: []const ContactEndTouchEvent,
    /// Array of hit events
    hitEvents: []const ContactHitEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        beginEvents: ?[*]const ContactBeginTouchEvent,
        endEvents: ?[*]const ContactEndTouchEvent,
        hitEvents: ?[*]const ContactHitEvent,
        beginCount: c_int,
        endCount: c_int,
        hitCount: c_int,
    };
};
""",
    "b3BodyEvents": """
pub const BodyEvents = struct {
    /// Array of move events
    moveEvents: []const BodyMoveEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        moveEvents: ?[*]const BodyMoveEvent,
        moveCount: c_int,
    };
};
""",
    "b3JointEvents": """
pub const JointEvents = struct {
    /// Array of events
    jointEvents: []const JointEvent,

    /// The C layout of these events.
    pub const Extern = extern struct {
        jointEvents: ?[*]const JointEvent,
        count: c_int,
    };
};
""",
    "b3TreeNode": """
pub const TreeNode = extern struct {
    /// The node bounding box
    aabb: AABB,
    /// bit 31 : 1 for leaf node
    /// bit 30 : 1 for moved flag
    /// bits 0-29 : index of the sibling pair node or the proxy id for a leaf
    flagIndex: u32,
    data: extern union {
        /// The height of an internal node. A leaf has zero height.
        height: i32,
        /// The shape index for a leaf. Truncated from proxy user data.
        shapeIndex: i32,
    },
};
""",
    "b3MeshNode": """
pub const MeshNode = extern struct {
    /// The lower bound of the node AABB. Strategic placement for SIMD.
    lowerBound: Vec3,
    data: extern union {
        /// Internal node
        asNode: packed struct(u32) {
            /// Split axis. 0, 1, or 2.
            axis: u2,
            /// Offset of the second child node.
            childOffset: u30,
        },
        /// Leaf node
        asLeaf: packed struct(u32) {
            /// Aligned with axis above and has value of 3 if this is a leaf.
            type: u2,
            /// The number of triangles for this leaf node.
            triangleCount: u30,
        },
    },
    /// The upper bound of the node AABB. Strategic placement for SIMD.
    upperBound: Vec3,
    /// The index of the leaf triangles.
    triangleOffset: u32,
};
""",
    "b3ChildShape": """
pub const ChildShape = extern struct {
    /// Tagged union, see `type`.
    shape: extern union {
        capsule: Capsule,
        hull: *const HullData,
        mesh: Mesh,
        sphere: Sphere,
    },
    /// Transform of the shape into compound local space.
    transform: Transform,
    /// Material indices. Index 0 is used for convex shapes.
    materialIndices: ?[*]const u16,
    /// The number of materials. This is one for convex shapes. For
    /// meshes it is determined by the maximum triangle material index.
    materialCount: c_int,
    /// The shape type (union tag).
    type: ShapeType,
};
""",
    "b3DebugShape": """
pub const DebugShape = extern struct {
    /// Shape id.
    shapeId: Shape,
    /// Shape type.
    type: ShapeType,
    /// Tagged union, see `type`.
    shape: extern union {
        capsule: *const Capsule,
        compound: *const CompoundData,
        heightField: *const HeightFieldData,
        hull: *const HullData,
        mesh: *const Mesh,
        sphere: *const Sphere,
    },
};
""",
    "b3DebugDraw": """
pub const DebugDraw = extern struct {
    /// Draws a user shape. The userShape pointer is owned by the application and is known to Box3D as
    /// an opaque pointer returned from `CreateDebugShapeCallback`. When this is called the drawn shape has
    /// passed a culling test against drawingBounds below.
    DrawShapeFcn: ?*const fn (userShape: ?*anyopaque, transform: WorldTransform, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a line segment.
    DrawSegmentFcn: ?*const fn (p1: Pos, p2: Pos, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a transform. Choose your own length scale.
    DrawTransformFcn: ?*const fn (transform: WorldTransform, context: ?*anyopaque) callconv(.c) void,
    /// Draw a point.
    DrawPointFcn: ?*const fn (p: Pos, size: f32, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a sphere.
    DrawSphereFcn: ?*const fn (p: Pos, radius: f32, color: HexColor, alpha: f32, context: ?*anyopaque) callconv(.c) void,
    /// Draw a capsule.
    DrawCapsuleFcn: ?*const fn (p1: Pos, p2: Pos, radius: f32, color: HexColor, alpha: f32, context: ?*anyopaque) callconv(.c) void,
    /// Draw a bounding box.
    DrawBoundsFcn: ?*const fn (aabb: AABB, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw an oriented box.
    DrawBoxFcn: ?*const fn (extents: Vec3, transform: WorldTransform, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// Draw a string in world space
    DrawStringFcn: ?*const fn (p: Pos, s: [*:0]const u8, color: HexColor, context: ?*anyopaque) callconv(.c) void,
    /// World bounds to use for debug draw
    drawingBounds: AABB,
    /// Scale to use when drawing forces
    forceScale: f32,
    /// Global scaling for joint drawing
    jointScale: f32,
    /// Option to draw shapes
    drawShapes: bool,
    /// Option to draw joints
    drawJoints: bool,
    /// Option to draw additional information for joints
    drawJointExtras: bool,
    /// Option to draw the bounding boxes for shapes
    drawBounds: bool,
    /// Option to draw the mass and center of mass of dynamic bodies
    drawMass: bool,
    /// Option to draw the sleep information for dynamic and kinematic bodies
    drawSleep: bool,
    /// Option to draw body names
    drawBodyNames: bool,
    /// Option to draw contact points
    drawContacts: bool,
    /// Draw contact anchor A or B
    drawAnchorA: bool,
    /// Option to visualize the graph coloring used for contacts and joints
    drawGraphColors: bool,
    /// Option to draw contact features
    drawContactFeatures: bool,
    /// Option to draw contact normals
    drawContactNormals: bool,
    /// Option to draw contact normal forces
    drawContactForces: bool,
    /// Option to draw islands as bounding boxes
    drawIslands: bool,
    /// User context that is passed as an argument to drawing callback functions
    context: ?*anyopaque,
};
""",
}

TYPED_JOINT_HEAD = """/// A @KIND@ joint. Use `joint` for the functions shared by all joint types.
pub const @NAME@ = extern struct {
    joint: Joint = .{},

    pub const joint_type: JointType = .@KIND@;
"""

# ---------------------------------------------------------------------------- wrappers

WRAPPERS = {
    "b3Hash": """
pub fn hash(seed: u32, data: []const u8) u32 {
    return b3Hash(seed, data.ptr, @intCast(data.len));
}""",
    "b3CreateWorld": """
pub fn create(def: *const WorldDef) World {
    return b3CreateWorld(def);
}
// Box3D renames this symbol in large world mode so mismatched builds fail to link.
const b3CreateWorld = @extern(*const fn (def: *const WorldDef) callconv(.c) World, .{
    .name = if (b3.double_precision) "b3CreateWorldDoublePrecision" else "b3CreateWorld",
});""",
    "b3World_GetBodyEvents": """
pub fn getBodyEvents(worldId: World) BodyEvents {
    const e = b3World_GetBodyEvents(worldId);
    return .{ .moveEvents = if (e.moveEvents) |p| p[0..@intCast(e.moveCount)] else &.{} };
}""",
    "b3World_GetSensorEvents": """
pub fn getSensorEvents(worldId: World) SensorEvents {
    const e = b3World_GetSensorEvents(worldId);
    return .{
        .beginEvents = if (e.beginEvents) |p| p[0..@intCast(e.beginCount)] else &.{},
        .endEvents = if (e.endEvents) |p| p[0..@intCast(e.endCount)] else &.{},
    };
}""",
    "b3World_GetContactEvents": """
pub fn getContactEvents(worldId: World) ContactEvents {
    const e = b3World_GetContactEvents(worldId);
    return .{
        .beginEvents = if (e.beginEvents) |p| p[0..@intCast(e.beginCount)] else &.{},
        .endEvents = if (e.endEvents) |p| p[0..@intCast(e.endCount)] else &.{},
        .hitEvents = if (e.hitEvents) |p| p[0..@intCast(e.hitCount)] else &.{},
    };
}""",
    "b3World_GetJointEvents": """
pub fn getJointEvents(worldId: World) JointEvents {
    const e = b3World_GetJointEvents(worldId);
    return .{ .jointEvents = if (e.jointEvents) |p| p[0..@intCast(e.count)] else &.{} };
}""",
    "b3Recording_GetData": """
pub fn getData(recording: *const Recording) []const u8 {
    const ptr = b3Recording_GetData(recording) orelse return &.{};
    return ptr[0..@intCast(b3Recording_GetSize(recording))];
}""",
    "b3ValidateReplay": """
pub fn validateReplay(data: []const u8, workerCount: c_int) bool {
    return b3ValidateReplay(data.ptr, @intCast(data.len), workerCount);
}""",
    "b3CreatePlayer": """
pub fn create(data: []const u8, workerCount: c_int) ?*RecPlayer {
    return b3CreatePlayer(data.ptr, @intCast(data.len), workerCount);
}""",
    "b3Body_GetName": """
pub fn getName(bodyId: Body) [:0]const u8 {
    return std.mem.span(b3Body_GetName(bodyId));
}""",
    "b3Shape_GetName": """
pub fn getName(shapeId: Shape) [:0]const u8 {
    return std.mem.span(b3Shape_GetName(shapeId));
}""",
    "b3Body_GetShapes": """
pub fn getShapes(bodyId: Body, shapeArray: []Shape) []Shape {
    return shapeArray[0..@intCast(b3Body_GetShapes(bodyId, shapeArray.ptr, @intCast(shapeArray.len)))];
}""",
    "b3Body_GetJoints": """
pub fn getJoints(bodyId: Body, jointArray: []Joint) []Joint {
    return jointArray[0..@intCast(b3Body_GetJoints(bodyId, jointArray.ptr, @intCast(jointArray.len)))];
}""",
    "b3Body_GetContactData": """
pub fn getContactData(bodyId: Body, contactData: []ContactData) []ContactData {
    return contactData[0..@intCast(b3Body_GetContactData(bodyId, contactData.ptr, @intCast(contactData.len)))];
}""",
    "b3Body_GetClosestPoint": """
pub fn getClosestPoint(bodyId: Body, target: Vec3) ClosestPoint {
    var point: Vec3 = undefined;
    const distance = b3Body_GetClosestPoint(bodyId, &point, target);
    return .{ .point = point, .distance = distance };
}""",
    "b3Body_CollideMover": """
pub fn collideMover(
    bodyId: Body,
    bodyPlanes: []BodyPlaneResult,
    origin: Pos,
    mover: *const Capsule,
    filter: QueryFilter,
    bodyTransform: WorldTransform,
) []BodyPlaneResult {
    const n = b3Body_CollideMover(bodyId, bodyPlanes.ptr, @intCast(bodyPlanes.len), origin, mover, filter, bodyTransform);
    return bodyPlanes[0..@intCast(n)];
}""",
    "b3Shape_GetContactData": """
pub fn getContactData(shapeId: Shape, contactData: []ContactData) []ContactData {
    return contactData[0..@intCast(b3Shape_GetContactData(shapeId, contactData.ptr, @intCast(contactData.len)))];
}""",
    "b3Shape_GetSensorData": """
pub fn getSensorData(shapeId: Shape, visitorIds: []Shape) []Shape {
    return visitorIds[0..@intCast(b3Shape_GetSensorData(shapeId, visitorIds.ptr, @intCast(visitorIds.len)))];
}""",
    "b3Joint_GetConstraintTuning": """
pub fn getConstraintTuning(jointId: Joint) ConstraintTuning {
    var tuning: ConstraintTuning = undefined;
    b3Joint_GetConstraintTuning(jointId, &tuning.hertz, &tuning.dampingRatio);
    return tuning;
}""",
    "b3DistanceJoint_GetSpringForceRange": """
pub fn getSpringForceRange(self: DistanceJoint) SpringForceRange {
    var range: SpringForceRange = undefined;
    b3DistanceJoint_GetSpringForceRange(self.joint, &range.lower, &range.upper);
    return range;
}

/// The force range of a distance joint spring.
pub const SpringForceRange = struct {
    /// How much tension the spring can sustain
    lower: f32,
    /// How much compression the spring can sustain
    upper: f32,
};""",
    "b3CreateHull": """
pub fn createHull(points: []const Vec3, maxVertexCount: c_int) ?*HullData {
    return b3CreateHull(points.ptr, @intCast(points.len), maxVertexCount);
}""",
    "b3CreateMesh": """
pub fn createMesh(def: *const MeshDef, degenerateTriangleIndices: []i32) ?*MeshData {
    return b3CreateMesh(def, degenerateTriangleIndices.ptr, @intCast(degenerateTriangleIndices.len));
}""",
    "b3GetCompoundMaterials": """
pub fn getMaterials(compound: *const CompoundData) []const SurfaceMaterial {
    return b3GetCompoundMaterials(compound)[0..@intCast(compound.materialCount)];
}""",
    "b3ValidateCompound": """
pub fn validateCompound(bytes: []const u8) ?*const CompoundData {
    return b3ValidateCompound(bytes.ptr, @intCast(bytes.len));
}""",
    "b3ShapeDistance": """
pub fn shapeDistance(input: *const DistanceInput, cache: *SimplexCache, simplexes: []Simplex) DistanceOutput {
    return b3ShapeDistance(input, cache, simplexes.ptr, @intCast(simplexes.len));
}""",
    "b3Hull2D": """
pub fn hull2D(points: []Point2D, hull: []Point2D) []Point2D {
    std.debug.assert(hull.len >= points.len);
    return hull[0..@intCast(b3Hull2D(points.ptr, @intCast(points.len), hull.ptr))];
}""",
    "b3SimplifyHull2D": """
pub fn simplifyHull2D(hull: []Point2D, target: c_int) []Point2D {
    return hull[0..@intCast(b3SimplifyHull2D(hull.ptr, @intCast(hull.len), target))];
}""",
    "b3SolvePlanes": """
pub fn solvePlanes(targetDelta: Vec3, planes: []CollisionPlane) PlaneSolverResult {
    return b3SolvePlanes(targetDelta, planes.ptr, @intCast(planes.len));
}""",
    "b3ClipVector": """
pub fn clipVector(vector: Vec3, planes: []const CollisionPlane) Vec3 {
    return b3ClipVector(vector, planes.ptr, @intCast(planes.len));
}""",
}

for _k in ["Distance", "Motor", "Filter", "Parallel", "Prismatic", "Revolute", "Spherical", "Weld", "Wheel"]:
    WRAPPERS[f"b3Create{_k}Joint"] = f"""
pub fn create{_k}Joint(worldId: World, def: *const {_k}JointDef) {_k}Joint {{
    return .{{ .joint = b3Create{_k}Joint(worldId, def) }};
}}"""
    RET_TYPES[f"b3Create{_k}Joint"] = "Joint"

# ---------------------------------------------------------------------------- file extras

FILE_EXTRAS = {
    "geometry": """
/// Triangle mesh edge flags.
pub const MeshEdgeFlags = packed struct(u8) {
    concaveEdge1: bool = false,
    concaveEdge2: bool = false,
    concaveEdge3: bool = false,
    _unused3: u1 = 0,
    inverseConcaveEdge1: bool = false,
    inverseConcaveEdge2: bool = false,
    inverseConcaveEdge3: bool = false,
    _unused7: u1 = 0,

    pub const all_concave_edges: MeshEdgeFlags = .{ .concaveEdge1 = true, .concaveEdge2 = true, .concaveEdge3 = true };
    pub const flat_edge1: MeshEdgeFlags = .{ .concaveEdge1 = true, .inverseConcaveEdge1 = true };
    pub const flat_edge2: MeshEdgeFlags = .{ .concaveEdge2 = true, .inverseConcaveEdge2 = true };
    pub const flat_edge3: MeshEdgeFlags = .{ .concaveEdge3 = true, .inverseConcaveEdge3 = true };
    pub const all_flat_edges: MeshEdgeFlags = @bitCast(@as(u8, 0x77));
};

/// Arrays hanging off the end of hull, mesh and height field data.
fn trailing(comptime T: type, base: anytype, offset: i32, count: i32) []const T {
    if (offset == 0 or count <= 0) return &.{};
    const ptr: [*]const T = @ptrFromInt(@intFromPtr(base) + @as(usize, @intCast(offset)));
    return ptr[0..@intCast(count)];
}
""",
    "query": """
/// Ray cast or shape-cast output in world space. In large world mode the hit point is a
/// world position so the result stays precise far from the world origin. In single precision
/// mode this is the same type as `CastOutput`.
pub const WorldCastOutput = if (b3.double_precision) extern struct {
    /// The surface normal at the hit point.
    normal: Vec3,
    /// The surface hit point in world space.
    point: Pos,
    /// The fraction of the input translation at collision.
    fraction: f32,
    /// The number of iterations used.
    iterations: c_int,
    /// The index of the mesh or height field triangle hit.
    triangleIndex: c_int,
    /// The index of the compound child shape.
    childIndex: c_int,
    /// The material index. May be -1 for null.
    materialIndex: c_int,
    /// Did the cast hit?
    hit: bool,
} else CastOutput;
""",
}
FILE_EXTRA_PUBS = {"geometry": ["MeshEdgeFlags"], "query": ["WorldCastOutput"]}

# Names used in doc comments that the parser does not see.
EXTRA_NAMES = {
    "b3Vec2": "Vec2", "b3Vec3": "Vec3", "b3Pos": "Pos", "b3Quat": "Quat", "b3Transform": "Transform",
    "b3WorldTransform": "WorldTransform", "b3Matrix3": "Matrix3", "b3AABB": "AABB", "b3Plane": "Plane",
    "b3CosSin": "CosSin", "b3WorldCastOutput": "WorldCastOutput", "b3MeshEdgeFlags": "MeshEdgeFlags",
    "b3InvMulWorldTransforms": "invMulWorldTransforms", "b3HexColor": "HexColor",
    "b3MakeDebugColor": "HexColor.withMaterial",
    "b3RecPlayer_Create": "RecPlayer.create",
    "b3_nullWorldId": "World.null_id", "b3_nullBodyId": "Body.null_id",
    "b3World_RayCastClosest": "World.castRayClosest",
    "b3Shape_GetSensorOverlaps": "Shape.getSensorData",
}

# Text replaced in doc comments, for C code examples and loose references.
DOC_REPLACE = {
    "b3BodyDef bodyDef = b3DefaultBodyDef();": "const body_def = b3.defaultBodyDef();",
    "b3BodyId myBodyId = b3CreateBody(myWorldId, &bodyDef);": "const body = world.createBody(&body_def);",
    "Used by b3Collide functions.": "Used by the `collide*` functions.",
}

MACRO_NAMES = {
    "B3_MAX_WORKERS": "max_workers",
    "B3_MAX_TASKS": "max_tasks",
    "B3_MAX_RESTITUTION_ITERATIONS": "max_restitution_iterations",
    "B3_MAX_SHAPE_CAST_POINTS": "max_shape_cast_points",
    "B3_MAX_HULL_VERTICES": "max_hull_vertices",
    "B3_MAX_HULL_FACES": "max_hull_faces",
    "B3_MAX_HULL_EDGES": "max_hull_edges",
    "B3_MAX_MANIFOLD_POINTS": "max_manifold_points",
    "B3_GRAPH_COLOR_COUNT": "graph_color_count",
    "B3_HULL_VERSION": "HullData.current_version",
    "B3_HUGE": "huge()",
    "B3_NULL_INDEX": "null_index",
    "B3_LINEAR_SLOP": "linearSlop()",
    "BOX3D_DOUBLE_PRECISION": "double_precision",
    "B3_MAX_AABB_MARGIN": "maxAABBMargin()",
    "B3_MESH_VERSION": "MeshData.current_version",
    "B3_HEIGHT_FIELD_VERSION": "HeightFieldData.current_version",
    "B3_COMPOUND_VERSION": "CompoundData.current_version",
    "B3_DYNAMIC_TREE_VERSION": "DynamicTree.current_version",
}

MATH_PUBS: list[str] = []
CONSTANT_PUBS: list[str] = []
