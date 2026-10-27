//! Geometry: spheres, capsules, hulls, meshes, height fields and compounds (types.h, collision.h)

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const CastOutput = b3.CastOutput;
const Matrix3 = b3.Matrix3;
const MeshQueryFcn = b3.MeshQueryFcn;
const Plane = b3.Plane;
const RayCastInput = b3.RayCastInput;
const ShapeCastInput = b3.ShapeCastInput;
const ShapeProxy = b3.ShapeProxy;
const ShapeType = b3.ShapeType;
const SurfaceMaterial = b3.SurfaceMaterial;
const Transform = b3.Transform;
const Vec3 = b3.Vec3;

/// This holds the mass data computed for a shape.
pub const MassData = extern struct {
    /// The shape mass
    mass: f32,
    /// The local center of mass position.
    center: Vec3,
    /// The inertia tensor about the shape center of mass.
    inertia: Matrix3,
};

/// A solid sphere
pub const Sphere = extern struct {
    /// The local center
    center: Vec3,
    /// The radius
    radius: f32,

    /// Compute mass properties of a sphere
    pub const computeMass = b3ComputeSphereMass;
    extern fn b3ComputeSphereMass(shape: *const Sphere, density: f32) MassData;

    /// Compute the bounding box of a transformed sphere
    pub const computeAABB = b3ComputeSphereAABB;
    extern fn b3ComputeSphereAABB(shape: *const Sphere, transform: Transform) AABB;

    /// Overlap shape versus sphere
    pub const overlap = b3OverlapSphere;
    extern fn b3OverlapSphere(shape: *const Sphere, shapeTransform: Transform, proxy: *const ShapeProxy) bool;

    /// Ray cast versus sphere in local space. A zero length ray is a point query. Initial overlap
    /// reports a hit at the ray origin with zero fraction and zero normal.
    pub const rayCast = b3RayCastSphere;
    extern fn b3RayCastSphere(shape: *const Sphere, input: *const RayCastInput) CastOutput;

    /// Ray cast versus a hollow sphere shell in local space. Unlike the solid sphere a ray starting
    /// inside is not an overlap: it passes through and hits the far wall.
    pub const rayCastHollow = b3RayCastHollowSphere;
    extern fn b3RayCastHollowSphere(shape: *const Sphere, input: *const RayCastInput) CastOutput;

    /// Shape cast versus a sphere. Initial overlap is treated as a miss.
    pub const shapeCast = b3ShapeCastSphere;
    extern fn b3ShapeCastSphere(shape: *const Sphere, input: *const ShapeCastInput) CastOutput;
};

/// A solid capsule can be viewed as two hemispheres connected by a cylinder.
pub const Capsule = extern struct {
    /// Local center of the first hemisphere
    center1: Vec3,
    /// Local center of the second hemisphere
    center2: Vec3,
    /// The radius of the hemispheres
    radius: f32,

    /// Compute mass properties of a capsule
    pub const computeMass = b3ComputeCapsuleMass;
    extern fn b3ComputeCapsuleMass(shape: *const Capsule, density: f32) MassData;

    /// Compute the bounding box of a transformed capsule
    pub const computeAABB = b3ComputeCapsuleAABB;
    extern fn b3ComputeCapsuleAABB(shape: *const Capsule, transform: Transform) AABB;

    /// Overlap shape versus capsule
    pub const overlap = b3OverlapCapsule;
    extern fn b3OverlapCapsule(shape: *const Capsule, shapeTransform: Transform, proxy: *const ShapeProxy) bool;

    /// Ray cast versus capsule in local space. A zero length ray is a point query. Initial overlap
    /// reports a hit at the ray origin with zero fraction and zero normal.
    pub const rayCast = b3RayCastCapsule;
    extern fn b3RayCastCapsule(shape: *const Capsule, input: *const RayCastInput) CastOutput;

    /// Shape cast versus a capsule. Initial overlap is treated as a miss.
    pub const shapeCast = b3ShapeCastCapsule;
    extern fn b3ShapeCastCapsule(shape: *const Capsule, input: *const ShapeCastInput) CastOutput;
};

/// A hull vertex. Identified by a half-edge with this vertex as its tail.
pub const HullVertex = extern struct {
    /// A half-edge that has this vertex as the origin
    /// Can be used along with edge twins and winding order
    /// to traverse all the edges connected to this vertex.
    edge: u8,
};

