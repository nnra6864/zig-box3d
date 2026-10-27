//! Dynamic tree, a binary AABB tree to organize and query geometric objects (types.h, collision.h)

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const BoxCastInput = b3.BoxCastInput;
const RayCastInput = b3.RayCastInput;
const Vec3 = b3.Vec3;

/// A node in the dynamic tree. Siblings sit together at an even index so two nodes fit in
/// a 64 byte cache line. The root is at index zero and index one always empty.
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

/// Separate storage for tree leaves.
pub const TreeProxy = extern struct {
    /// User data is an index instead of void* because it is used internally as a shape index.
    userData: u64,
    /// Category bits for collision filtering.
    categoryBits: u64,
    /// The leaf node. `null_index` for a free proxy.
    node: i32,
    /// Next free proxy.
    next: i32,
};

/// The dynamic tree structure. This should be considered private data.
/// It is placed here for performance reasons.
pub const DynamicTree = extern struct {
    /// The dynamic tree version. Always the first field. Useful
    /// if the tree is serialized.
    version: u64,
    /// Array of nodes. The root is at index zero and index 1 is empty.
    /// Otherwise siblings are paired at even indices. Has holes for free node pairs.
    nodes: ?[*]TreeNode,
    /// Parent index per node. The free list is interweaved.
    parents: ?[*]i32,
    /// Proxy data split from node array as cold data.
    proxies: ?[*]TreeProxy,
    /// Every allocated node has a lower index than this.
    nodeEnd: i32,
    /// The allocated node space
    nodeCapacity: i32,
    /// Free pairs below nodeEnd
    pairFreeList: i32,
    /// Number of proxies created
    proxyCount: i32,
    /// The allocated proxy space
    proxyCapacity: i32,
    /// Proxy free list
    proxyFreeList: i32,
    /// Array of nodes for rebuild.
    swapNodes: ?[*]TreeNode,
    /// Leaf indices for rebuild
    leafIndices: ?[*]i32,
    /// Leaves for the rebuild. May represent a proxy or a retained subtree.
    leafNodes: ?[*]TreeNode,
    /// Leaf bounding boxes for rebuild
    leafBoxes: ?[*]AABB,
    /// Leaf bounding box centers for rebuild
    leafCenters: ?[*]Vec3,
    /// Bins for sorting during rebuild
    binIndices: ?[*]i32,
    /// Allocated space for rebuilding
    rebuildCapacity: i32,
    /// Rebuild orders the nodes so the children follow parents. Cache friendly for queries
    /// and refitting. The order can be disrupted by proxy creation.
    dfsOrdered: bool,

    /// Dynamic tree version for compatibility testing.
    pub const current_version: u64 = 0x1D6F4C2A73B80E91;

    /// Get proxy user data
    pub fn getUserData(tree: *const DynamicTree, proxyId: c_int) u64 {
        return tree.proxies.?[@intCast(proxyId)].userData;
    }

    /// Get the AABB of a proxy
    pub fn getAABB(tree: *const DynamicTree, proxyId: c_int) AABB {
        return tree.nodes.?[@intCast(tree.proxies.?[@intCast(proxyId)].node)].aabb;
    }

    /// Constructing the tree initializes the node pool.
    pub const create = b3DynamicTree_Create;
    extern fn b3DynamicTree_Create(proxyCapacity: c_int) DynamicTree;

    /// Destroy the tree, freeing the node pool.
    pub const destroy = b3DynamicTree_Destroy;
    extern fn b3DynamicTree_Destroy(tree: *DynamicTree) void;

    /// Create a proxy. Provide an AABB and a userData value.
    pub const createProxy = b3DynamicTree_CreateProxy;
    extern fn b3DynamicTree_CreateProxy(tree: *DynamicTree, aabb: AABB, categoryBits: u64, userData: u64) c_int;

    /// Destroy a proxy. This asserts if the id is invalid.
    pub const destroyProxy = b3DynamicTree_DestroyProxy;
    extern fn b3DynamicTree_DestroyProxy(tree: *DynamicTree, proxyId: c_int) void;

    /// Move a proxy to a new AABB by removing and reinserting into the tree.
    pub const moveProxy = b3DynamicTree_MoveProxy;
    extern fn b3DynamicTree_MoveProxy(tree: *DynamicTree, proxyId: c_int, aabb: AABB) void;

    /// Enlarge a proxy and enlarge ancestors as necessary.
    pub const enlargeProxy = b3DynamicTree_EnlargeProxy;
    extern fn b3DynamicTree_EnlargeProxy(tree: *DynamicTree, proxyId: c_int, aabb: AABB) void;

    /// Modify the category bits on a proxy. This is an expensive operation.
    pub const setCategoryBits = b3DynamicTree_SetCategoryBits;
    extern fn b3DynamicTree_SetCategoryBits(tree: *DynamicTree, proxyId: c_int, categoryBits: u64) void;

    /// Get the category bits on a proxy.
    pub const getCategoryBits = b3DynamicTree_GetCategoryBits;
    extern fn b3DynamicTree_GetCategoryBits(tree: *DynamicTree, proxyId: c_int) u64;

    /// Query an AABB for overlapping proxies. The callback function is called for each proxy that overlaps the supplied AABB.
    /// Returns performance data
    pub const query = b3DynamicTree_Query;
    extern fn b3DynamicTree_Query(tree: *const DynamicTree, aabb: AABB, maskBits: u64, requireAllBits: bool, callback: TreeQueryCallbackFcn, context: ?*anyopaque) TreeStats;

    /// Query an AABB for the closest object. The callback function is called for each proxy that might be closest to the supplied
    /// point.
    /// - `tree`: the dynamic tree to query
    /// - `point`: the query point
    /// - `maskBits`: proxies are skipped if the bit-wise AND with the proxy category bits is zero
    /// - `requireAllBits`: proxies are skipped if the bit-wise AND with the proxy category bits does not equal the maskBits
    /// - `callback`: a user provided instance of `TreeQueryClosestCallbackFcn`
    /// - `context`: a user context object that is provided to the callback
    /// - `minDistanceSqr`: the initial and final minimum squared distance. Provide a small initial to restrict the search and
    /// improve performance. If the value is large this query has performance that scales linearly with the number of proxies and
    /// would be slower than a brute force search.
    /// Returns performance data
    pub const queryClosest = b3DynamicTree_QueryClosest;
    extern fn b3DynamicTree_QueryClosest(tree: *const DynamicTree, point: Vec3, maskBits: u64, requireAllBits: bool, callback: TreeQueryClosestCallbackFcn, context: ?*anyopaque, minDistanceSqr: *f32) TreeStats;

    /// Ray cast against the proxies in the tree. This relies on the callback
    /// to perform an exact ray cast in the case where the proxy contains a shape.
    /// The callback also performs any collision filtering. This has performance
    /// roughly equal to k * log(n), where k is the number of collisions and n is the
    /// number of proxies in the tree.
    /// Bit-wise filtering using mask bits can greatly improve performance in some scenarios.
    /// However, this filtering may be approximate, so the user should still apply filtering to results.
    /// - `tree`: the dynamic tree to ray cast
    /// - `input`: the ray cast input data. The ray extends from p1 to p1 + maxFraction * (p2 - p1)
    /// - `maskBits`: bit mask test: `bool accept = (maskBits & proxy->categoryBits) != 0;`
    /// - `requireAllBits`: modifies bit mask test: `bool accept = (maskBits & proxy->categoryBits) == maskBits;`
    /// - `callback`: a callback function that is called for each proxy that is hit by the ray
    /// - `context`: user context that is passed to the callback
    /// Returns performance data
    pub const rayCast = b3DynamicTree_RayCast;
    extern fn b3DynamicTree_RayCast(tree: *const DynamicTree, input: *const RayCastInput, maskBits: u64, requireAllBits: bool, callback: TreeRayCastCallbackFcn, context: ?*anyopaque) TreeStats;

    /// Sweep an AABB through the tree. The box is in the tree's world float frame and the callback
    /// re-differences each shape at full precision against the query origin. Used by the large world
    /// spatial queries so the tree traversal stays float while the narrow phase stays precise.
    pub const boxCast = b3DynamicTree_BoxCast;
    extern fn b3DynamicTree_BoxCast(tree: *const DynamicTree, input: *const BoxCastInput, maskBits: u64, requireAllBits: bool, callback: TreeBoxCastCallbackFcn, context: ?*anyopaque) TreeStats;

    /// Get the height of the binary tree.
    pub const getHeight = b3DynamicTree_GetHeight;
    extern fn b3DynamicTree_GetHeight(tree: *const DynamicTree) c_int;

    /// Get the ratio of the sum of the node areas to the root area.
    pub const getAreaRatio = b3DynamicTree_GetAreaRatio;
    extern fn b3DynamicTree_GetAreaRatio(tree: *const DynamicTree) f32;

    /// Get the bounding box that contains the entire tree
    pub const getRootBounds = b3DynamicTree_GetRootBounds;
    extern fn b3DynamicTree_GetRootBounds(tree: *const DynamicTree) AABB;

    /// Get the number of proxies created
    pub const getProxyCount = b3DynamicTree_GetProxyCount;
    extern fn b3DynamicTree_GetProxyCount(tree: *const DynamicTree) c_int;

    /// Rebuild the tree while retaining subtrees that haven't changed. Returns the number of boxes sorted.
    pub const rebuild = b3DynamicTree_Rebuild;
    extern fn b3DynamicTree_Rebuild(tree: *DynamicTree, fullBuild: bool) c_int;

    /// Get the number of bytes used by this tree
    pub const getByteCount = b3DynamicTree_GetByteCount;
    extern fn b3DynamicTree_GetByteCount(tree: *const DynamicTree) c_int;

    /// Validate this tree. For testing.
    pub const validate = b3DynamicTree_Validate;
    extern fn b3DynamicTree_Validate(tree: *const DynamicTree) void;

    /// Validate this tree has no moved nodes. For testing.
    pub const validateNoMoved = b3DynamicTree_ValidateNoMoved;
    extern fn b3DynamicTree_ValidateNoMoved(tree: *const DynamicTree) void;

    /// Save this tree to a file for debugging
    pub const save = b3DynamicTree_Save;
    extern fn b3DynamicTree_Save(tree: *const DynamicTree, fileName: [*:0]const u8) void;

    /// Load a file for debugging
    pub const load = b3DynamicTree_Load;
    extern fn b3DynamicTree_Load(fileName: [*:0]const u8, scale: f32) DynamicTree;
};

