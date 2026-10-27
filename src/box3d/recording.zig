//! Recording and replay (box3d.h)

const b3 = @import("../box3d.zig");
const AABB = b3.AABB;
const Body = b3.Body;
const CreateDebugShapeCallback = b3.CreateDebugShapeCallback;
const DebugDraw = b3.DebugDraw;
const DestroyDebugShapeCallback = b3.DestroyDebugShapeCallback;
const Pos = b3.Pos;
const QueryFilter = b3.QueryFilter;
const Shape = b3.Shape;
const Vec3 = b3.Vec3;
const World = b3.World;

/// Opaque recording handle. Create with `Recording.create`, destroy with `Recording.destroy`.
pub const Recording = opaque {
    /// Create a recording buffer with an optional initial byte capacity.
    /// Pass 0 to use the default (64 KiB). The buffer grows on demand.
    /// Returns a new recording, owned by the caller
    pub const create = b3CreateRecording;
    extern fn b3CreateRecording(byteCapacity: c_int) *Recording;

    /// Destroy a recording and free its buffer.
    /// - `recording`: may be null
    pub const destroy = b3DestroyRecording;
    extern fn b3DestroyRecording(recording: *Recording) void;

    /// Get a pointer to the raw recording bytes.
    /// Valid until the recording buffer is modified or destroyed.
    /// - `recording`: the recording handle
    /// Returns pointer to the byte buffer, or null if no bytes have been written
    pub fn getData(recording: *const Recording) []const u8 {
        const ptr = b3Recording_GetData(recording) orelse return &.{};
        return ptr[0..@intCast(b3Recording_GetSize(recording))];
    }
    extern fn b3Recording_GetData(recording: *const Recording) ?[*]const u8;

    /// Get the number of bytes currently in the recording buffer.
    /// - `recording`: the recording handle
    pub const getSize = b3Recording_GetSize;
    extern fn b3Recording_GetSize(recording: *const Recording) c_int;

    /// Save the recording buffer to a file. Returns true on success.
    /// - `recording`: the recording to save
    /// - `path`: file path to write
    pub const saveToFile = b3SaveRecordingToFile;
    extern fn b3SaveRecordingToFile(recording: *const Recording, path: [*:0]const u8) bool;

    /// Load a recording from a file. Returns null on failure (file not found, wrong magic).
    /// The caller owns the returned recording and must destroy it with `Recording.destroy`.
    /// - `path`: file path to read
    pub const loadFromFile = b3LoadRecordingFromFile;
    extern fn b3LoadRecordingFromFile(path: [*:0]const u8) ?*Recording;
};

/// Replay a recording from memory and verify it reproduces the same world-state hashes.
/// Stands up a fresh world, restores the seed snapshot, replays every op, and checks each embedded
/// StateHash record. Returns true if replay completed without id mismatches or hash divergences.
/// - `data`: pointer to recording bytes
/// - `size`: byte count of the recording
/// - `workerCount`: reserved for future multithreaded replay; pass 1 for now
pub fn validateReplay(data: []const u8, workerCount: c_int) bool {
    return b3ValidateReplay(data.ptr, @intCast(data.len), workerCount);
}
extern fn b3ValidateReplay(data: [*]const u8, size: c_int, workerCount: c_int) bool;