/// Half-edge for hull data structure
pub const HullHalfEdge = extern struct {
    /// Next edge index CCW
    next: u8,
    /// Twin edge index
    twin: u8,
    /// index of origin vertex and point
    origin: u8,
    /// Face to the left of this edge
    face: u8,
};

/// A hull face. Hulls use a half-edge data structure, so a face
/// can be determined from a single half-edge index.
pub const HullFace = extern struct {
    /// An arbitrary half-edge on this face
    edge: u8,
};

/// A convex hull.
/// Note: This data structure has data hanging off the end and cannot be directly copied.
pub const HullData = extern struct {
    /// Version must be first and match `HullData.current_version`
    version: u64,
    /// Hash of this hull (this field is zero when the hash is computed).
    hash: u64,
    /// Axis-aligned box in local space.
    aabb: AABB,
    /// Surface area, typically in squared meters.
    surfaceArea: f32,
    /// Volume, typically in m^3.
    volume: f32,
    /// The radius of the largest sphere at the center.
    innerRadius: f32,
    /// The local centroid.
    center: Vec3,
    /// The inertia tensor about the centroid.
    centralInertia: Matrix3,
    /// The vertex count.
    vertexCount: i32,
    /// Offset of the vertex array in bytes from the struct address.
    vertexOffset: i32,
    /// Offset of the point array in bytes from the struct address.
    pointOffset: i32,
    /// This is the half-edge count (double the edge count).
    edgeCount: i32,
    /// Offset of the edge array in bytes from the struct address.
    edgeOffset: i32,
    /// The face count. Hulls faces are convex polygons.
    faceCount: i32,
    /// Offset of the face plane array in bytes from the struct address.
    planeOffset: i32,
    /// Offset of the face array in bytes from the struct address.
    faceOffset: i32,
    /// Offset of structure of array (SOA) vertices.
    soaVertexOffset: i32,
    /// Offset of structure of array (SOA) unit normal vectors.
    soaNormalOffset: i32,
    /// Offset of dot(n1, n2) for each full edge.
    edgeCosineOffset: i32,
    /// The total number of bytes for this hull.
    byteCount: i32,
    /// Explicit padding for determinism.
    padding: i32,

    /// Hull version. Useful for validating serialized data.
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

    /// Deep clone a hull.
    pub const clone = b3CloneHull;
    extern fn b3CloneHull(hull: *const HullData) ?*HullData;

    /// Clone and transform a hull. Supports non-uniform and mirroring scale.
    pub const cloneAndTransform = b3CloneAndTransformHull;
    extern fn b3CloneAndTransformHull(original: *const HullData, transform: Transform, scale: Vec3) ?*HullData;

    /// Destroy a hull.
    pub const destroy = b3DestroyHull;
    extern fn b3DestroyHull(hull: *HullData) void;

    /// Compute mass properties of a hull
    pub const computeMass = b3ComputeHullMass;
    extern fn b3ComputeHullMass(shape: *const HullData, density: f32) MassData;

    /// Compute the bounding box of a transformed hull
    pub const computeAABB = b3ComputeHullAABB;
    extern fn b3ComputeHullAABB(shape: *const HullData, transform: Transform) AABB;

    /// Overlap shape versus hull
    pub const overlap = b3OverlapHull;
    extern fn b3OverlapHull(shape: *const HullData, shapeTransform: Transform, proxy: *const ShapeProxy) bool;

    /// Ray cast versus hull shape in local space. A zero length ray is a point query. Initial overlap
    /// reports a hit at the ray origin with zero fraction and zero normal.
    pub const rayCast = b3RayCastHull;
    extern fn b3RayCastHull(shape: *const HullData, input: *const RayCastInput) CastOutput;

    /// Shape cast versus a hull. Initial overlap is treated as a miss.
    pub const shapeCast = b3ShapeCastHull;
    extern fn b3ShapeCastHull(shape: *const HullData, input: *const ShapeCastInput) CastOutput;
};