/// These are performance results returned by dynamic tree queries.
pub const TreeStats = extern struct {
    /// Number of internal nodes visited during the query
    nodeVisits: c_int,
    /// Number of leaf nodes visited during the query
    leafVisits: c_int,
};

/// This function receives proxies found in the AABB query.
/// Returns true if the query should continue
pub const TreeQueryCallbackFcn = *const fn (proxyId: c_int, userData: u64, context: ?*anyopaque) callconv(.c) bool;

/// This function receives the minimum distance squared so far and proxy to check in the closest query.
/// Returns minimum distance squared to user objects in the proxy
pub const TreeQueryClosestCallbackFcn = *const fn (distanceSqrMin: f32, proxyId: c_int, userData: u64, context: ?*anyopaque) callconv(.c) f32;

/// This function receives clipped AABB cast input for a proxy. The function returns the new cast
/// fraction.
/// - return a value of 0 to terminate the cast
/// - return a value less than input->maxFraction to clip the cast
/// - return a value of input->maxFraction to continue the cast without clipping
pub const TreeBoxCastCallbackFcn = *const fn (input: *const BoxCastInput, proxyId: c_int, userData: u64, context: ?*anyopaque) callconv(.c) f32;

/// This function receives clipped ray cast input for a proxy. The function
/// returns the new ray fraction.
/// - return a value of 0 to terminate the ray cast
/// - return a value less than input->maxFraction to clip the ray
/// - return a value of input->maxFraction to continue the ray cast without clipping
pub const TreeRayCastCallbackFcn = *const fn (input: *const RayCastInput, proxyId: c_int, userData: u64, context: ?*anyopaque) callconv(.c) f32;