/// Opaque incremental replay player with a keyframe ring for O(interval) backward seek.
pub const RecPlayer = opaque {
    /// Create a player over a recording. Owns a private copy of the bytes.
    /// - `data`: pointer to recording bytes
    /// - `size`: byte count of the recording
    /// - `workerCount`: worker count for the replay world; pass 1 to match a serial recording.
    /// Replaying at a different count re-partitions the constraint graph, so the StateHash check
    /// becomes a cross-thread determinism test. Adjustable later with `RecPlayer.setWorkerCount`.
    /// Returns a new player, or null on bad header or deserialization failure
    pub fn create(data: []const u8, workerCount: c_int) ?*RecPlayer {
        return b3CreatePlayer(data.ptr, @intCast(data.len), workerCount);
    }
    extern fn b3CreatePlayer(data: [*]const u8, size: c_int, workerCount: c_int) ?*RecPlayer;

    /// Destroy the player and free all memory. Restores the previous global length scale.
    pub const destroy = b3DestroyPlayer;
    extern fn b3DestroyPlayer(player: *RecPlayer) void;

    /// Advance one frame. dispatch ops until the next Step completes.
    /// Returns true when a frame was stepped, false at end-of-recording
    pub const stepFrame = b3RecPlayer_StepFrame;
    extern fn b3RecPlayer_StepFrame(player: *RecPlayer) bool;

    /// Sub-step one frame. This will sub-step and return immediately after body creation.
    /// The next call will execute the time step. This allows bodies to be rendered
    /// at the creation pose.
    pub const subStepFrame = b3RecPlayer_SubStepFrame;
    extern fn b3RecPlayer_SubStepFrame(player: *RecPlayer) void;

    /// Rewind to frame 0 (in-place restore so the world id stays stable).
    pub const restart = b3RecPlayer_Restart;
    extern fn b3RecPlayer_Restart(player: *RecPlayer) void;

    /// Seek to a specific frame. Forward seek steps op-by-op; backward seek restores
    /// the nearest keyframe then re-steps the remaining gap.
    pub const seekFrame = b3RecPlayer_SeekFrame;
    extern fn b3RecPlayer_SeekFrame(player: *RecPlayer, targetFrame: c_int) void;

    /// Returns the world currently driven by this player
    pub const getWorldId = b3RecPlayer_GetWorldId;
    extern fn b3RecPlayer_GetWorldId(player: *const RecPlayer) World;

    /// Returns the last fully-stepped frame index (0 before any step)
    pub const getFrame = b3RecPlayer_GetFrame;
    extern fn b3RecPlayer_GetFrame(player: *const RecPlayer) c_int;

    /// Returns total number of recorded frames
    pub const getFrameCount = b3RecPlayer_GetFrameCount;
    extern fn b3RecPlayer_GetFrameCount(player: *const RecPlayer) c_int;

    /// Returns true when the op stream is exhausted
    pub const isAtEnd = b3RecPlayer_IsAtEnd;
    extern fn b3RecPlayer_IsAtEnd(player: *const RecPlayer) bool;

    /// Returns true when the op stream is paused between body creation and world step.
    pub const isAtPreStep = b3RecPlayer_IsAtPreStep;
    extern fn b3RecPlayer_IsAtPreStep(player: *const RecPlayer) bool;

    /// Returns true when any StateHash mismatch has been detected
    pub const hasDiverged = b3RecPlayer_HasDiverged;
    extern fn b3RecPlayer_HasDiverged(player: *const RecPlayer) bool;

    /// Returns a summary of the recording read at open: frame count, recorded tuning, and bounds
    pub const getInfo = b3RecPlayer_GetInfo;
    extern fn b3RecPlayer_GetInfo(player: *const RecPlayer) RecPlayerInfo;

    /// Returns the first frame at which replay diverged, or -1 if it has not diverged
    pub const getDivergeFrame = b3RecPlayer_GetDivergeFrame;
    extern fn b3RecPlayer_GetDivergeFrame(player: *const RecPlayer) c_int;

    /// Set the worker count of the replay world. Clamped to [1, `max_workers`]. Applied to the live
    /// world at once and reused whenever the player rebuilds its world on Restart or a backward seek.
    /// Replaying at a different count than recorded re-partitions the constraint graph, so the StateHash
    /// check becomes a cross-thread determinism test.
    pub const setWorkerCount = b3RecPlayer_SetWorkerCount;
    extern fn b3RecPlayer_SetWorkerCount(player: *RecPlayer, count: c_int) void;

    /// Tune the keyframe ring used to speed up backward seeking. A keyframe is a periodic snapshot the
    /// player restores from instead of replaying from the start, trading memory for seek speed.
    /// - `player`: the recording player
    /// - `budgetBytes`: memory cap for the kept snapshots; the spacing widens to stay under it
    /// - `minIntervalFrames`: finest spacing between keyframes, in frames
    /// A zero budget or a non-positive interval keeps that value. Clears the existing ring, so call
    /// `RecPlayer.restart` afterward to repopulate it under the new policy.
    pub const setKeyframePolicy = b3RecPlayer_SetKeyframePolicy;
    extern fn b3RecPlayer_SetKeyframePolicy(player: *RecPlayer, budgetBytes: usize, minIntervalFrames: c_int) void;

    /// Returns the keyframe memory budget in bytes
    pub const getKeyframeBudget = b3RecPlayer_GetKeyframeBudget;
    extern fn b3RecPlayer_GetKeyframeBudget(player: *const RecPlayer) usize;

    /// Returns the finest keyframe spacing in frames
    pub const getKeyframeMinInterval = b3RecPlayer_GetKeyframeMinInterval;
    extern fn b3RecPlayer_GetKeyframeMinInterval(player: *const RecPlayer) c_int;

    /// Returns the current keyframe spacing in frames; starts at the min interval and doubles as the
    /// ring evicts to stay under budget, so it reflects the effective backward-seek granularity now
    pub const getKeyframeInterval = b3RecPlayer_GetKeyframeInterval;
    extern fn b3RecPlayer_GetKeyframeInterval(player: *const RecPlayer) c_int;

    /// Returns the memory currently held by keyframe snapshots, in bytes
    pub const getKeyframeBytes = b3RecPlayer_GetKeyframeBytes;
    extern fn b3RecPlayer_GetKeyframeBytes(player: *const RecPlayer) usize;

    /// Returns the number of bodies tracked in creation order (including holes for destroyed bodies)
    pub const getBodyCount = b3RecPlayer_GetBodyCount;
    extern fn b3RecPlayer_GetBodyCount(player: *const RecPlayer) c_int;

    /// Resolve a creation ordinal to the live body id at the current frame.
    /// Returns the body id, or a null id if that ordinal is out of range or its body is destroyed
    pub const getBodyId = b3RecPlayer_GetBodyId;
    extern fn b3RecPlayer_GetBodyId(player: *const RecPlayer, index: c_int) Body;

    /// Wire host debug-shape callbacks into the player's replay world so a renderer can build
    /// per-shape draw resources (the 3D sample needs this or the replay world draws nothing).
    /// Rebuilds the current world under the new callbacks and rewinds to frame 0, so call it
    /// once right after `RecPlayer.create` and re-read the world id afterward. The callbacks
    /// persist across Restart and backward seeks, which recreate the world internally.
    /// - `player`: the player to configure
    /// - `createDebugShape`: called when a replayed shape is added; returns a user draw handle
    /// - `destroyDebugShape`: called when a replayed shape is removed; may be null
    /// - `context`: user context passed to both callbacks
    pub const setDebugShapeCallbacks = b3RecPlayer_SetDebugShapeCallbacks;
    extern fn b3RecPlayer_SetDebugShapeCallbacks(player: *RecPlayer, createDebugShape: CreateDebugShapeCallback, destroyDebugShape: ?DestroyDebugShapeCallback, context: ?*anyopaque) void;

    /// Draw the spatial queries recorded during the most recently replayed frame, layered on top of the
    /// world. Call after `World.draw`. null draw function pointers are skipped.
    /// - `player`: a valid player handle
    /// - `draw`: debug draw callbacks
    /// - `queryIndex`: index of the frame query to draw, or -1 to draw all of them
    /// - `selectedIndex`: index of the query to emphasize (reserved color plus a label), or -1 for none
    pub const drawFrameQueries = b3RecPlayer_DrawFrameQueries;
    extern fn b3RecPlayer_DrawFrameQueries(player: *RecPlayer, draw: *DebugDraw, queryIndex: c_int, selectedIndex: c_int) void;

    /// Returns the number of spatial queries recorded for the most recently replayed frame
    pub const getFrameQueryCount = b3RecPlayer_GetFrameQueryCount;
    extern fn b3RecPlayer_GetFrameQueryCount(player: *const RecPlayer) c_int;

    /// Get a recorded query from the most recently replayed frame by index.
    pub const getFrameQuery = b3RecPlayer_GetFrameQuery;
    extern fn b3RecPlayer_GetFrameQuery(player: *const RecPlayer, index: c_int) RecQueryInfo;

    /// Get one result of a recorded query from the most recently replayed frame.
    pub const getFrameQueryHit = b3RecPlayer_GetFrameQueryHit;
    extern fn b3RecPlayer_GetFrameQueryHit(player: *const RecPlayer, queryIndex: c_int, hitIndex: c_int) RecQueryHit;
};