/// Efficient box hull
pub const BoxHull = extern struct {
    /// The embedded hull. So the offsets index into the arrays that follow.
    base: HullData,
    /// Box vertices.
    boxVertices: [8]HullVertex,
    /// Box points.
    boxPoints: [8]Vec3,
    /// Box half-edges.
    boxEdges: [24]HullHalfEdge,
    /// Box face planes.
    boxPlanes: [6]Plane,
    /// Box faces.
    boxFaces: [6]HullFace,
    /// Explicit padding.
    padding: [2]u8,
    /// vertex x
    vx: [8]f32,
    /// vertex y
    vy: [8]f32,
    /// vertex z
    vz: [8]f32,
    /// normal x, padded to multiple of 8
    nx: [8]f32,
    /// normal y, padded to multiple of 8
    ny: [8]f32,
    /// normal z, padded to multiple of 8
    nz: [8]f32,
    /// dot(n1, n2) for each full edge.
    edgeCosines: [12]f32,

    /// The embedded hull, to pass to functions taking a `HullData`.
    pub fn hull(box: *const BoxHull) *const HullData {
        return &box.base;
    }
};

/// This is used to create a re-usable collision mesh. No pointers
/// are held to this data in `MeshData`. So all this data can be temporary.
pub const MeshDef = extern struct {
    /// Triangle vertices.
    vertices: ?[*]const Vec3,
    /// Stride between vertices. Use 0 for contiguous vertices.
    stride: usize,
    /// Triangle vertex indices. 3 for each triangle. CCW winding unless CW is indicated below.
    indices: ?[*]const i32,
    /// Triangle material index. 1 per triangle. Indexes into `ShapeDef.materials`.
    /// This allows different run-time material data to be associated with different
    /// instances of this mesh.
    materialIndices: ?[*]const u8,
    /// Tolerance for vertex welding in length units.
    weldTolerance: f32,
    /// The vertex count. Must be 3 or more.
    vertexCount: c_int,
    /// The triangle count. Must be 1 or more.
    triangleCount: c_int,
    /// Optionally weld nearby vertices.
    weldVertices: bool,
    /// Use the median split instead of SAH to speed up mesh creation. Good
    /// for meshes that are structured like a grid.
    useMedianSplit: bool,
    /// Compute triangle adjacency information using shared edges
    identifyEdges: bool,
    /// Input indices have clockWise winding order.
    clockWiseWinding: bool,
};

/// A mesh triangle.
pub const MeshTriangle = extern struct {
    /// Index of vertex 1.
    index1: i32,
    /// Index of vertex 2.
    index2: i32,
    /// Index of vertex 3.
    index3: i32,
};

/// A mesh BVH node.
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

/// This is a sorted triangle collision bounding volume hierarchy.
/// Note: This struct has data hanging off the end and cannot be directly copied.
pub const MeshData = extern struct {
    /// Version must be first.
    version: u64,
    /// Hash of this mesh (this field is zero when the hash is computed)
    hash: u64,
    /// The total number of bytes for this mesh.
    byteCount: i32,
    /// Local axis-aligned box.
    bounds: AABB,
    /// Combined surface area of all triangles. Single-sided.
    surfaceArea: f32,
    /// The height of the bounding volume hierarchy.
    treeHeight: i32,
    /// The number of degenerate triangles. Diagnostic.
    degenerateCount: i32,
    /// Offset of the node array in bytes from the struct address.
    nodeOffset: i32,
    /// The number of BVH nodes.
    nodeCount: i32,
    /// Offset of the vertex array in bytes from the struct address.
    vertexOffset: i32,
    /// The number of vertices.
    vertexCount: i32,
    /// Offset of the triangle array in bytes from the struct address.
    triangleOffset: i32,
    /// The number of triangles.
    triangleCount: i32,
    /// Offset of the material array in bytes from the struct address.
    materialOffset: i32,
    /// The number of materials.
    materialCount: i32,
    /// Offset of the triangle flag array in bytes from the struct address.
    flagsOffset: i32,
    /// Explicit padding.
    padding: i32,

    /// Mesh version. Useful for validating serialized data.
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

    /// Destroy a mesh.
    pub const destroy = b3DestroyMesh;
    extern fn b3DestroyMesh(mesh: *MeshData) void;

    /// Get the height of the mesh BVH.
    pub const getHeight = b3GetHeight;
    extern fn b3GetHeight(mesh: *const MeshData) c_int;

    /// Compute the bounding box of a transformed mesh. Scale may be non-uniform and have negative components.
    pub const computeAABB = b3ComputeMeshAABB;
    extern fn b3ComputeMeshAABB(shape: *const MeshData, transform: Transform, scale: Vec3) AABB;
};

/// This allows mesh data to be re-used with different scales.
pub const Mesh = extern struct {
    /// Immutable pointer to the mesh data.
    data: ?*const MeshData,
    /// This scale may be non-uniform and have negative components. However,
    /// no component may be very small in magnitude.
    scale: Vec3,

    /// Overlap shape versus mesh
    pub const overlap = b3OverlapMesh;
    extern fn b3OverlapMesh(shape: *const Mesh, shapeTransform: Transform, proxy: *const ShapeProxy) bool;

    /// Ray cast versus mesh in local space. A thin surface with no interior, so there is no overlap case.
    pub const rayCast = b3RayCastMesh;
    extern fn b3RayCastMesh(shape: *const Mesh, input: *const RayCastInput) CastOutput;

    /// Shape cast versus a mesh. Initial overlap is treated as a miss.
    pub const shapeCast = b3ShapeCastMesh;
    extern fn b3ShapeCastMesh(shape: *const Mesh, input: *const ShapeCastInput) CastOutput;

    /// Query a mesh for triangles overlapping a bounding box in local space. May have false positives. Useful for debug draw.
    /// - `mesh`: the mesh to query, includes scale
    /// - `bounds`: the bounding box in local space
    /// - `fcn`: a user function to collect triangles
    /// - `context`: the context sent to the user function.
    pub const query = b3QueryMesh;
    extern fn b3QueryMesh(mesh: *const Mesh, bounds: AABB, fcn: MeshQueryFcn, context: ?*anyopaque) void;
};

/// Data used to create a height field. No pointers are held to this data.
pub const HeightFieldDef = extern struct {
    /// Grid point heights
    /// count = countX * countZ
    heights: ?[*]const f32,
    /// Grid cell material
    /// A value of 0xFF is reserved for holes
    /// count = (countX - 1) * (countZ - 1)
    materialIndices: ?[*]const u8,
    /// The height field scale. All components must be positive values.
    scale: Vec3,
    /// The number of grid lines along the x-axis.
    countX: c_int,
    /// The number of grid lines along the z-axis.
    countZ: c_int,
    /// Global minimum and maximum heights used for quantization. This is important
    /// if you want height fields to be placed next to each other and line up exactly.
    /// In that case, both height fields should use the same minimum and maximum heights.
    /// All height values are clamped to this range.
    /// These values are in unscaled space.
    globalMinimumHeight: f32,
    /// The maximum.
    globalMaximumHeight: f32,
    /// Use clock-wise winding. This effectively inverts the height-field along the y-axis.
    clockwiseWinding: bool,
};