/// Summary of a recording, read once at open so a viewer can frame and label it.
pub const RecPlayerInfo = extern struct {
    /// total recorded steps
    frameCount: c_int,
    /// worker count requested for the replay world
    workerCount: c_int,
    /// dt of the recorded steps
    timeStep: f32,
    /// recorded sub-steps
    subStepCount: c_int,
    /// length units per meter in effect when recorded
    lengthScale: f32,
    /// accumulated world bounds over the recording, zero-extent if unavailable
    bounds: AABB,
};

/// The kind of a recorded spatial query, matching the public query and cast functions.
pub const RecQueryType = enum(c_int) {
    overlap_aabb,
    overlap_shape,
    cast_ray,
    cast_shape,
    cast_ray_closest,
    cast_mover,
    collide_mover,
};

/// A spatial query recorded during a replayed frame, exposed for inspection.
pub const RecQueryInfo = extern struct {
    type: RecQueryType,
    filter: QueryFilter,
    /// world-space bounds of the query, swept for casts
    aabb: AABB,
    /// query origin (zero for overlap AABB)
    origin: Pos,
    /// ray and cast translation
    translation: Vec3,
    /// number of recorded results
    hitCount: c_int,
    /// identity key, the hash of (id, name), 0 if untagged
    key: u64,
    /// query id, 0 if none
    id: u64,
    /// query label, null if none
    name: ?[*:0]const u8,
};

/// One result of a recorded spatial query.
pub const RecQueryHit = extern struct {
    shape: Shape,
    point: Pos,
    normal: Vec3,
    fraction: f32,
};