/// A height field with compressed storage.
/// Note: This data structure has data hanging off the end and cannot be directly copied.
pub const HeightFieldData = extern struct {
    /// Version must be first and match `HeightFieldData.current_version`
    version: u64,
    /// Hash of this height field (this field is zero when the hash is computed).
    hash: u64,
    /// The total number of bytes for this height field.
    byteCount: c_int,
    /// The local axis-aligned bounding box.
    aabb: AABB,
    /// The minimum y value.
    minHeight: f32,
    /// The maximum y value
    maxHeight: f32,
    /// The quantization scale.
    heightScale: f32,
    /// The overall scale.
    scale: Vec3,
    /// The number of grid columns along the local x-axis.
    columnCount: i32,
    /// The number of grid rows along the local z-axis.
    rowCount: i32,
    /// Offset of the compressed height array in bytes from the struct address.
    /// uint16_t, one per grid point.
    heightsOffset: i32,
    /// Offset of the material index array in bytes from the struct address.
    /// uint8_t, one per cell.
    materialOffset: i32,
    /// Offset of the flag array in bytes from the struct address.
    /// uint8_t, one per triangle.
    flagsOffset: i32,
    /// Triangle winding.
    clockwise: u8,
    /// Explicit padding.
    padding: [7]u8,

    /// Height field version. Useful for validating serialized data.
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

    /// Destroy a height field.
    pub const destroy = b3DestroyHeightField;
    extern fn b3DestroyHeightField(heightField: *HeightFieldData) void;

    /// Compute the bounding box of a transformed height-field
    pub const computeAABB = b3ComputeHeightFieldAABB;
    extern fn b3ComputeHeightFieldAABB(shape: *const HeightFieldData, transform: Transform) AABB;

    /// Overlap shape versus height field
    pub const overlap = b3OverlapHeightField;
    extern fn b3OverlapHeightField(shape: *const HeightFieldData, shapeTransform: Transform, proxy: *const ShapeProxy) bool;

    /// Ray cast versus height field in local space. A thin surface with no interior, so there is no overlap case.
    pub const rayCast = b3RayCastHeightField;
    extern fn b3RayCastHeightField(shape: *const HeightFieldData, input: *const RayCastInput) CastOutput;

    /// Shape cast versus a height field. Initial overlap is treated as a miss.
    pub const shapeCast = b3ShapeCastHeightField;
    extern fn b3ShapeCastHeightField(shape: *const HeightFieldData, input: *const ShapeCastInput) CastOutput;

    /// Query a height field for triangles overlapping a bounding box in local space. May have false positives. Useful for debug draw.
    /// - `heightField`: the height field to query
    /// - `bounds`: the bounding box in local space
    /// - `fcn`: a user function to collect triangles
    /// - `context`: the context sent to the user function.
    pub const query = b3QueryHeightField;
    extern fn b3QueryHeightField(heightField: *const HeightFieldData, bounds: AABB, fcn: MeshQueryFcn, context: ?*anyopaque) void;
};

/// Definition for a capsule in a compound shape.
pub const CompoundCapsuleDef = extern struct {
    /// Local capsule.
    capsule: Capsule,
    /// Material properties.
    material: SurfaceMaterial,
};

/// Definition for a convex hull in a compound shape.
pub const CompoundHullDef = extern struct {
    /// Shared hull.
    hull: ?*const HullData,
    /// Transform of the shared hull into compound local space.
    transform: Transform,
    /// Material properties.
    material: SurfaceMaterial,
};

/// Definition for a triangle mesh in a compound shape.
pub const CompoundMeshDef = extern struct {
    /// Shared mesh.
    meshData: ?*const MeshData,
    /// Transform of the shared mesh into compound local space.
    transform: Transform,
    /// Local space non-uniform mesh scale. May have negative components.
    scale: Vec3,
    /// Material properties.
    /// This array must line up with the material indices on the triangles.
    materials: ?[*]const SurfaceMaterial,
    /// Number of materials.
    materialCount: c_int,
};

/// Definition for a sphere in a compound shape.
pub const CompoundSphereDef = extern struct {
    /// Local sphere.
    sphere: Sphere,
    /// Material properties.
    material: SurfaceMaterial,
};

/// Definition for creating a compound shape. All this data is fully cloned
/// into the run-time compound shape.
pub const CompoundDef = extern struct {
    /// Capsule instances.
    capsules: ?[*]const CompoundCapsuleDef,
    /// Number of capsules.
    capsuleCount: c_int,
    /// Hulls instances.
    hulls: ?[*]const CompoundHullDef,
    /// Number of hull instances.
    hullCount: c_int,
    /// Mesh instances.
    meshes: ?[*]const CompoundMeshDef,
    /// Number of mesh instances.
    meshCount: c_int,
    /// Sphere instances.
    spheres: ?[*]const CompoundSphereDef,
    /// Number of spheres.
    sphereCount: c_int,
};

/// The data for a baked compound shape. This is a potentially large yet highly optimized
/// data structure. It can contain thousands of child shapes, yet at runtime it populates
/// into the world as a single shape in the runtime broad-phase.
/// This data structure has data living off the end and must be accessed using offsets.
/// Accessors are provided for user relevant data.
/// Note: you don't need to use this to create runtime compounds. For runtime compounds you can
/// add multiple shapes to a body using the regular shape creation functions.
pub const CompoundData = extern struct {
    /// The compound version is always first.
    version: u64,
    /// The total number of bytes for this compound.
    byteCount: c_int,
    bounds: AABB,
    treeHeight: c_int,
    /// Offset of the tree node array in bytes from the struct address.
    nodeOffset: c_int,
    nodeCount: c_int,
    /// Offset of the material array in bytes from the struct address.
    materialOffset: c_int,
    /// The number of materials.
    materialCount: c_int,
    /// Offset of the capsule array in bytes from the struct address.
    capsuleOffset: c_int,
    /// The number of capsules.
    capsuleCount: c_int,
    /// Offset of the hull instance array in bytes from the struct address.
    hullOffset: c_int,
    /// The number of hull instances.
    hullCount: c_int,
    /// The number of unique hulls. Diagnostic.
    sharedHullCount: c_int,
    /// Offset of the mesh instance array in bytes from the struct address.
    meshOffset: c_int,
    /// The number of mesh instances.
    meshCount: c_int,
    /// The number of unique meshes. Diagnostic.
    sharedMeshCount: c_int,
    /// Offset of the sphere array in bytes from the struct address.
    sphereOffset: c_int,
    /// The number of spheres.
    sphereCount: c_int,

    /// Compound version. Depends on the mesh and hull versions.
    pub const current_version: u64 = 0x9E4B17D3A25C68F1 ^ MeshData.current_version ^ HullData.current_version;

    /// Get a child shape of a compound.
    pub const getChild = b3GetCompoundChild;
    extern fn b3GetCompoundChild(compound: *const CompoundData, childIndex: c_int) ChildShape;

    /// Query a compound shape for children that overlap an AABB.
    pub const query = b3QueryCompound;
    extern fn b3QueryCompound(compound: *const CompoundData, aabb: AABB, fcn: CompoundQueryFcn, context: ?*anyopaque) void;

    /// Access a child capsule by index.
    pub const getCapsule = b3GetCompoundCapsule;
    extern fn b3GetCompoundCapsule(compound: *const CompoundData, index: c_int) CompoundCapsule;

    /// Access a child hull by index.
    pub const getHull = b3GetCompoundHull;
    extern fn b3GetCompoundHull(compound: *const CompoundData, index: c_int) CompoundHull;

    /// Access a child mesh by index.
    pub const getMesh = b3GetCompoundMesh;
    extern fn b3GetCompoundMesh(compound: *const CompoundData, index: c_int) CompoundMesh;

    /// Access a child sphere by index.
    pub const getSphere = b3GetCompoundSphere;
    extern fn b3GetCompoundSphere(compound: *const CompoundData, index: c_int) CompoundSphere;

    /// Access the compound material array.
    pub fn getMaterials(compound: *const CompoundData) []const SurfaceMaterial {
        return b3GetCompoundMaterials(compound)[0..@intCast(compound.materialCount)];
    }
    extern fn b3GetCompoundMaterials(compound: *const CompoundData) [*]const SurfaceMaterial;

    /// Destroy a compound shape.
    pub const destroy = b3DestroyCompound;
    extern fn b3DestroyCompound(compound: *CompoundData) void;

    /// Compute the bounding box of a compound
    pub const computeAABB = b3ComputeCompoundAABB;
    extern fn b3ComputeCompoundAABB(shape: *const CompoundData, transform: Transform) AABB;

    /// Overlap shape versus compound
    pub const overlap = b3OverlapCompound;
    extern fn b3OverlapCompound(shape: *const CompoundData, shapeTransform: Transform, proxy: *const ShapeProxy) bool;

    /// Ray cast versus compound in local space. A zero length ray is a point query. Initial overlap
    /// with a child reports a hit at the ray origin with zero fraction and zero normal.
    pub const rayCast = b3RayCastCompound;
    extern fn b3RayCastCompound(shape: *const CompoundData, input: *const RayCastInput) CastOutput;

    /// Shape cast versus compound. Initial overlap is treated as a miss.
    pub const shapeCast = b3ShapeCastCompound;
    extern fn b3ShapeCastCompound(shape: *const CompoundData, input: *const ShapeCastInput) CastOutput;
};

/// A capsule that lives in a compound.
pub const CompoundCapsule = extern struct {
    /// Local capsule.
    capsule: Capsule,
    /// Index to a shared material.
    materialIndex: u16,
    /// Padding for determinism.
    padding: u16,
};

/// A hull that lives in a compound.
pub const CompoundHull = extern struct {
    /// Pointer to the unique shared hull.
    hull: ?*const HullData,
    /// The transform of this hull instance.
    transform: Transform,
    /// Index to a shared material.
    materialIndex: u16,
    /// Padding for determinism.
    padding: u16,
};

/// A mesh with non-uniform scale that lives in a compound.
pub const CompoundMesh = extern struct {
    /// Pointer to the unique shared mesh.
    meshData: ?*const MeshData,
    /// The transform of this mesh instance.
    transform: Transform,
    /// Non-uniform scale of this mesh instance.
    scale: Vec3,
    /// This is used to access the surface material from `CompoundData.getMaterials`.
    /// Requires an extra level of indirection.
    /// materialIndex = materialIndices[triangle->materialIndex]
    materialIndices: ?[*]const u16,
    /// The number of materials. 1 for convex hapes.
    materialCount: c_int,
};

/// A sphere that lives in a compound.
pub const CompoundSphere = extern struct {
    /// Local sphere.
    sphere: Sphere,
    /// Index to a shared material.
    materialIndex: u16,
    /// Padding for determinism.
    padding: u16,
};

/// Child shape of a compound
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

/// Callback for compound overlap queries.
pub const CompoundQueryFcn = *const fn (compound: *const CompoundData, childIndex: c_int, context: ?*anyopaque) callconv(.c) bool;

/// Create a tessellated cylinder as a hull.
pub const createCylinder = b3CreateCylinder;
extern fn b3CreateCylinder(height: f32, radius: f32, yOffset: f32, sides: c_int) ?*HullData;

/// Create a tessellated cone as a hull.
pub const createCone = b3CreateCone;
extern fn b3CreateCone(height: f32, radius1: f32, radius2: f32, slices: c_int) ?*HullData;

/// Create a rock shaped hull.
pub const createRock = b3CreateRock;
extern fn b3CreateRock(radius: f32) ?*HullData;

/// Hull of 32 pseudo random points on a sphere. From the convex pile hull in PEEL.
pub const createComplexHull = b3CreateComplexHull;
extern fn b3CreateComplexHull(radius: f32) ?*HullData;

/// Create a generic convex hull. This can fail if `max_hull_vertices`, `max_hull_faces`,
/// or `max_hull_edges` is exceeded.
pub fn createHull(points: []const Vec3, maxVertexCount: c_int) ?*HullData {
    return b3CreateHull(points.ptr, @intCast(points.len), maxVertexCount);
}
extern fn b3CreateHull(points: [*]const Vec3, pointCount: c_int, maxVertexCount: c_int) ?*HullData;

/// Make a cube as a hull. Do not call `HullData.destroy` on this.
pub const makeCubeHull = b3MakeCubeHull;
extern fn b3MakeCubeHull(halfWidth: f32) BoxHull;

/// Make a box as a hull. Do not call `HullData.destroy` on this.
pub const makeBoxHull = b3MakeBoxHull;
extern fn b3MakeBoxHull(hx: f32, hy: f32, hz: f32) BoxHull;

/// Make an offset box as a hull. Do not call `HullData.destroy` on this.
pub const makeOffsetBoxHull = b3MakeOffsetBoxHull;
extern fn b3MakeOffsetBoxHull(hx: f32, hy: f32, hz: f32, offset: Vec3) BoxHull;

/// Make a transformed box as a hull. Do not call `HullData.destroy` on this.
/// - `hx`: , hy, hz positive half widths
/// - `transform`: local transform of box
pub const makeTransformedBoxHull = b3MakeTransformedBoxHull;
extern fn b3MakeTransformedBoxHull(hx: f32, hy: f32, hz: f32, transform: Transform) BoxHull;

/// This makes a transformed box hull with post scaling. This is useful for boxes that are scaled in
/// a level editor. Such scaling can have reflection and shear. In the case of shear the result
/// may be approximate. If you need to support shear consider using `createHull`.
/// Do not call `HullData.destroy` on this.
/// - `halfWidths`: positive half widths
/// - `transform`: local transform of box
/// - `postScale`: scale applied after the transform, may be negative
pub const makeScaledBoxHull = b3MakeScaledBoxHull;
extern fn b3MakeScaledBoxHull(halfWidths: Vec3, transform: Transform, postScale: Vec3) BoxHull;

/// This takes a box with a transform and post scale and converts it into a box with the post scale
/// resolved with new half-widths and transform. This accepts non-uniform and negative scale.
/// This is approximate if there is shear.
/// - `halfWidths`: the box half widths
/// - `transform`: the box transform with rotation and translation
/// - `postScale`: the post scale being applied to the box after the transform
/// - `minHalfWidth`: the minimum half width after scale is applied
pub const scaleBox = b3ScaleBox;
extern fn b3ScaleBox(halfWidths: *Vec3, transform: *Transform, postScale: Vec3, minHalfWidth: f32) void;

/// Create a grid mesh along the x and z axes.
/// - `xCount`: the number of rows in the x direction
/// - `zCount`: the number of rows in the z direction
/// - `cellWidth`: the width of each cell
/// - `materialCount`: the number of materials to generate
/// - `identifyEdges`: compute adjacency information
pub const createGridMesh = b3CreateGridMesh;
extern fn b3CreateGridMesh(xCount: c_int, zCount: c_int, cellWidth: f32, materialCount: c_int, identifyEdges: bool) ?*MeshData;

/// Create a wave mesh along the x and z axes.
pub const createWaveMesh = b3CreateWaveMesh;
extern fn b3CreateWaveMesh(xCount: c_int, zCount: c_int, cellWidth: f32, amplitude: f32, rowFrequency: f32, columnFrequency: f32) ?*MeshData;

/// Create a torus mesh.
pub const createTorusMesh = b3CreateTorusMesh;
extern fn b3CreateTorusMesh(radialResolution: c_int, tubularResolution: c_int, radius: f32, thickness: f32) ?*MeshData;

/// Create a box mesh.
pub const createBoxMesh = b3CreateBoxMesh;
extern fn b3CreateBoxMesh(center: Vec3, extent: Vec3, identifyEdges: bool) ?*MeshData;

/// Create a hollow box mesh.
pub const createHollowBoxMesh = b3CreateHollowBoxMesh;
extern fn b3CreateHollowBoxMesh(center: Vec3, extent: Vec3) ?*MeshData;

/// Create a platform mesh. A truncated pyramid.
pub const createPlatformMesh = b3CreatePlatformMesh;
extern fn b3CreatePlatformMesh(center: Vec3, height: f32, topWidth: f32, bottomWidth: f32) ?*MeshData;

/// Create a generic mesh.
pub fn createMesh(def: *const MeshDef, degenerateTriangleIndices: []i32) ?*MeshData {
    return b3CreateMesh(def, degenerateTriangleIndices.ptr, @intCast(degenerateTriangleIndices.len));
}
extern fn b3CreateMesh(def: *const MeshDef, degenerateTriangleIndices: ?[*]i32, degenerateCapacity: c_int) ?*MeshData;

/// Create a generic height field.
pub const createHeightField = b3CreateHeightField;
extern fn b3CreateHeightField(data: *const HeightFieldDef) ?*HeightFieldData;

/// Create a grid as a height field.
pub const createGrid = b3CreateGrid;
extern fn b3CreateGrid(rowCount: c_int, columnCount: c_int, scale: Vec3, makeHoles: bool) ?*HeightFieldData;

/// Create a wave grid as a height field.
pub const createWave = b3CreateWave;
extern fn b3CreateWave(rowCount: c_int, columnCount: c_int, scale: Vec3, rowFrequency: f32, columnFrequency: f32, makeHoles: bool) ?*HeightFieldData;

/// Save input height data to a file
pub const dumpHeightData = b3DumpHeightData;
extern fn b3DumpHeightData(data: *const HeightFieldDef, fileName: [*:0]const u8) void;

/// Create a height field by loading a previously saved height data
pub const loadHeightField = b3LoadHeightField;
extern fn b3LoadHeightField(fileName: [*:0]const u8) ?*HeightFieldData;

/// Create a compound shape. All input data in the definition is cloned into the resulting compound.
pub const createCompound = b3CreateCompound;
extern fn b3CreateCompound(def: *const CompoundDef) ?*CompoundData;

/// Cast serialized bytes into a compound and validate. Returns null if invalid.
pub fn validateCompound(bytes: []const u8) ?*const CompoundData {
    return b3ValidateCompound(bytes.ptr, @intCast(bytes.len));
}
extern fn b3ValidateCompound(bytes: [*]const u8, byteCount: c_int) ?*const CompoundData;

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
